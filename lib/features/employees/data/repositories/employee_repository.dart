import 'package:dio/dio.dart';
import 'package:taskflow_flutter/core/constants/api_endpoints.dart';
import 'package:taskflow_flutter/core/network/dio_client.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';

class EmployeeRepository {
  final DioClient _dioClient;

  EmployeeRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Dio get _dio => _dioClient.dio;

  /// Get list of all active employees (Admin only)
  Future<List<UserProfile>> getEmployees() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.employees,
        queryParameters: {'limit': 1000},
      );
      final raw = response.data;
      final employees = <UserProfile>[];

      List<dynamic>? list;
      if (raw is List) {
        list = raw;
      } else if (raw is Map<String, dynamic>) {
        if (raw['employees'] is List) {
          list = raw['employees'] as List;
        } else if (raw['users'] is List) {
          list = raw['users'] as List;
        } else if (raw['data'] is List) {
          list = raw['data'] as List;
        }
      }

      if (list != null) {
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            employees.add(UserProfile.fromJson(item));
          }
        }
      }

      return employees;
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Block an employee (Admin only)
  Future<void> blockEmployee(String id, {String? reason}) async {
    try {
      await _dio.put(
        ApiEndpoints.blockEmployee(id),
        data: {'reason': reason ?? 'Blocked by admin'},
      );
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Unblock an employee (Admin only)
  Future<void> unblockEmployee(String id) async {
    try {
      await _dio.put(ApiEndpoints.unblockEmployee(id));
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Delete/Archive employee (Admin only)
  Future<void> deleteEmployee(String id) async {
    try {
      await _dio.delete(ApiEndpoints.employeeById(id));
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Add employee (Admin only)
  Future<UserProfile> addEmployee(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.employees, data: data);
      final raw = response.data;
      if (raw is Map<String, dynamic> && raw['employee'] != null) {
        return UserProfile.fromJson(raw['employee'] as Map<String, dynamic>);
      }
      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }

  /// Update current employee's profile
  Future<UserProfile> updateMyProfile(Map<String, dynamic> fields) async {
    try {
      final response = await _dio.put(ApiEndpoints.myProfile, data: fields);
      final data = response.data;
      if (data is Map<String, dynamic> && data['user'] != null) {
        return UserProfile.fromJson(data['user'] as Map<String, dynamic>);
      }
      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.extractErrorMessage(e);
    }
  }
}
