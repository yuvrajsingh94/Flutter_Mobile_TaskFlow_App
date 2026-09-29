import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/storage/storage_service.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';

const String _themePrefKey = '@taskflow_theme_pref';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final StorageService? _storageService;

  ThemeModeNotifier(this._storageService) : super(_resolveInitialTheme(_storageService));

  static ThemeMode _resolveInitialTheme(StorageService? storage) {
    if (storage == null) return ThemeMode.light;
    final pref = storage.getString(_themePrefKey);
    if (pref == 'dark') return ThemeMode.dark;
    if (pref == 'system') return ThemeMode.system;
    return ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = nextMode;
    await _storageService?.setString(_themePrefKey, nextMode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final modeStr = mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.light
            ? 'light'
            : 'system';
    await _storageService?.setString(_themePrefKey, modeStr);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeModeNotifier(storage);
});
