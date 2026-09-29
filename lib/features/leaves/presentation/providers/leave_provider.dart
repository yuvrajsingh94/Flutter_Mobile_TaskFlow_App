import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/leaves/data/repositories/leave_repository.dart';
import 'package:taskflow_flutter/features/leaves/data/models/leave_model.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return LeaveRepository(dioClient: dioClient);
});

class LeaveListState {
  final List<LeaveModel> leaves;
  final bool isLoading;
  final String? errorMessage;
  final String activeFilter; // 'All', 'Pending', 'Approved', 'Rejected'

  LeaveListState({
    this.leaves = const [],
    this.isLoading = false,
    this.errorMessage,
    this.activeFilter = 'All',
  });

  LeaveListState copyWith({
    List<LeaveModel>? leaves,
    bool? isLoading,
    String? errorMessage,
    String? activeFilter,
  }) {
    return LeaveListState(
      leaves: leaves ?? this.leaves,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

class LeaveNotifier extends StateNotifier<LeaveListState> {
  final LeaveRepository _repository;

  LeaveNotifier({required LeaveRepository repository})
      : _repository = repository,
        super(LeaveListState()) {
    loadLeaves();
  }

  Future<void> loadLeaves() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getLeaves();
      state = state.copyWith(leaves: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  Future<bool> applyLeave({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    try {
      final newLeave = await _repository.applyLeave(
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );
      state = state.copyWith(leaves: [newLeave, ...state.leaves]);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> cancelLeave(String id) async {
    try {
      final updated = await _repository.cancelLeave(id);
      state = state.copyWith(
        leaves: state.leaves.map((l) => l.id == id ? updated : l).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateStatus(String id, String status, {String? reason}) async {
    try {
      final updated = await _repository.updateLeaveStatus(
        id: id,
        status: status,
        rejectionReason: reason,
      );
      state = state.copyWith(
        leaves: state.leaves.map((l) => l.id == id ? updated : l).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final leaveNotifierProvider = StateNotifierProvider<LeaveNotifier, LeaveListState>((ref) {
  final repository = ref.watch(leaveRepositoryProvider);
  return LeaveNotifier(repository: repository);
});

final filteredLeavesProvider = Provider<List<LeaveModel>>((ref) {
  final state = ref.watch(leaveNotifierProvider);
  if (state.activeFilter == 'Pending') {
    return state.leaves.where((l) => l.status == LeaveStatus.pending).toList();
  }
  if (state.activeFilter == 'Approved') {
    return state.leaves.where((l) => l.status == LeaveStatus.approved).toList();
  }
  if (state.activeFilter == 'Rejected') {
    return state.leaves.where((l) => l.status == LeaveStatus.rejected).toList();
  }
  return state.leaves;
});

final leavesProvider = FutureProvider<List<LeaveModel>>((ref) async {
  final repository = ref.watch(leaveRepositoryProvider);
  return repository.getLeaves();
});

final myLeavesProvider = FutureProvider<List<LeaveModel>>((ref) async {
  final repository = ref.watch(leaveRepositoryProvider);
  return repository.getLeaves();
});

