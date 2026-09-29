import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/navigation/navigator_service.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/utils/name_input_formatter.dart';
import 'package:taskflow_flutter/core/utils/validators.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/app_card.dart';
import 'package:taskflow_flutter/core/widgets/app_phone_field.dart';
import 'package:taskflow_flutter/core/widgets/app_select.dart';
import 'package:taskflow_flutter/core/widgets/app_text_field.dart';
import 'package:taskflow_flutter/core/widgets/app_textarea.dart';
import 'package:taskflow_flutter/core/widgets/logout_confirmation_sheet.dart';
import 'package:taskflow_flutter/core/widgets/password_strength_meter.dart';
import 'package:taskflow_flutter/core/widgets/profile_avatar.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/auth/presentation/widgets/email_verification_banner.dart';
import 'package:taskflow_flutter/features/auth/presentation/widgets/phone_verification_modal.dart';
import 'package:taskflow_flutter/features/employees/presentation/providers/employee_provider.dart';
import 'package:taskflow_flutter/features/settings/presentation/screens/settings_screen.dart';

const List<SelectOption> kStandardQualificationOptions = [
  SelectOption(label: 'High School / 12th', value: 'High School / 12th'),
  SelectOption(label: 'Diploma', value: 'Diploma'),
  SelectOption(label: 'ITI', value: 'ITI'),
  SelectOption(label: 'B.A.', value: 'B.A.'),
  SelectOption(label: 'B.Sc.', value: 'B.Sc.'),
  SelectOption(label: 'B.Com.', value: 'B.Com.'),
  SelectOption(label: 'BCA', value: 'BCA'),
  SelectOption(label: 'BBA', value: 'BBA'),
  SelectOption(label: 'B.Tech / B.E.', value: 'B.Tech / B.E.'),
  SelectOption(label: 'B.Arch', value: 'B.Arch'),
  SelectOption(label: 'LLB', value: 'LLB'),
  SelectOption(label: 'M.A.', value: 'M.A.'),
  SelectOption(label: 'M.Sc.', value: 'M.Sc.'),
  SelectOption(label: 'M.Com.', value: 'M.Com.'),
  SelectOption(label: 'MCA', value: 'MCA'),
  SelectOption(label: 'MBA', value: 'MBA'),
  SelectOption(label: 'M.Tech / M.E.', value: 'M.Tech / M.E.'),
  SelectOption(label: 'Ph.D.', value: 'Ph.D.'),
  SelectOption(label: 'Other', value: 'Other'),
];

Map<String, String> parseQualificationAndSpecialization(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return {'qualification': '', 'specialization': ''};
  }
  final trimmed = raw.trim();
  final dashMatch = RegExp(r'^([^-]+)\s*-\s*(.+)$').firstMatch(trimmed);
  if (dashMatch != null) {
    return {
      'qualification': dashMatch.group(1)?.trim() ?? '',
      'specialization': dashMatch.group(2)?.trim() ?? '',
    };
  }
  final parenMatch = RegExp(r'^([^(]+)\s*\(([^)]+)\)$').firstMatch(trimmed);
  if (parenMatch != null) {
    return {
      'qualification': parenMatch.group(1)?.trim() ?? '',
      'specialization': parenMatch.group(2)?.trim() ?? '',
    };
  }
  return {'qualification': trimmed, 'specialization': ''};
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _specializationController;
  late TextEditingController _designationController;
  late TextEditingController _departmentController;
  late TextEditingController _bioController;
  late TextEditingController _qualificationController;

  String _countryCode = '+91';
  String _countryIso = 'IN';
  String _qualification = '';

  String? _firstNameError;
  String? _lastNameError;
  String? _phoneError;
  String? _bioError;

  final GlobalKey _personalDetailsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _specializationController = TextEditingController();
    _designationController = TextEditingController();
    _departmentController = TextEditingController();
    _bioController = TextEditingController();
    _qualificationController = TextEditingController();

    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _specializationController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).refreshUser();
      final user = ref.read(authNotifierProvider).user;
      _syncWithUser(user);
    });
  }

  void _onFieldChanged() {
    if (_isEditing && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_onFieldChanged);
    _lastNameController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _specializationController.removeListener(_onFieldChanged);
    _bioController.removeListener(_onFieldChanged);

    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    _bioController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  void _syncWithUser(UserProfile? user) {
    if (user == null) return;
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _emailController.text = user.email;
    _phoneController.text = user.phoneNumber;
    _countryCode = user.countryCode?.isNotEmpty == true ? user.countryCode! : '+91';
    _countryIso = kCountries
        .firstWhere(
          (c) => c.code == _countryCode,
          orElse: () => const CountryCode(name: 'India', flag: '🇮🇳', code: '+91', iso: 'IN'),
        )
        .iso;
    _bioController.text = user.bio ?? '';
    _designationController.text = user.designation?.isNotEmpty == true
        ? user.designation!
        : (user.role == UserRole.admin ? 'Administrator' : 'Software Engineer');
    _departmentController.text = user.department?.isNotEmpty == true
        ? user.department!
        : 'Engineering';

    final parsed = parseQualificationAndSpecialization(user.qualification);
    _qualification = parsed['qualification'] ?? '';
    _specializationController.text = parsed['specialization'] ?? '';
    _qualificationController.text =
        _qualification.isNotEmpty ? _qualification : 'Not provided';

    _firstNameError = null;
    _lastNameError = null;
    _phoneError = null;
    _bioError = null;
  }

  void _startEditing() {
    final user = ref.read(authNotifierProvider).user;
    setState(() {
      _syncWithUser(user);
      _isEditing = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_personalDetailsKey.currentContext != null) {
        Scrollable.ensureVisible(
          _personalDetailsKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _handleCancel() {
    final user = ref.read(authNotifierProvider).user;
    setState(() {
      _syncWithUser(user);
      _isEditing = false;
    });
  }

  bool get _hasUnsavedChanges {
    final user = ref.read(authNotifierProvider).user;
    if (user == null || !_isEditing) return false;
    final parsed = parseQualificationAndSpecialization(user.qualification);
    final initialQual = parsed['qualification'] ?? '';
    final initialSpec = parsed['specialization'] ?? '';

    return _firstNameController.text.trim() != user.firstName.trim() ||
        _lastNameController.text.trim() != user.lastName.trim() ||
        _phoneController.text.trim() != user.phoneNumber.trim() ||
        _countryCode != (user.countryCode?.isNotEmpty == true ? user.countryCode! : '+91') ||
        _bioController.text.trim() != (user.bio?.trim() ?? '') ||
        _qualification.trim() != initialQual.trim() ||
        _specializationController.text.trim() != initialSpec.trim();
  }

  Future<void> _handleSaveProfile() async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final fn = _firstNameController.text.trim();
    final ln = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final bio = _bioController.text.trim();

    final isPhoneChanging =
        phone != user.phoneNumber.trim() ||
        _countryCode != (user.countryCode?.isNotEmpty == true ? user.countryCode! : '+91');

    final fErr = Validators.validateFirstName(fn);
    final lErr = Validators.validateLastName(ln);
    final pErr = isPhoneChanging
        ? Validators.validatePhoneNumber(
            phone,
            isRequired: true,
            countryCode: _countryCode,
            isoCode: _countryIso,
          )
        : (phone.isEmpty ? 'Please enter your phone number.' : null);
    final bErr = Validators.validateBio(bio);

    setState(() {
      _firstNameError = fErr;
      _lastNameError = lErr;
      _phoneError = pErr;
      _bioError = bErr;
    });

    if (fErr != null || lErr != null || pErr != null || bErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check the highlighted fields.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final spec = _specializationController.text.trim();
    final qual = _qualification.trim();
    final combinedQualification = (qual.isNotEmpty && spec.isNotEmpty)
        ? '$qual - $spec'
        : (qual.isNotEmpty ? qual : spec);

    setState(() => _isSaving = true);

    try {
      final empRepo = ref.read(employeeRepositoryProvider);
      final updatedUser = await empRepo.updateMyProfile({
        'firstName': fn,
        'lastName': ln,
        'phoneNumber': phone,
        'countryCode': _countryCode,
        'bio': bio,
        'qualification': combinedQualification,
      });

      ref.read(authNotifierProvider.notifier).updateUser(updatedUser);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isEditing = false;
          _syncWithUser(updatedUser);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isPhoneChanging
                  ? 'Profile saved. Phone number updated — please verify with SMS OTP.'
                  : 'Profile updated successfully!',
            ),
            backgroundColor: isPhoneChanging ? AppColors.info : AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    await ref.read(authNotifierProvider.notifier).refreshUser();
    if (!_isEditing) {
      final user = ref.read(authNotifierProvider).user;
      _syncWithUser(user);
    }
  }

  void _showChangePasswordDialog() {
    final user = ref.read(authNotifierProvider).user;
    final messenger = ScaffoldMessenger.of(context);
    final currentPwCtrl = TextEditingController();
    final newPwCtrl = TextEditingController();
    final confirmPwCtrl = TextEditingController();

    bool isSubmitting = false;
    String? errorMsg;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.darkBgElevated : AppColors.surfaceElevated;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final handleColor = isDark ? AppColors.darkBorder : AppColors.borderHairline;
    final errorBg = isDark ? AppColors.darkErrorBg : AppColors.errorBg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep your account secure with a strong password',
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
                const SizedBox(height: 20),

                if (errorMsg != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: errorBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      errorMsg!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),

                AppTextField.password(
                  controller: currentPwCtrl,
                  label: 'Current Password',
                  placeholder: '••••••••',
                ),
                const SizedBox(height: 14),

                AppTextField.password(
                  controller: newPwCtrl,
                  label: 'New Password',
                  placeholder: '••••••••',
                  onChanged: (_) => setModalState(() {}),
                ),
                PasswordStrengthMeter(password: newPwCtrl.text),
                const SizedBox(height: 14),

                AppTextField.password(
                  controller: confirmPwCtrl,
                  label: 'Confirm New Password',
                  placeholder: '••••••••',
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        text: isSubmitting ? 'Updating...' : 'Update Password',
                        isLoading: isSubmitting,
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final cur = currentPwCtrl.text;
                                final neu = newPwCtrl.text;
                                final conf = confirmPwCtrl.text;

                                final curErr = Validators.validateLoginPassword(cur);
                                if (curErr != null) {
                                  setModalState(() => errorMsg = curErr);
                                  return;
                                }

                                final newErr = Validators.validateRegisterPassword(
                                  neu,
                                  firstName: user?.firstName,
                                  lastName: user?.lastName,
                                  email: user?.email,
                                );
                                if (newErr != null) {
                                  setModalState(() => errorMsg = newErr);
                                  return;
                                }

                                final confErr = Validators.validateConfirmPassword(neu, conf);
                                if (confErr != null) {
                                  setModalState(() => errorMsg = confErr);
                                  return;
                                }

                                setModalState(() {
                                  isSubmitting = true;
                                  errorMsg = null;
                                });

                                try {
                                  final authRepo = ref.read(authRepositoryProvider);
                                  await authRepo.changeTemporaryPassword(
                                    currentPassword: currentPwCtrl.text,
                                    newPassword: newPwCtrl.text,
                                  );

                                  if (ctx.mounted) {
                                    Navigator.pop(ctx);
                                  }
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Password changed successfully!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                } catch (e) {
                                  setModalState(() {
                                    isSubmitting = false;
                                    errorMsg = e.toString();
                                  });
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout() {
    final user = ref.read(authNotifierProvider).user;
    showLogoutConfirmationSheet(
      context: context,
      role: user?.role,
      onConfirmLogout: () async {
        await ref.read(authNotifierProvider.notifier).logout();
        if (context.mounted) {
          popToRoot();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final canGoBack = Navigator.canPop(context);

    return ScreenWrapper(
      title: 'Profile',
      subtitle: user?.role == UserRole.admin
          ? 'Workspace administrator profile'
          : 'Personal information & security',
      onBack: canGoBack ? () => Navigator.pop(context) : null,
      rightAction: IconButton(
        icon: const Icon(Icons.settings_outlined, size: 22),
        tooltip: 'Settings',
        onPressed: () {
          Navigator.push(
            context,
            SlidePageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
      onRefresh: _handleRefresh,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── User Card ──────────────────────────────────────────────────────────
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                ProfileAvatar(
                  imageUrl: user?.profilePicture,
                  name: user?.fullName,
                  radius: 44,
                  editable: true,
                ),
                const SizedBox(height: 12),

                Text(
                  user?.fullName.isNotEmpty == true ? user!.fullName : 'User',
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeLg,
                    fontWeight: AppTypography.fontWeightBold,
                    color: textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  '${user?.designation?.isNotEmpty == true ? user!.designation! : (user?.role == UserRole.admin ? 'Administrator' : 'Employee')} • ${user?.department?.isNotEmpty == true ? user!.department! : 'Engineering'}',
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeXs,
                    color: textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Interactive Verification Badges Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: user?.emailVerified == true
                          ? null
                          : () => EmailVerificationDialog.show(
                                context,
                                user?.email ?? '',
                                onVerified: _handleRefresh,
                              ),
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: user?.emailVerified == true
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          user?.emailVerified == true ? 'Email Verified ✓' : 'Verify Email ⚠️',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: user?.emailVerified == true ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: user?.phoneVerified == true
                          ? null
                          : () => PhoneVerificationModal.show(
                                context,
                                onSuccess: _handleRefresh,
                              ),
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: user?.phoneVerified == true
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          user?.phoneVerified == true ? 'Phone Verified ✓' : 'Verify Phone ⚠️',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: user?.phoneVerified == true ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Personal Details Card ─────────────────────────────────────────────
          AppCard(
            key: _personalDetailsKey,
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Personal Details',
                      style: TextStyle(
                        fontSize: AppTypography.fontSizeBase,
                        fontWeight: AppTypography.fontWeightBold,
                        color: textPrimaryColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_isEditing) {
                          _handleCancel();
                        } else {
                          _startEditing();
                        }
                      },
                      child: Text(
                        _isEditing ? 'Cancel' : 'Edit Profile',
                        style: TextStyle(
                          fontSize: AppTypography.fontSizeSm,
                          fontWeight: AppTypography.fontWeightSemibold,
                          color: isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // First Name & Last Name (2 columns)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'First Name',
                        controller: _firstNameController,
                        readOnly: !_isEditing,
                        maxLength: 30,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: const [NameInputFormatter(allowSpaces: false)],
                        error: _firstNameError,
                        isRequired: _isEditing,
                        onChanged: (t) {
                          if (_firstNameError != null) setState(() => _firstNameError = null);
                        },
                        onBlur: () {
                          if (_isEditing) {
                            setState(() {
                              _firstNameError =
                                  Validators.validateFirstName(_firstNameController.text);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Last Name',
                        controller: _lastNameController,
                        readOnly: !_isEditing,
                        maxLength: 50,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: const [NameInputFormatter(allowSpaces: true)],
                        error: _lastNameError,
                        isRequired: _isEditing,
                        onChanged: (t) {
                          if (_lastNameError != null) setState(() => _lastNameError = null);
                        },
                        onBlur: () {
                          if (_isEditing) {
                            setState(() {
                              _lastNameError =
                                  Validators.validateLastName(_lastNameController.text);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Work Email
                AppTextField(
                  label: 'Work Email',
                  controller: _emailController,
                  readOnly: true,
                  helperText: user?.role == UserRole.admin
                      ? 'Primary workspace identity (cannot be changed directly for security)'
                      : 'Email is managed by your workspace administrator',
                ),
                const SizedBox(height: 14),

                // Phone Number
                AppPhoneField(
                  label: 'Phone Number',
                  countryCode: _countryCode,
                  countryIso: _countryIso,
                  value: _phoneController.text,
                  editable: _isEditing,
                  isRequired: _isEditing,
                  onCountryCodeChange: (code) {
                    setState(() {
                      _countryCode = code;
                      _phoneError = null;
                    });
                  },
                  onCountryChange: (country) {
                    setState(() {
                      _countryCode = country.code;
                      _countryIso = country.iso;
                      _phoneError = null;
                    });
                  },
                  onChanged: (text) {
                    if (_phoneController.text != text) {
                      _phoneController.text = text;
                    }
                    if (_phoneError != null) setState(() => _phoneError = null);
                  },
                  onBlur: () {
                    if (_isEditing) {
                      setState(() {
                        _phoneError = Validators.validatePhoneNumber(
                          _phoneController.text,
                          isRequired: true,
                          countryCode: _countryCode,
                          isoCode: _countryIso,
                        );
                      });
                    }
                  },
                  error: _phoneError,
                  helperText: _isEditing &&
                          (_phoneController.text.trim() != (user?.phoneNumber ?? '') ||
                              _countryCode != (user?.countryCode ?? '+91'))
                      ? '⚠️ Changing your phone number will require SMS re-verification.'
                      : null,
                ),
                const SizedBox(height: 14),

                // Highest Qualification
                if (_isEditing)
                  AppSelect(
                    label: 'Highest Qualification',
                    options: kStandardQualificationOptions,
                    value: _qualification.isNotEmpty ? _qualification : null,
                    placeholder: 'Select Highest Qualification...',
                    searchable: true,
                    onChanged: (val) {
                      setState(() {
                        _qualification = val;
                        _qualificationController.text = val;
                      });
                    },
                  )
                else
                  AppTextField(
                    label: 'Highest Qualification',
                    controller: _qualificationController,
                    readOnly: true,
                    placeholder: 'e.g. B.Tech / B.E., MCA, MBA',
                  ),
                const SizedBox(height: 14),

                // Specialization / Field of Study
                AppTextField(
                  label: 'Specialization / Field of Study',
                  controller: _specializationController,
                  readOnly: !_isEditing,
                  placeholder: 'e.g. Computer Science & Engineering, Finance',
                  maxLength: 100,
                  helperText: _isEditing ? 'Academic major or specialization domain' : null,
                ),
                const SizedBox(height: 14),

                // Job Title / Designation & Department (2 columns)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Job Title / Designation',
                        controller: _designationController,
                        readOnly: true,
                        helperText: 'Assigned by workspace admin',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Department',
                        controller: _departmentController,
                        readOnly: true,
                        helperText: 'Assigned by workspace admin',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Short Bio
                AppTextarea(
                  label: 'Short Bio',
                  value: _bioController.text,
                  enabled: _isEditing,
                  maxLength: 500,
                  minLines: 3,
                  maxLines: 5,
                  placeholder: 'Tell us about your background, skills, or expertise...',
                  error: _bioError,
                  onChanged: (text) {
                    if (_bioController.text != text) {
                      _bioController.text = text;
                    }
                    if (_bioError != null) setState(() => _bioError = null);
                  },
                  onBlur: () {
                    if (_isEditing) {
                      setState(() {
                        _bioError = Validators.validateBio(_bioController.text);
                      });
                    }
                  },
                ),

                // Action Buttons Row (when editing)
                if (_isEditing) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Cancel',
                          variant: ButtonVariant.outline,
                          disabled: _isSaving,
                          onPressed: _handleCancel,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          text: 'Save Changes',
                          variant: ButtonVariant.primary,
                          isLoading: _isSaving,
                          disabled: _isSaving || !_hasUnsavedChanges,
                          onPressed: _handleSaveProfile,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Security & Password Card ──────────────────────────────────────────
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security & Credentials',
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeBase,
                    fontWeight: AppTypography.fontWeightBold,
                    color: textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep your account secure by periodically updating your password.',
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeXs,
                    color: textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _showChangePasswordDialog,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkOverlayMedium : AppColors.surfaceStone,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.key_outlined,
                          size: 20,
                          color: isDark ? AppColors.darkAccentPrimary : AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Change Password',
                                style: TextStyle(
                                  fontSize: AppTypography.fontSizeSm,
                                  fontWeight: AppTypography.fontWeightSemibold,
                                  color: textPrimaryColor,
                                ),
                              ),
                              Text(
                                'Update your account password',
                                style: TextStyle(
                                  fontSize: AppTypography.fontSizeXs,
                                  color: textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 20, color: textSecondaryColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Log Out Button ────────────────────────────────────────────────────
          InkWell(
            onTap: _handleLogout,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                border: Border.all(color: AppColors.error),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                  SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeSm,
                      fontWeight: AppTypography.fontWeightBold,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
