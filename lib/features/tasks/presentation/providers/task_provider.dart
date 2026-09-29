import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/tasks/data/repositories/task_repository.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TaskRepository(dioClient: dioClient);
});

class TaskListState {
  final List<TaskModel> tasks;
  final bool isLoading;
  final String? errorMessage;
  final String activeFilter; // 'All', 'Pending', 'In Progress', 'Completed', etc.
  final String searchQuery;

  TaskListState({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.activeFilter = 'All',
    this.searchQuery = '',
  });

  TaskListState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    String? errorMessage,
    String? activeFilter,
    String? searchQuery,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class TasksNotifier extends StateNotifier<TaskListState> {
  final TaskRepository _repository;

  TasksNotifier({required TaskRepository repository})
      : _repository = repository,
        super(TaskListState()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getTasks();
      state = state.copyWith(tasks: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> updateTaskStatus(String id, TaskStatus status) async {
    try {
      final updated = await _repository.updateTaskStatus(id, status);
      state = state.copyWith(
        tasks: state.tasks.map((t) => t.id == id ? updated : t).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateTaskProgress(String id, int progress) async {
    try {
      final updated = await _repository.updateTaskProgress(id, progress);
      state = state.copyWith(
        tasks: state.tasks.map((t) => t.id == id ? updated : t).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      await _repository.deleteTask(id);
      state = state.copyWith(
        tasks: state.tasks.where((t) => t.id != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> createTask({
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
      final newTask = await _repository.createTask(
        title: title,
        description: description,
        assignedTo: assignedTo,
        priority: priority,
        dueDate: dueDate,
        category: category,
        estimatedTime: estimatedTime,
        tags: tags,
      );
      state = state.copyWith(tasks: [newTask, ...state.tasks]);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateTaskDetails(String id, Map<String, dynamic> data) async {
    try {
      final updated = await _repository.updateTask(id, data);
      state = state.copyWith(
        tasks: state.tasks.map((t) => t.id == id ? updated : t).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final tasksNotifierProvider = StateNotifierProvider<TasksNotifier, TaskListState>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TasksNotifier(repository: repository);
});

final taskNotifierProvider = tasksNotifierProvider;

final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final state = ref.watch(tasksNotifierProvider);
  return state.tasks.where((task) {
    // Tab filter
    if (state.activeFilter == 'Pending' && task.status != TaskStatus.pending) {
      return false;
    }
    if (state.activeFilter == 'In Progress' && task.status != TaskStatus.inProgress) {
      return false;
    }
    if (state.activeFilter == 'Completed' && task.status != TaskStatus.completed) {
      return false;
    }

    // Search query filter
    if (state.searchQuery.trim().isNotEmpty) {
      final q = state.searchQuery.trim().toLowerCase();
      final titleMatch = task.title.toLowerCase().contains(q);
      final descMatch = task.description.toLowerCase().contains(q);
      final assigneeMatch = task.assignedToName.toLowerCase().contains(q);
      if (!titleMatch && !descMatch && !assigneeMatch) return false;
    }

    return true;
  }).toList();
});

final tasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTasks();
});

final myTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTasks();
});

