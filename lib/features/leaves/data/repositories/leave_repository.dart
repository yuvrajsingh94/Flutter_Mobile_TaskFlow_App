import 'package:dio/dio.dart';
import 'package:taskflow_flutter/core/constants/api_endpoints.dart';
import 'package:taskflow_flutter/core/network/dio_client.dart';
import 'package:taskflow_flutter/features/leaves/data/models/leave_model.dart';

class LeaveRepository {
  final DioClient _dioClient;

  LeaveRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Dio get _dio => _dioClient.dio;

  /// Fetches leaves (Admin gets all, Employee gets own)
  Future<List<LeaveModel>> getLeaves() async {
    try {
      final response = await _dio.get(ApiEndpoints.leaves);
      final raw = response.data;
      final leaves = <LeaveModel>[];

      if (raw is List) {
        for (final item in raw) {
          if (item is Map<String, dynamic>) {
            leaves.add(LeaveModel.fromJson(item));
          }
        }
      } else if (raw is Map<String, dynamic> && raw['leaves'] is List) {
        for (final item in raw['leaves']) {
          if (item is Map<String, dynamic>) {
            leaves.add(LeaveModel.fromJson(item));
          }
        }
      }

      return leaves;
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Apply for a leave
  Future<LeaveModel> applyLeave({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.leaves,
        data: {
          'leaveType': leaveType.value,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'reason': reason.trim(),
        },
      );

      return LeaveModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Cancel a pending leave (Employee)
  Future<LeaveModel> cancelLeave(String id) async {
    try {
      final response = await _dio.patch(ApiEndpoints.cancelLeave(id));
      return LeaveModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Update leave status (Admin: Approve or Reject)
  Future<LeaveModel> updateLeaveStatus({
    required String id,
    required String status, // 'Approved' | 'Rejected'
    String? rejectionReason,
  }) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.leaveStatus(id),
        data: {
          'status': status,
          if (rejectionReason != null) 'rejectionReason': rejectionReason,
        },
      );

      return LeaveModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }
}
