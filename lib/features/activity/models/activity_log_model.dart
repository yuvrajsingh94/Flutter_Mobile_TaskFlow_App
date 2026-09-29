import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';

class ActivityLogModel {
  final String id;
  final UserProfile? user;
  final String? userId;
  final String action;
  final String description;
  final DateTime createdAt;

  ActivityLogModel({
    required this.id,
    this.user,
    this.userId,
    required this.action,
    required this.description,
    required this.createdAt,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    UserProfile? userProfile;
    String? rawUserId;
    if (json['user'] is Map<String, dynamic>) {
      userProfile = UserProfile.fromJson(json['user']);
    } else if (json['user'] != null) {
      rawUserId = json['user'].toString();
    }

    return ActivityLogModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      user: userProfile,
      userId: rawUserId,
      action: json['action']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
