import 'package:dio/dio.dart';
import 'package:taskflow_flutter/core/constants/api_endpoints.dart';
import 'package:taskflow_flutter/core/network/dio_client.dart';
import 'package:taskflow_flutter/features/notifications/data/models/notification_model.dart';

class NotificationRepository {
  final DioClient _dioClient;

  NotificationRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Dio get _dio => _dioClient.dio;

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get(ApiEndpoints.notifications);
      final raw = response.data;
      final notifications = <NotificationModel>[];

      if (raw is List) {
        for (final item in raw) {
          if (item is Map<String, dynamic>) {
            notifications.add(NotificationModel.fromJson(item));
          }
        }
      } else if (raw is Map<String, dynamic> && raw['notifications'] is List) {
        for (final item in raw['notifications']) {
          if (item is Map<String, dynamic>) {
            notifications.add(NotificationModel.fromJson(item));
          }
        }
      }

      return notifications;
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.patch(ApiEndpoints.markAllNotificationsRead);
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  Future<void> clearAll() async {
    try {
      await _dio.delete(ApiEndpoints.clearAllNotifications);
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _dio.patch(ApiEndpoints.markNotificationRead(id));
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  Future<void> archive(String id) async {
    try {
      await _dio.patch(ApiEndpoints.archiveNotification(id));
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }
}
