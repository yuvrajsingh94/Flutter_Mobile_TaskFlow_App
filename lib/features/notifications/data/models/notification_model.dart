class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? taskId;
  final String? taskTitle;
  final String? senderName;
  final bool isRead;
  final bool isArchived;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.taskId,
    this.taskTitle,
    this.senderName,
    this.isRead = false,
    this.isArchived = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      taskId: json['taskId']?.toString(),
      taskTitle: json['taskTitle']?.toString(),
      senderName: json['senderName']?.toString(),
      isRead: json['isRead'] == true,
      isArchived: json['isArchived'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'message': message,
      'type': type,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'senderName': senderName,
      'isRead': isRead,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
