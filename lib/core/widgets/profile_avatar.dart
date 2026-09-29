import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskflow_flutter/core/network/dio_client.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/employees/presentation/providers/employee_provider.dart';

class ProfileAvatar extends ConsumerStatefulWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final bool editable;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 36,
    this.editable = false,
    this.onTap,
  });

  @override
  ConsumerState<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends ConsumerState<ProfileAvatar> {
  bool _isUploading = false;
  bool _hasImageError = false;

  @override
  void didUpdateWidget(covariant ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _hasImageError = false;
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'U';
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      // Client-side guard: enforce max 5 MB size limit
      if (bytes.lengthInBytes > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image is too large (maximum size is 5MB). Please select a smaller photo.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      setState(() => _isUploading = true);

      final base64String = base64Encode(bytes);
      final dataUri = 'data:image/jpeg;base64,$base64String';

      final empRepo = ref.read(employeeRepositoryProvider);
      final updatedUser = await empRepo.updateMyProfile({'profilePicture': dataUri});

      ref.read(authNotifierProvider.notifier).updateUser(updatedUser);

      if (mounted) {
        setState(() {
          _hasImageError = false;
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        final errorMessage = DioClient.extractErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage.startsWith('Failed to')
                  ? errorMessage
                  : 'Failed to update picture: $errorMessage',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _removePhoto() async {
    try {
      setState(() => _isUploading = true);

      final empRepo = ref.read(employeeRepositoryProvider);
      final updatedUser = await empRepo.updateMyProfile({'profilePicture': ''});

      ref.read(authNotifierProvider.notifier).updateUser(updatedUser);

      if (mounted) {
        setState(() {
          _hasImageError = false;
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture removed.'),
            backgroundColor: AppColors.textPrimary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        final errorMessage = DioClient.extractErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage.startsWith('Failed to')
                  ? errorMessage
                  : 'Failed to remove picture: $errorMessage',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImageOptions() {
    final hasCurrentPhoto = widget.imageUrl != null && widget.imageUrl!.trim().isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.darkBgElevated : AppColors.surfaceElevated;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final iconBg = isDark ? AppColors.darkBgInput : AppColors.surfaceStone;
    final iconColor = isDark ? AppColors.darkAccentPrimary : AppColors.primary;
    final handleColor = isDark ? AppColors.darkBorder : AppColors.borderHairline;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Profile Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Upload a photo from your gallery or take a new one',
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.photo_library_outlined, color: iconColor),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.camera_alt_outlined, color: iconColor),
                ),
                title: Text(
                  'Take Photo',
                  style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              if (hasCurrentPhoto) ...[
                Divider(height: 16, color: handleColor),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkErrorBg : AppColors.errorBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  ),
                  title: const Text(
                    'Remove Current Photo',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _removePhoto();
                  },
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarContent() {
    final url = widget.imageUrl;
    final size = widget.radius * 2;

    if (!_hasImageError && url != null && url.trim().isNotEmpty) {
      if (url.startsWith('data:image/')) {
        try {
          final commaIndex = url.indexOf(',');
          final base64Data = commaIndex != -1 ? url.substring(commaIndex + 1) : url;
          final bytes = base64Decode(base64Data);
          return ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: Image.memory(
              bytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return _buildFallbackInitials();
              },
            ),
          );
        } catch (_) {
          return _buildFallbackInitials();
        }
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _hasImageError = true);
            });
            return _buildFallbackInitials();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: size,
              height: size,
              color: AppColors.surfaceStone,
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        ),
      );
    }

    return _buildFallbackInitials();
  }

  Widget _buildFallbackInitials() {
    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getInitials(widget.name),
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.radius * 0.65,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ringBorderColor = isDark ? AppColors.darkBorderSubtle : AppColors.surfaceElevated;
    final badgeBorderColor = isDark ? AppColors.darkBgCard : Colors.white;
    final badgeBgColor = isDark ? AppColors.darkBgInput : AppColors.primary;
    final badgeIconColor = isDark ? AppColors.darkTextPrimary : Colors.white;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: widget.editable
                ? (_isUploading ? null : _showImageOptions)
                : widget.onTap,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ringBorderColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildAvatarContent(),
                  if (_isUploading)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (widget.editable)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isUploading ? null : _showImageOptions,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: badgeBorderColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: badgeIconColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
