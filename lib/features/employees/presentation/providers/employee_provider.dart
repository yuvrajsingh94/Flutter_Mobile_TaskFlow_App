import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/employees/data/repositories/employee_repository.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return EmployeeRepository(dioClient: dioClient);
});

class EmployeeListState {
  final List<UserProfile> employees;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;

  EmployeeListState({
    this.employees = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  EmployeeListState copyWith({
    List<UserProfile>? employees,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
  }) {
    return EmployeeListState(
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class EmployeeNotifier extends StateNotifier<EmployeeListState> {
  final EmployeeRepository _repository;

  EmployeeNotifier({required EmployeeRepository repository})
      : _repository = repository,
        super(EmployeeListState()) {
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getEmployees();
      state = state.copyWith(employees: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> blockEmployee(String id, {String? reason}) async {
    try {
      await _repository.blockEmployee(id, reason: reason);
      await loadEmployees();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> unblockEmployee(String id) async {
    try {
      await _repository.unblockEmployee(id);
      await loadEmployees();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteEmployee(String id) async {
    try {
      await _repository.deleteEmployee(id);
      state = state.copyWith(
        employees: state.employees.where((e) => e.id != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> addEmployee(Map<String, dynamic> data) async {
    try {
      await _repository.addEmployee(data);
      await loadEmployees();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final employeeNotifierProvider = StateNotifierProvider<EmployeeNotifier, EmployeeListState>((ref) {
  final repository = ref.watch(employeeRepositoryProvider);
  return EmployeeNotifier(repository: repository);
});

final filteredEmployeesProvider = Provider<List<UserProfile>>((ref) {
  final state = ref.watch(employeeNotifierProvider);
  if (state.searchQuery.trim().isEmpty) return state.employees;

  final q = state.searchQuery.trim().toLowerCase();
  return state.employees.where((emp) {
    return emp.fullName.toLowerCase().contains(q) ||
        emp.email.toLowerCase().contains(q) ||
        (emp.department != null && emp.department!.toLowerCase().contains(q)) ||
        (emp.designation != null && emp.designation!.toLowerCase().contains(q));
  }).toList();
});
