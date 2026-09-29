import 'package:dio/dio.dart';
import 'package:taskflow_flutter/core/constants/api_endpoints.dart';
import 'package:taskflow_flutter/core/network/dio_client.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Dio get _dio => _dioClient.dio;

  /// Logs in using email & password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token']?.toString() ?? '';
      final refreshToken = data['refreshToken']?.toString();
      final userMap = data['user'] as Map<String, dynamic>;
      final user = UserProfile.fromJson(userMap);

      return {'token': token, 'refreshToken': refreshToken, 'user': user};
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Registers a new user account
  Future<Map<String, dynamic>> register({
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
    String role = 'employee',
    String? department,
    String? designation,
    String? otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
          'phoneNumber': phoneNumber.trim(),
          if (countryCode != null) 'countryCode': countryCode,
          if (dob != null) 'dob': dob,
          if (gender != null) 'gender': gender,
          if (qualification != null) 'qualification': qualification,
          if (bio != null) 'bio': bio,
          'role': role,
          if (department != null) 'department': department,
          if (designation != null) 'designation': designation,
          if (otp != null) 'otp': otp.trim(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token']?.toString() ?? '';
      final refreshToken = data['refreshToken']?.toString();
      final userMap = data['user'] as Map<String, dynamic>;
      final user = UserProfile.fromJson(userMap);

      return {'token': token, 'refreshToken': refreshToken, 'user': user};
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Gets current authenticated user profile
  Future<UserProfile> getMe() async {
    try {
      final response = await _dio.get(ApiEndpoints.me);
      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Logs out user
  Future<void> logout({String? refreshToken}) async {
    try {
      await _dio.post(
        ApiEndpoints.logout,
        data: {
          if (refreshToken != null) 'refreshToken': refreshToken,
        },
      );
    } catch (_) {
      // ignore network errors during logout
    }
  }

  /// Send email OTP for verification (returns optional test previewUrl when in development mode)
  Future<String?> sendEmailOtp(String email) async {
    try {
      final res = await _dio.post(ApiEndpoints.sendEmailOtp, data: {'email': email.trim().toLowerCase()});
      if (res.data is Map) {
        return (res.data as Map)['previewUrl']?.toString();
      }
      return null;
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Verify email OTP
  Future<void> verifyEmailOtp(String email, String otp) async {
    try {
      await _dio.post(
        ApiEndpoints.verifyEmailOtpPublic,
        data: {'email': email.trim().toLowerCase(), 'otp': otp.trim()},
      );
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Send public phone OTP
  Future<void> sendPhoneOtpPublic(String phoneNumber) async {
    try {
      await _dio.post(
        ApiEndpoints.sendPhoneOtpPublic,
        data: {'phoneNumber': phoneNumber.trim()},
      );
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Change temporary password on first login
  Future<void> changeTemporaryPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.changeTempPassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Send email verification to current logged-in user
  Future<void> sendVerificationEmail() async {
    try {
      await _dio.post(ApiEndpoints.sendVerificationEmail);
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Verify email for current logged-in user
  Future<void> verifyEmailCurrent(String otp) async {
    try {
      await _dio.post(
        ApiEndpoints.verifyEmail,
        data: {'otp': otp.trim()},
      );
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Send phone OTP to current logged-in user
  Future<void> sendPhoneOtp() async {
    try {
      await _dio.post(ApiEndpoints.sendPhoneOtp);
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Verify phone OTP for current logged-in user
  Future<void> verifyPhoneOtp(String otp) async {
    try {
      await _dio.post(
        ApiEndpoints.verifyPhoneOtp,
        data: {'otp': otp.trim()},
      );
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Request OTP for forgotten password (returns optional test previewUrl when in development mode)
  Future<String?> forgotPasswordOtp(String email) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.forgotPasswordOtp,
        data: {'email': email.trim().toLowerCase()},
      );
      if (res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        final msg = map['message']?.toString() ?? '';
        if (msg.contains('If an account exists') && !map.containsKey('previewUrl')) {
          throw 'No account found with this email address. Please check and try again.';
        }
        return map['previewUrl']?.toString();
      }
      return null;
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Verify forgot password OTP
  Future<void> verifyForgotPasswordOtp(String email, String otp) async {
    try {
      await _dio.post(
        ApiEndpoints.verifyForgotPasswordOtp,
        data: {'email': email.trim().toLowerCase(), 'otp': otp.trim()},
      );
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Reset password with verified OTP
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email.trim().toLowerCase(),
          'otp': otp.trim(),
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Admin only: get all users for task assignments
  Future<List<UserProfile>> getAllUsers() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.users,
        queryParameters: {'limit': 1000},
      );
      final list = <UserProfile>[];
      final raw = response.data;
      if (raw is List) {
        for (final item in raw) {
          if (item is Map<String, dynamic>) list.add(UserProfile.fromJson(item));
        }
      } else if (raw is Map<String, dynamic> && raw['users'] is List) {
        for (final item in raw['users']) {
          if (item is Map<String, dynamic>) list.add(UserProfile.fromJson(item));
        }
      }
      return list;
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }
}
