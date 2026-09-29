enum UserRole { admin, employee }

/// Presentation extensions for [UserRole] providing consistent role names,
/// portal titles, and UI copy across the application.
extension UserRoleLabel on UserRole {
  /// User-friendly display title for the role (e.g. "Admin", "Employee").
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.employee:
        return 'Employee';
    }
  }

  /// Portal label associated with the role (e.g. "Admin Portal", "Employee Portal").
  String get portalLabel => '$displayName Portal';

  /// Preferences & tools subtitle used in More screen.
  String get preferencesSubtitle => '$displayName preferences & tools';

  /// Standard logout confirmation question for this role's portal.
  String get logoutConfirmationMessage =>
      'Are you sure you want to log out of the $portalLabel?';
}

/// Helper extension on nullable [UserRole] for safe copy formatting when the
/// user's role is unset or unknown.
extension UserRoleNullableLabel on UserRole? {
  /// Portal label or null if role is unset.
  String? get portalLabel => this?.portalLabel;

  /// Preferences & tools subtitle or default fallback.
  String get preferencesSubtitle =>
      this?.preferencesSubtitle ?? 'Preferences & tools';

  /// Role-aware logout confirmation message.
  /// Falls back to "Are you sure you want to log out?" if role is null.
  String get logoutConfirmationMessage {
    final portal = this?.portalLabel;
    if (portal != null && portal.isNotEmpty) {
      return 'Are you sure you want to log out of the $portal?';
    }
    return 'Are you sure you want to log out?';
  }
}

enum UserStatus { active, inactive, blocked }

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final UserRole role;
  final String phoneNumber;
  final String? countryCode;
  final String? dob;
  final String? gender;
  final String? qualification;
  final String? bio;
  final String? profilePicture;
  final String? coverPhoto;
  final String? department;
  final String? designation;
  final UserStatus status;
  final bool emailVerified;
  final bool phoneVerified;
  final bool firstLogin;
  final bool isBlocked;
  final String? blockReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.phoneNumber,
    this.countryCode,
    this.dob,
    this.gender,
    this.qualification,
    this.bio,
    this.profilePicture,
    this.coverPhoto,
    this.department,
    this.designation,
    this.status = UserStatus.active,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.firstLogin = false,
    this.isBlocked = false,
    this.blockReason,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  bool get isAdmin => role == UserRole.admin;
  bool get isEmployee => role == UserRole.employee;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Parse role
    UserRole role = UserRole.employee;
    final roleStr = json['role']?.toString().toLowerCase();
    if (roleStr == 'admin') {
      role = UserRole.admin;
    }

    // Parse status
    UserStatus status = UserStatus.active;
    final statusStr = json['status']?.toString().toUpperCase();
    if (statusStr == 'INACTIVE') {
      status = UserStatus.inactive;
    } else if (statusStr == 'BLOCKED') {
      status = UserStatus.blocked;
    }

    return UserProfile(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: role,
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      countryCode: json['countryCode']?.toString(),
      dob: json['dob']?.toString(),
      gender: json['gender']?.toString(),
      qualification: json['qualification']?.toString(),
      bio: json['bio']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
      coverPhoto: json['coverPhoto']?.toString(),
      department: json['department']?.toString(),
      designation: json['designation']?.toString(),
      status: status,
      emailVerified: json['emailVerified'] == true,
      phoneVerified: json['phoneVerified'] == true,
      firstLogin: json['firstLogin'] == true,
      isBlocked: json['isBlocked'] == true || status == UserStatus.blocked,
      blockReason: json['blockReason']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'employee',
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'dob': dob,
      'gender': gender,
      'qualification': qualification,
      'bio': bio,
      'profilePicture': profilePicture,
      'coverPhoto': coverPhoto,
      'department': department,
      'designation': designation,
      'status': status == UserStatus.blocked
          ? 'BLOCKED'
          : status == UserStatus.inactive
              ? 'INACTIVE'
              : 'ACTIVE',
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'firstLogin': firstLogin,
      'isBlocked': isBlocked,
      'blockReason': blockReason,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    UserRole? role,
    String? phoneNumber,
    String? countryCode,
    String? dob,
    String? gender,
    String? qualification,
    String? bio,
    String? profilePicture,
    String? coverPhoto,
    String? department,
    String? designation,
    UserStatus? status,
    bool? emailVerified,
    bool? phoneVerified,
    bool? firstLogin,
    bool? isBlocked,
    String? blockReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      qualification: qualification ?? this.qualification,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      status: status ?? this.status,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      firstLogin: firstLogin ?? this.firstLogin,
      isBlocked: isBlocked ?? this.isBlocked,
      blockReason: blockReason ?? this.blockReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
