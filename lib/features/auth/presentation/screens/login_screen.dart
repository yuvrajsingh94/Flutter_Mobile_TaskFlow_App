import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/navigation/navigator_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:taskflow_flutter/core/config/api_config.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/utils/validators.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/app_checkbox.dart';
import 'package:taskflow_flutter/core/widgets/app_text_field.dart';
import 'package:taskflow_flutter/core/widgets/logo.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:taskflow_flutter/features/auth/presentation/screens/register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storage = ref.read(storageServiceProvider);
      if (storage.getRememberMe()) {
        final savedEmail = storage.getRememberedEmail();
        if (savedEmail != null) {
          _emailController.text = savedEmail;
          setState(() => _rememberMe = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      _emailError = Validators.validateEmail(_emailController.text);
      _passwordError = Validators.validateLoginPassword(_passwordController.text);
    });
  }

  Future<void> _handleLogin() async {
    _validateFields();
    if (_emailError != null || _passwordError != null) return;

    ref.read(authNotifierProvider.notifier).clearError();
    setState(() => _errorMsg = null);

    try {
      await ref.read(authNotifierProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
            rememberMe: _rememberMe,
          );
    } catch (e) {
      setState(() => _errorMsg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''));
    }
  }

  void _showServerConfigModal() {
    final urlController = TextEditingController(text: ApiConfig.baseUrl);
    String? testResult;
    bool isTesting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final isDark = Theme.of(sheetCtx).brightness == Brightness.dark;
        final bgCard = isDark ? AppColors.darkCard : AppColors.card;
        final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
        final borderSubtle = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.sm,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
                border: Border(top: BorderSide(color: borderSubtle, width: 1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBorderInput : AppColors.borderInput,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Backend Connection',
                        style: TextStyle(
                          fontSize: AppTypography.fontSizeBase,
                          fontWeight: AppTypography.fontWeightBold,
                          color: textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetCtx),
                        icon: Icon(Icons.close, color: textSecondary, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Ensure your phone and computer are on the same Wi-Fi. The Express backend runs on port 5000.',
                    style: TextStyle(fontSize: AppTypography.fontSizeXs, color: textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'API Base URL',
                    hint: 'http://172.16.2.15:5000/api',
                    controller: urlController,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        label: const Text('LAN IP', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          setModalState(() {
                            urlController.text = 'http://172.16.2.15:5000/api';
                          });
                        },
                      ),
                      ActionChip(
                        label: const Text('Android Emulator', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          setModalState(() {
                            urlController.text = 'http://10.0.2.2:5000/api';
                          });
                        },
                      ),
                      ActionChip(
                        label: const Text('Localhost', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          setModalState(() {
                            urlController.text = 'http://localhost:5000/api';
                          });
                        },
                      ),
                    ],
                  ),
                  if (testResult != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      testResult!,
                      style: TextStyle(
                        fontSize: AppTypography.fontSizeXs,
                        fontWeight: AppTypography.fontWeightMedium,
                        color: testResult!.startsWith('Success') ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: isTesting
                            ? null
                            : () async {
                                setModalState(() {
                                  isTesting = true;
                                  testResult = null;
                                });
                                try {
                                  final dio = Dio(BaseOptions(
                                    connectTimeout: const Duration(seconds: 4),
                                    receiveTimeout: const Duration(seconds: 4),
                                  ));
                                  final clean = urlController.text.trim().replaceAll(RegExp(r'/+$'), '');
                                  final res = await dio.get('$clean/me');
                                  setModalState(() {
                                    testResult = 'Success! Connected (HTTP ${res.statusCode})';
                                    isTesting = false;
                                  });
                                } catch (err) {
                                  setModalState(() {
                                    testResult = 'Connection failed: Check Wi-Fi and host IP';
                                    isTesting = false;
                                  });
                                }
                              },
                        child: Text(isTesting ? 'Testing...' : 'Test Connection'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppButton(
                        title: 'Save & Apply',
                        size: ButtonSize.sm,
                        onPressed: () async {
                          final clean = urlController.text.trim().replaceAll(RegExp(r'/+$'), '');
                          await ApiConfig.setCustomBaseUrl(clean);
                          if (!sheetCtx.mounted) return;
                          Navigator.pop(sheetCtx);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('API URL set to: ${ApiConfig.baseUrl}')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final bgCard = isDark ? AppColors.darkCard : AppColors.card;
    final borderSubtle = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;
    final errorText = (_errorMsg ?? authState.errorMessage)?.replaceFirst(RegExp(r'^Exception:\s*'), '');

    return ScreenWrapper(
      scrollable: true,
      dismissKeyboardOnTap: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Header & Logo Checkmark (Long press logo for Server Config modal)
              Center(
                child: Column(
                  children: [
                    Logo(
                      size: LogoSize.md,
                      showWordmark: false,
                      onLongPress: kDebugMode ? _showServerConfigModal : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ENTERPRISE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: AppTypography.fontWeightBold,
                            letterSpacing: 1.2,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: AppTypography.fontWeightBold,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in to your TaskFlow account',
                      style: TextStyle(
                        fontSize: AppTypography.fontSizeSm,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Error Banner
              if (errorText != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkErrorBg : AppColors.errorBg,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(color: AppColors.errorBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorText,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: AppTypography.fontSizeXs,
                            fontWeight: AppTypography.fontWeightMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Form Card Surface
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(AppBorderRadius.card),
                  border: Border.all(color: borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email Field
                    AppTextField(
                      label: 'Email Address',
                      placeholder: 'yourname@gmail.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      leftIcon: Icon(Icons.mail_outline_rounded, size: 18, color: textSecondary),
                      error: _emailError,
                      onChanged: (text) {
                        if (_emailError != null) setState(() => _emailError = null);
                        if (_errorMsg != null) setState(() => _errorMsg = null);
                      },
                      onBlur: () {
                        setState(() => _emailError = Validators.validateEmail(_emailController.text));
                      },
                    ),

                    // Password Field
                    AppTextField.password(
                      label: 'Password',
                      placeholder: '••••••••',
                      controller: _passwordController,
                      isRequired: true,
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      leftIcon: Icon(Icons.lock_outline_rounded, size: 18, color: textSecondary),
                      error: _passwordError,
                      onSubmitted: (_) => _handleLogin(),
                      onChanged: (text) {
                        if (_passwordError != null) setState(() => _passwordError = null);
                        if (_errorMsg != null) setState(() => _errorMsg = null);
                      },
                      onBlur: () {
                        setState(() => _passwordError = Validators.validateLoginPassword(_passwordController.text));
                      },
                    ),

                    // Remember Me & Forgot Password Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppCheckbox(
                          label: 'Remember me',
                          value: _rememberMe,
                          disabled: authState.isLoading,
                          onChanged: (val) => setState(() => _rememberMe = val),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              SlidePageRoute(builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: AppTypography.fontSizeXs,
                              fontWeight: AppTypography.fontWeightMedium,
                              color: textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Submit Button
                    AppButton(
                      title: authState.isLoading ? 'Signing In...' : 'Sign In',
                      onPressed: _handleLogin,
                      loading: authState.isLoading,
                      variant: ButtonVariant.primary,
                      size: ButtonSize.lg,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Footer Register Link
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: AppTypography.fontSizeSm,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        SlidePageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      'Create one now',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: AppTypography.fontSizeSm,
                        fontWeight: AppTypography.fontWeightBold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Trust Bar matching web & React Native
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildTrustItem(Icons.lock_outline_rounded, 'SSL Secured', isDark),
                  _buildTrustDivider(isDark),
                  _buildTrustItem(Icons.shield_outlined, 'AES-256', isDark),
                  _buildTrustDivider(isDark),
                  _buildTrustItem(Icons.speed_rounded, '99.9% Uptime', isDark),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String label, bool isDark) {
    final color = isDark ? AppColors.darkTextPlaceholder : AppColors.textPlaceholder;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.fontSizeTiny,
            color: color,
            fontWeight: AppTypography.fontWeightMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildTrustDivider(bool isDark) {
    final color = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: 1,
        height: 10,
        color: color,
      ),
    );
  }
}
