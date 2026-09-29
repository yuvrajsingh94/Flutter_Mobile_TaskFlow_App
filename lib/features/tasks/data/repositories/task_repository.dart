import 'package:dio/dio.dart';
import 'package:taskflow_flutter/core/constants/api_endpoints.dart';
import 'package:taskflow_flutter/core/network/dio_client.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';

class TaskRepository {
  final DioClient _dioClient;

  TaskRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Dio get _dio => _dioClient.dio;

  /// Fetches tasks. Role filtering is enforced on backend by token.
  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await _dio.get(ApiEndpoints.tasks);
      final raw = response.data;
      final tasks = <TaskModel>[];

      if (raw is List) {
        for (final item in raw) {
          if (item is Map<String, dynamic>) {
            tasks.add(TaskModel.fromJson(item));
          }
        }
      } else if (raw is Map<String, dynamic> && raw['tasks'] is List) {
        for (final item in raw['tasks']) {
          if (item is Map<String, dynamic>) {
            tasks.add(TaskModel.fromJson(item));
          }
        }
      }

      return tasks;
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Creates a new task (Admin only)
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String assignedTo,
    required TaskPriority priority,
    required String dueDate,
    String category = 'General',
    num estimatedTime = 0,
    List<String> tags = const [],
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.tasks,
        data: {
          'title': title.trim(),
          'description': description.trim(),
          'assignedTo': assignedTo,
          'priority': priority.value,
          'dueDate': dueDate,
          'category': category,
          'estimatedTime': estimatedTime,
          'tags': tags,
        },
      );

      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Update task by ID
  Future<TaskModel> updateTask(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiEndpoints.taskById(id), data: data);
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Delete task by ID (Admin only)
  Future<void> deleteTask(String id) async {
    try {
      await _dio.delete(ApiEndpoints.taskById(id));
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Patch task status (Pending, In Progress, Review, Completed, Blocked)
  Future<TaskModel> updateTaskStatus(String id, TaskStatus status) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.taskStatus(id),
        data: {'status': status.value},
      );
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Patch task progress (0-100)
  Future<TaskModel> updateTaskProgress(String id, int progress) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.taskProgress(id),
        data: {'progress': progress},
      );
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }
}
