import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';

enum TaskStatus { pending, inProgress, review, completed, blocked }

enum TaskPriority { low, medium, high }

extension TaskStatusX on TaskStatus {
  String get value {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.review:
        return 'Review';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.blocked:
        return 'Blocked';
    }
  }

  static TaskStatus fromString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'in progress':
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'review':
        return TaskStatus.review;
      case 'completed':
        return TaskStatus.completed;
      case 'blocked':
        return TaskStatus.blocked;
      case 'pending':
      default:
        return TaskStatus.pending;
    }
  }
}

extension TaskPriorityX on TaskPriority {
  String get value {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  static TaskPriority fromString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }
}

class TaskComment {
  final String? id;
  final UserProfile? user;
  final String? userId;
  final String text;
  final DateTime createdAt;

  TaskComment({
    this.id,
    this.user,
    this.userId,
    required this.text,
    required this.createdAt,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    UserProfile? userProfile;
    String? rawUserId;
    if (json['user'] is Map<String, dynamic>) {
      userProfile = UserProfile.fromJson(json['user']);
    } else if (json['user'] != null) {
      rawUserId = json['user'].toString();
    }

    return TaskComment(
      id: json['_id']?.toString(),
      user: userProfile,
      userId: rawUserId,
      text: json['text']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (user != null) 'user': user!.toJson() else if (userId != null) 'user': userId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String dueDate;
  final String category;
  final List<String> tags;
  final num estimatedTime;
  final int progress;
  final List<TaskComment> comments;
  final List<String> attachments;
  final UserProfile? assignedUser;
  final String? assignedUserId;
  final UserProfile? createdByUser;
  final String? createdByUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    this.category = 'General',
    this.tags = const [],
    this.estimatedTime = 0,
    this.progress = 0,
    this.comments = const [],
    this.attachments = const [],
    this.assignedUser,
    this.assignedUserId,
    this.createdByUser,
    this.createdByUserId,
    this.createdAt,
    this.updatedAt,
  });

  String get assignedToName {
    if (assignedUser != null) {
      return assignedUser!.fullName;
    }
    return 'Unassigned';
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    UserProfile? assignedUser;
    String? assignedUserId;
    if (json['assignedTo'] is Map<String, dynamic>) {
      assignedUser = UserProfile.fromJson(json['assignedTo']);
    } else if (json['assignedTo'] != null) {
      assignedUserId = json['assignedTo'].toString();
    }

    UserProfile? createdByUser;
    String? createdByUserId;
    if (json['createdBy'] is Map<String, dynamic>) {
      createdByUser = UserProfile.fromJson(json['createdBy']);
    } else if (json['createdBy'] != null) {
      createdByUserId = json['createdBy'].toString();
    }

    final commentsList = <TaskComment>[];
    if (json['comments'] is List) {
      for (final c in json['comments']) {
        if (c is Map<String, dynamic>) {
          commentsList.add(TaskComment.fromJson(c));
        }
      }
    }

    final tagsList = <String>[];
    if (json['tags'] is List) {
      for (final t in json['tags']) {
        tagsList.add(t.toString());
      }
    }

    final attachmentsList = <String>[];
    if (json['attachments'] is List) {
      for (final a in json['attachments']) {
        attachmentsList.add(a.toString());
      }
    }

    return TaskModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: TaskStatusX.fromString(json['status']?.toString()),
      priority: TaskPriorityX.fromString(json['priority']?.toString()),
      dueDate: json['dueDate']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      tags: tagsList,
      estimatedTime: json['estimatedTime'] is num ? json['estimatedTime'] : 0,
      progress: json['progress'] is int ? json['progress'] : int.tryParse(json['progress']?.toString() ?? '0') ?? 0,
      comments: commentsList,
      attachments: attachmentsList,
      assignedUser: assignedUser,
      assignedUserId: assignedUserId,
      createdByUser: createdByUser,
      createdByUserId: createdByUserId,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'status': status.value,
      'priority': priority.value,
      'dueDate': dueDate,
      'category': category,
      'tags': tags,
      'estimatedTime': estimatedTime,
      'progress': progress,
      'comments': comments.map((c) => c.toJson()).toList(),
      'attachments': attachments,
      'assignedTo': assignedUser != null ? assignedUser!.toJson() : assignedUserId,
      'createdBy': createdByUser != null ? createdByUser!.toJson() : createdByUserId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? dueDate,
    String? category,
    List<String>? tags,
    num? estimatedTime,
    int? progress,
    List<TaskComment>? comments,
    UserProfile? assignedUser,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      progress: progress ?? this.progress,
      comments: comments ?? this.comments,
      attachments: attachments,
      assignedUser: assignedUser ?? this.assignedUser,
      assignedUserId: assignedUserId,
      createdByUser: createdByUser,
      createdByUserId: createdByUserId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
