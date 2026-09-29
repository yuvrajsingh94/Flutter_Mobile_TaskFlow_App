import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/notifications/data/repositories/notification_repository.dart';
import 'package:taskflow_flutter/features/notifications/data/models/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NotificationRepository(dioClient: dioClient);
});

class NotificationListState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? errorMessage;

  NotificationListState({
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationListState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationListState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationListState> {
  final NotificationRepository _repository;

  NotificationsNotifier({required NotificationRepository repository})
      : _repository = repository,
        super(NotificationListState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getNotifications();
      state = state.copyWith(notifications: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> markAllRead() async {
    try {
      await _repository.markAllRead();
      state = state.copyWith(
        notifications: state.notifications.map((n) {
          return NotificationModel(
            id: n.id,
            title: n.title,
            message: n.message,
            type: n.type,
            taskId: n.taskId,
            taskTitle: n.taskTitle,
            senderName: n.senderName,
            isRead: true,
            isArchived: n.isArchived,
            createdAt: n.createdAt,
          );
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> clearAll() async {
    try {
      await _repository.clearAll();
      state = state.copyWith(notifications: []);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final notificationsNotifierProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationListState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationsNotifier(repository: repository);
});
