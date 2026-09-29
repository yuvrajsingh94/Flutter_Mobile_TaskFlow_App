import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:taskflow_flutter/features/dashboard/data/models/dashboard_stats.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DashboardRepository(dioClient: dioClient);
});

final adminStatsProvider = FutureProvider.autoDispose<AdminDashboardStats>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return await repo.getAdminDashboardStats();
});

final employeeStatsProvider = FutureProvider.autoDispose<EmployeeDashboardStats>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return await repo.getEmployeeDashboardStats();
});
