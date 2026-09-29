import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/network/dio_client.dart';
import 'package:taskflow_flutter/core/storage/storage_service.dart';
import 'package:taskflow_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';

// ── Global Core Providers ───────────────────────────────────────────────────

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be initialized before runApp');
});

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return DioClient(storage: storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRepository(dioClient: dioClient);
});

// ── Auth State Model ────────────────────────────────────────────────────────

class AuthState {
  final UserProfile? user;
  final String? token;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitialized;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
  });

  bool get isAuthenticated => user != null && token != null;
  bool get isAdmin => user?.isAdmin ?? false;
  bool get isEmployee => user?.isEmployee ?? false;

  AuthState copyWith({
    UserProfile? user,
    String? token,
    bool? isLoading,
    String? errorMessage,
    bool? isInitialized,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      token: clearUser ? null : (token ?? this.token),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

// ── Auth Notifier ───────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final StorageService _storage;

  AuthNotifier({
    required AuthRepository repository,
    required StorageService storage,
    required DioClient dioClient,
  })  : _repository = repository,
        _storage = storage,
        super(AuthState()) {
    dioClient.onUnauthorized = handleUnauthorized;
    _initAuth();
  }

  Future<void> _initAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await _storage.getToken();
      final cachedUser = _storage.getUser();

      if (token != null && token.isNotEmpty) {
        state = state.copyWith(
          token: token,
          user: cachedUser,
          isInitialized: true,
          isLoading: false,
        );

        // Fetch fresh profile in background
        try {
          final freshUser = await _repository.getMe();
          await _storage.saveUser(freshUser);
          state = state.copyWith(user: freshUser);
        } catch (_) {
          // If offline or network error, keep cached user
        }
      } else {
        state = state.copyWith(isInitialized: true, isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isInitialized: true, isLoading: false);
    }
  }

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _repository.login(email: email, password: password);
      final token = res['token'] as String;
      final refreshToken = res['refreshToken'] as String?;
      var user = res['user'] as UserProfile;

      await _storage.saveToken(token);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _storage.saveRefreshToken(refreshToken);
      }
      await _storage.saveUser(user);
      await _storage.setRememberMe(rememberMe, email: email);

      // Immediately fetch complete profile from /api/me to retrieve profilePicture, phone, bio, etc.
      try {
        final fullUser = await _repository.getMe();
        user = fullUser;
        await _storage.saveUser(user);
      } catch (_) {
        // Continue with basic user if getMe fails
      }

      state = state.copyWith(
        user: user,
        token: token,
        isLoading: false,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Silently refresh the full user profile from the backend
  Future<void> refreshUser() async {
    try {
      final freshUser = await _repository.getMe();
      await _storage.saveUser(freshUser);
      state = state.copyWith(user: freshUser);
    } catch (_) {
      // Keep cached state if network fails
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    String? countryCode,
    String? dob,
    String? gender,
    String? qualification,
    String? bio,
    String? department,
    String? designation,
    String role = 'employee',
    String? otp,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        dob: dob,
        gender: gender,
        qualification: qualification,
        bio: bio,
        department: department,
        designation: designation,
        role: role,
        otp: otp,
      );
      final token = res['token'] as String?;
      final refreshToken = res['refreshToken'] as String?;
      final user = res['user'] as UserProfile;

      if (token != null && token.isNotEmpty) {
        await _storage.saveToken(token);
      }
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _storage.saveRefreshToken(refreshToken);
      }
      await _storage.saveUser(user);

      state = state.copyWith(
        user: user,
        token: token,
        isLoading: false,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> setSession({required String token, required UserProfile user}) async {
    await _storage.saveToken(token);
    await _storage.saveUser(user);
    state = state.copyWith(
      user: user,
      token: token,
      isLoading: false,
      errorMessage: null,
    );
  }

  void updateUser(UserProfile updated) {
    _storage.saveUser(updated);
    state = state.copyWith(user: updated);
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    final refreshToken = await _storage.getRefreshToken();
    await _repository.logout(refreshToken: refreshToken);
    await _storage.clearSession();
    state = AuthState(isInitialized: true);
  }

  void handleUnauthorized() {
    _storage.clearSession();
    state = AuthState(isInitialized: true);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final storage = ref.watch(storageServiceProvider);
  final dioClient = ref.watch(dioClientProvider);
  return AuthNotifier(
    repository: repository,
    storage: storage,
    dioClient: dioClient,
  );
});
