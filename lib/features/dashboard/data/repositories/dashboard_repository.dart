import 'package:dio/dio.dart';
import 'package:taskflow_flutter/core/constants/api_endpoints.dart';
import 'package:taskflow_flutter/core/network/dio_client.dart';
import 'package:taskflow_flutter/features/dashboard/data/models/dashboard_stats.dart';

class DashboardRepository {
  final DioClient _dioClient;

  DashboardRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Dio get _dio => _dioClient.dio;

  Future<AdminDashboardStats> getAdminDashboardStats() async {
    try {
      final dashboardFuture = _dio.get(ApiEndpoints.adminDashboard);
      final leavesFuture = _dio.get(
        ApiEndpoints.leaves,
        queryParameters: {'status': 'Pending', 'limit': 1},
      ).catchError((_) => Response(
        requestOptions: RequestOptions(path: ApiEndpoints.leaves),
        data: {'total': 0},
      ));

      final results = await Future.wait([dashboardFuture, leavesFuture]);
      final dashboardResponse = results[0];
      final leavesResponse = results[1];

      final dashboardData = Map<String, dynamic>.from(dashboardResponse.data as Map);

      int pendingLeavesCount = 0;
      if (leavesResponse.data is Map<String, dynamic>) {
        final leavesData = leavesResponse.data as Map<String, dynamic>;
        pendingLeavesCount = int.tryParse(leavesData['total']?.toString() ?? '0') ?? 0;
      } else if (leavesResponse.data is List) {
        pendingLeavesCount = (leavesResponse.data as List).length;
      }

      dashboardData['pendingLeaves'] = pendingLeavesCount;

      return AdminDashboardStats.fromJson(dashboardData);
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  Future<EmployeeDashboardStats> getEmployeeDashboardStats() async {
    try {
      final response = await _dio.get(ApiEndpoints.employeeDashboard);
      return EmployeeDashboardStats.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }
}
