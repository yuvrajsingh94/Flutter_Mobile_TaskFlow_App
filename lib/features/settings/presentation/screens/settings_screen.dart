import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/config/api_config.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/theme/theme_provider.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/app_text_field.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _urlController = TextEditingController();
  bool _isTesting = false;
  String? _testResult;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _urlController.text = ApiConfig.baseUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final targetUrl = _urlController.text.trim();
    if (targetUrl.isEmpty) return;

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      final clean = targetUrl.endsWith('/')
          ? targetUrl.substring(0, targetUrl.length - 1)
          : targetUrl;
      final endpoint = '$clean/me';

      final res = await dio.get(endpoint);
      setState(() {
        _isTesting = false;
        _isSuccess = true;
        _testResult = 'Success! Server reachable (HTTP ${res.statusCode}).';
      });
    } on DioException catch (dioErr) {
      final status = dioErr.response?.statusCode;
      if (status == 401 || status == 200) {
        // 401 Unauthorized means server is running and route exists!
        setState(() {
          _isTesting = false;
          _isSuccess = true;
          _testResult = 'Success! Connected to TaskFlow backend (HTTP $status).';
        });
      } else {
        setState(() {
          _isTesting = false;
          _isSuccess = false;
          _testResult = 'Server error: ${dioErr.message} (HTTP $status)';
        });
      }
    } catch (e) {
      setState(() {
        _isTesting = false;
        _isSuccess = false;
        _testResult = 'Connection failed: $e';
      });
    }
  }

  Future<void> _saveUrl() async {
    final targetUrl = _urlController.text.trim();
    await ApiConfig.setCustomBaseUrl(targetUrl);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API Base URL saved: ${ApiConfig.baseUrl}')),
      );
    }
  }

  Future<void> _resetDefault() async {
    await ApiConfig.resetToDefault();
    _urlController.text = ApiConfig.baseUrl;
    setState(() {
      _testResult = 'Reset to factory default.';
      _isSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardBg = isDark ? AppColors.darkBgCard : AppColors.surfaceElevated;
    final borderCol = isDark ? AppColors.darkBorderSubtle : AppColors.borderHairline;
    final chipBg = isDark ? AppColors.darkBgInput : AppColors.surfaceStone;

    return ScreenWrapper(
      appBar: AppBar(
        title: const Text('Settings & Connection'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Appearance Section ──────────────────────────────────────────
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Customize the look and feel of the application.',
            style: TextStyle(fontSize: 13, color: textSecondary),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      size: 18,
                      color: isDark ? AppColors.darkAccentPrimary : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Theme',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose Light, Dark, or follow your device system theme.',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
                const SizedBox(height: 14),
                _ThemeSegmentSelector(
                  selectedMode: currentThemeMode,
                  onModeChanged: (newMode) {
                    ref.read(themeModeProvider.notifier).setThemeMode(newMode);
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── 2. Backend Configuration Section ────────────────────────────────
          Text(
            'Backend Configuration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ensure the mobile device is on the same local Wi-Fi network as your development computer to connect seamlessly.',
            style: TextStyle(fontSize: 13, color: textSecondary),
          ),
          const SizedBox(height: 20),

          // Base URL Input
          AppTextField(
            label: 'API Base URL',
            hint: 'http://172.16.2.15:5000/api',
            controller: _urlController,
          ),
          const SizedBox(height: 12),

          // Presets
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                backgroundColor: chipBg,
                side: BorderSide(color: borderCol),
                label: Text(
                  'LAN IP (Physical Phone)',
                  style: TextStyle(fontSize: 12, color: textPrimary),
                ),
                onPressed: () {
                  _urlController.text = 'http://172.16.2.15:5000/api';
                },
              ),
              ActionChip(
                backgroundColor: chipBg,
                side: BorderSide(color: borderCol),
                label: Text(
                  'Android Emulator (10.0.2.2)',
                  style: TextStyle(fontSize: 12, color: textPrimary),
                ),
                onPressed: () {
                  _urlController.text = 'http://10.0.2.2:5000/api';
                },
              ),
              ActionChip(
                backgroundColor: chipBg,
                side: BorderSide(color: borderCol),
                label: Text(
                  'Localhost (iOS / Web)',
                  style: TextStyle(fontSize: 12, color: textPrimary),
                ),
                onPressed: () {
                  _urlController.text = 'http://localhost:5000/api';
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Test connection result banner
          if (_testResult != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isSuccess
                    ? (isDark ? AppColors.darkSuccessBg : AppColors.lightSuccessBg)
                    : (isDark ? AppColors.darkErrorBg : AppColors.lightErrorBg),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isSuccess
                      ? (isDark ? AppColors.darkSuccess : AppColors.lightSuccess)
                      : (isDark ? AppColors.darkError : AppColors.lightError),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                    color: _isSuccess
                        ? (isDark ? AppColors.darkSuccess : AppColors.lightSuccess)
                        : (isDark ? AppColors.darkError : AppColors.lightError),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _testResult!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _isSuccess
                            ? (isDark ? AppColors.darkSuccess : AppColors.lightSuccess)
                            : (isDark ? AppColors.darkError : AppColors.lightError),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Test Connection',
                  variant: ButtonVariant.secondary,
                  isLoading: _isTesting,
                  onPressed: _testConnection,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: 'Save URL',
                  variant: ButtonVariant.primary,
                  onPressed: _saveUrl,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          AppButton(
            text: 'Reset to Default URL',
            variant: ButtonVariant.ghost,
            onPressed: _resetDefault,
          ),

          const SizedBox(height: 28),

          // ── 3. About Client Section ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About Client',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'TaskFlow Multi-Platform Client',
                  style: TextStyle(fontSize: 13, color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0 (Flutter / Dart)',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Target: Android + iOS',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ThemeSegmentSelector extends StatelessWidget {
  final ThemeMode selectedMode;
  final ValueChanged<ThemeMode> onModeChanged;
  final bool isDark;

  const _ThemeSegmentSelector({
    required this.selectedMode,
    required this.onModeChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      (ThemeMode.light, Icons.light_mode_rounded, 'Light'),
      (ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
      (ThemeMode.system, Icons.brightness_auto_rounded, 'System'),
    ];

    final activeBg = isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary;
    final activeFg = isDark ? AppColors.darkAccentFg : AppColors.lightAccentFg;
    final inactiveFg = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgInput : AppColors.surfaceStone,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorderSubtle : AppColors.borderHairline,
        ),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = selectedMode == opt.$1;

          return Expanded(
            child: InkWell(
              onTap: () => onModeChanged(opt.$1),
              borderRadius: BorderRadius.circular(9),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      opt.$2,
                      size: 17,
                      color: isSelected ? activeFg : inactiveFg,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      opt.$3,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? activeFg : inactiveFg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
