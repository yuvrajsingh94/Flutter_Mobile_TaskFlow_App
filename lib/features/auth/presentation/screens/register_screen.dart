import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/navigation/navigator_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/constants/api_endpoints.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/utils/name_input_formatter.dart';
import 'package:taskflow_flutter/core/utils/validators.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/app_checkbox.dart';
import 'package:taskflow_flutter/core/widgets/app_dob_picker.dart';
import 'package:taskflow_flutter/core/widgets/app_phone_field.dart';
import 'package:taskflow_flutter/core/widgets/app_select.dart';
import 'package:taskflow_flutter/core/widgets/app_text_field.dart';
import 'package:taskflow_flutter/core/widgets/app_textarea.dart';
import 'package:taskflow_flutter/core/widgets/password_strength_meter.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/auth/presentation/screens/verify_email_screen.dart';

const List<String> kGenders = ['Male', 'Female', 'Other'];
const List<SelectOption> kQualifications = [
  SelectOption(label: 'High School', value: 'High School'),
  SelectOption(label: 'Diploma', value: 'Diploma'),
  SelectOption(label: "Bachelor's Degree", value: "Bachelor's Degree"),
  SelectOption(label: "Master's Degree", value: "Master's Degree"),
  SelectOption(label: 'Doctorate / PhD', value: 'Doctorate / PhD'),
];

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _countryCode = '+91';
  String _countryIso = 'IN';
  String _phoneNumber = '';
  String _dob = '';
  String _gender = 'Male';
  String _qualification = "Bachelor's Degree";
  String _bio = '';
  bool _termsAccepted = false;

  // Field error states
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _dobError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _bioError;
  String? _termsError;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showTermsDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBorderRadius.card)),
        title: Text(
          'Terms & Privacy Policy',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: AppTypography.fontWeightBold,
            fontSize: AppTypography.fontSizeBase,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'By creating an account on TaskFlow Enterprise, you agree that your '
            'workspace activities, task assignments, and performance logs are accessible '
            'to authorized administrators within your organization.\n\n'
            '1. Account Security: You are responsible for keeping your credentials confidential.\n'
            '2. Acceptable Use: TaskFlow may only be used for legitimate business operations.\n'
            '3. Data Privacy: We never sell your organizational data.\n\n'
            'All organizational interactions comply with enterprise security standards.',
            style: TextStyle(
              fontSize: AppTypography.fontSizeSm,
              height: 1.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    final fn = _firstNameController.text;
    final ln = _lastNameController.text;
    final email = _emailController.text.trim().toLowerCase();
    final pass = _passwordController.text;
    final cPass = _confirmPasswordController.text;

    final fErr = Validators.validateFirstName(fn);
    final lErr = Validators.validateLastName(ln);
    final eErr = Validators.validateEmail(email);
    final pErr = Validators.validatePhoneNumber(
      _phoneNumber,
      isRequired: true,
      countryCode: _countryCode,
      isoCode: _countryIso,
    );
    final dErr = Validators.validateDob(_dob);
    final passErr = Validators.validateRegisterPassword(pass, firstName: fn, lastName: ln, email: email);
    final cPassErr = Validators.validateConfirmPassword(pass, cPass);
    final bErr = Validators.validateBio(_bio);
    final tErr = _termsAccepted ? null : 'Please accept the Terms & Conditions to continue.';

    setState(() {
      _firstNameError = fErr;
      _lastNameError = lErr;
      _emailError = eErr;
      _phoneError = pErr;
      _dobError = dErr;
      _passwordError = passErr;
      _confirmPasswordError = cPassErr;
      _bioError = bErr;
      _termsError = tErr;
    });

    if (fErr != null ||
        lErr != null ||
        eErr != null ||
        pErr != null ||
        dErr != null ||
        passErr != null ||
        cPassErr != null ||
        bErr != null ||
        tErr != null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final formData = {
      'firstName': Validators.capitalizeFirst(fn),
      'lastName': Validators.capitalizeWords(ln),
      'email': email,
      'countryCode': _countryCode,
      'phoneNumber': _phoneNumber.trim(),
      'dob': _dob.trim(),
      'gender': _gender,
      'qualification': _qualification,
      'bio': _bio.trim(),
      'password': pass,
    };

    try {
      final dio = ref.read(dioClientProvider);

      // Send OTP to email first
      final res = await dio.post(
        ApiEndpoints.sendEmailOtp,
        data: {'email': formData['email']},
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (!mounted) return;
        final previewUrl = res.data is Map ? res.data['previewUrl']?.toString() : null;
        Navigator.of(context).push(
          SlidePageRoute(
            builder: (_) => VerifyEmailScreen(
              email: formData['email'] as String,
              registrationPayload: formData,
              previewUrl: previewUrl,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = res.data?['message']?.toString() ?? 'Failed to send OTP verification.';
        });
      }
    } catch (err) {
      final dynamic e = err;
      final dynamic resData = e?.response?.data;
      final msg = (resData is Map ? resData['message'] : null) ?? 'Failed to register. Please check connection.';
      final cleanedMsg = msg.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      final lower = cleanedMsg.toLowerCase();
      final isAlreadyRegistered = lower.contains('already exist') ||
          lower.contains('already registered') ||
          lower.contains('duplicate') ||
          lower.contains('already in use');
      setState(() {
        _errorMessage = isAlreadyRegistered
            ? 'An account with this email already exists. Please sign in instead.'
            : cleanedMsg;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final bgCard = isDark ? AppColors.darkCard : AppColors.card;
    final borderSubtle = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;
    final accentPrimary = isDark ? AppColors.darkAccentPrimary : AppColors.accentPrimary;
    final accentFg = isDark ? AppColors.darkAccentFg : AppColors.accentFg;

    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return PopScope(
      canPop: !isKeyboardVisible,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        FocusScope.of(context).unfocus();
      },
      child: ScreenWrapper(
        title: 'Create Account',
        subtitle: "Join your organization's TaskFlow workspace",
        onBack: () => Navigator.of(context).pop(),
        scrollable: true,
        dismissKeyboardOnTap: true,
        child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.sm),

              // Error banner
              if (_errorMessage != null) ...[
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
                          _errorMessage!,
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

              // Card Container
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(AppBorderRadius.card),
                  border: Border.all(color: borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // First & Last Name row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'First Name',
                            placeholder: 'John',
                            controller: _firstNameController,
                            isRequired: true,
                            maxLength: 30,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: const [NameInputFormatter(allowSpaces: false)],
                            error: _firstNameError,
                            onChanged: (val) {
                              if (_firstNameError != null) setState(() => _firstNameError = null);
                            },
                            onBlur: () {
                              setState(() => _firstNameError =
                                  Validators.validateFirstName(_firstNameController.text));
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppTextField(
                            label: 'Last Name',
                            placeholder: 'Doe',
                            controller: _lastNameController,
                            isRequired: true,
                            maxLength: 50,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: const [NameInputFormatter(allowSpaces: true)],
                            error: _lastNameError,
                            onChanged: (val) {
                              if (_lastNameError != null) setState(() => _lastNameError = null);
                            },
                            onBlur: () {
                              setState(() => _lastNameError =
                                  Validators.validateLastName(_lastNameController.text));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Email Address
                    AppTextField(
                      label: 'Work Email Address',
                      placeholder: 'john.doe@company.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                      maxLength: 254,
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      leftIcon: Icon(Icons.mail_outline_rounded, size: 18, color: textSecondary),
                      error: _emailError,
                      onChanged: (val) {
                        if (_emailError != null) setState(() => _emailError = null);
                      },
                      onBlur: () {
                        setState(() => _emailError = Validators.validateEmail(_emailController.text));
                      },
                    ),

                    // Phone Field with Country Picker
                    AppPhoneField(
                      label: 'Phone Number',
                      countryCode: _countryCode,
                      countryIso: _countryIso,
                      onCountryCodeChange: (code) {
                        setState(() {
                          _countryCode = code;
                          if (_phoneNumber.isNotEmpty) {
                            _phoneError = Validators.validatePhoneNumber(
                              _phoneNumber,
                              isRequired: true,
                              countryCode: _countryCode,
                              isoCode: _countryIso,
                            );
                          } else if (_phoneError != null) {
                            _phoneError = null;
                          }
                        });
                      },
                      onCountryChange: (country) {
                        setState(() {
                          _countryCode = country.code;
                          _countryIso = country.iso;
                          if (_phoneNumber.isNotEmpty) {
                            _phoneError = Validators.validatePhoneNumber(
                              _phoneNumber,
                              isRequired: true,
                              countryCode: _countryCode,
                              isoCode: _countryIso,
                            );
                          } else if (_phoneError != null) {
                            _phoneError = null;
                          }
                        });
                      },
                      value: _phoneNumber,
                      isRequired: true,
                      error: _phoneError,
                      onChanged: (val) {
                        setState(() {
                          _phoneNumber = val;
                          if (_phoneError != null) _phoneError = null;
                        });
                      },
                      onBlur: () {
                        setState(() => _phoneError = Validators.validatePhoneNumber(
                          _phoneNumber,
                          isRequired: true,
                          countryCode: _countryCode,
                          isoCode: _countryIso,
                        ));
                      },
                    ),

                    // Date of Birth Multi-Stage Picker
                    AppDOBPicker(
                      label: 'Date of Birth',
                      value: _dob,
                      isRequired: true,
                      error: _dobError,
                      onChanged: (val) {
                        setState(() {
                          _dob = val;
                          _dobError = Validators.validateDob(val);
                        });
                      },
                      onBlur: () {
                        setState(() => _dobError = Validators.validateDob(_dob));
                      },
                    ),

                    // Gender Selection
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Gender',
                                style: TextStyle(
                                  fontSize: AppTypography.fontSizeSm,
                                  fontWeight: AppTypography.fontWeightMedium,
                                  color: isDark ? AppColors.darkTextLabel : AppColors.lightTextLabel,
                                ),
                              ),
                              Text(
                                '*',
                                style: TextStyle(
                                  color: isDark ? AppColors.darkError : AppColors.lightError,
                                  fontSize: AppTypography.fontSizeSm,
                                  fontWeight: AppTypography.fontWeightMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: kGenders.map((g) {
                              final isSelected = _gender == g;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: InkWell(
                                    onTap: () => setState(() => _gender = g),
                                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isSelected ? accentPrimary : Colors.transparent,
                                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                                        border: Border.all(
                                          color: isSelected ? accentPrimary : borderSubtle,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          g,
                                          style: TextStyle(
                                            fontSize: AppTypography.fontSizeSm,
                                            fontWeight: isSelected
                                                ? AppTypography.fontWeightBold
                                                : AppTypography.fontWeightMedium,
                                            color: isSelected ? accentFg : textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // Qualification Select
                    AppSelect(
                      label: 'Highest Qualification',
                      options: kQualifications,
                      value: _qualification,
                      isRequired: true,
                      onChanged: (val) => setState(() => _qualification = val),
                    ),

                    // Bio Textarea
                    AppTextarea(
                      label: 'Professional Bio',
                      placeholder: 'Briefly describe your role, skills, and background...',
                      value: _bio,
                      maxLength: 500,
                      minLines: 3,
                      error: _bioError,
                      onChanged: (val) {
                        setState(() {
                          _bio = val;
                          if (_bioError != null) _bioError = Validators.validateBio(val);
                        });
                      },
                      onBlur: () {
                        if (_bio.isNotEmpty) {
                          setState(() => _bioError = Validators.validateBio(_bio));
                        }
                      },
                    ),

                    // Password
                    AppTextField.password(
                      label: 'Password',
                      placeholder: '••••••••',
                      controller: _passwordController,
                      isRequired: true,
                      maxLength: 64,
                      leftIcon: Icon(Icons.lock_outline_rounded, size: 18, color: textSecondary),
                      error: _passwordError,
                      onChanged: (val) {
                        if (_passwordError != null) setState(() => _passwordError = null);
                      },
                      onBlur: () {
                        setState(() => _passwordError = Validators.validateRegisterPassword(
                          _passwordController.text,
                          firstName: _firstNameController.text,
                          lastName: _lastNameController.text,
                          email: _emailController.text,
                        ));
                      },
                    ),
                    const SizedBox(height: 8),

                    PasswordStrengthMeter(password: _passwordController.text),
                    const SizedBox(height: AppSpacing.lg),

                    // Confirm Password
                    AppTextField.password(
                      label: 'Confirm Password',
                      placeholder: '••••••••',
                      controller: _confirmPasswordController,
                      isRequired: true,
                      maxLength: 64,
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      leftIcon: Icon(Icons.lock_outline_rounded, size: 18, color: textSecondary),
                      error: _confirmPasswordError,
                      onChanged: (val) {
                        if (_confirmPasswordError != null) setState(() => _confirmPasswordError = null);
                      },
                      onBlur: () {
                        setState(() => _confirmPasswordError = Validators.validateConfirmPassword(
                          _passwordController.text,
                          _confirmPasswordController.text,
                        ));
                      },
                    ),

                    // Terms Checkbox & Link
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AppCheckbox(
                                value: _termsAccepted,
                                onChanged: (val) {
                                  setState(() {
                                    _termsAccepted = val;
                                    if (val) _termsError = null;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'I agree to the ',
                                      style: TextStyle(
                                        fontSize: AppTypography.fontSizeXs,
                                        color: textSecondary,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _showTermsDialog,
                                      child: Text(
                                        'Terms & Conditions',
                                        style: TextStyle(
                                          fontSize: AppTypography.fontSizeXs,
                                          fontWeight: AppTypography.fontWeightBold,
                                          color: textPrimary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      ' and Privacy Policy.',
                                      style: TextStyle(
                                        fontSize: AppTypography.fontSizeXs,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_termsError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 26),
                              child: Text(
                                _termsError!,
                                style: const TextStyle(color: AppColors.error, fontSize: 11),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Submit Button
                    AppButton(
                      title: _isLoading ? 'Sending Verification Code...' : 'Create Account',
                      loading: _isLoading,
                      variant: ButtonVariant.primary,
                      size: ButtonSize.lg,
                      onPressed: _handleRegister,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Back to Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(color: textSecondary, fontSize: AppTypography.fontSizeSm),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: AppTypography.fontSizeSm,
                        fontWeight: AppTypography.fontWeightBold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
