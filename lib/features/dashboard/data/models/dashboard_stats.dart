class AdminDashboardStats {
  final int totalEmployees;
  final int activeTasks;
  final int completedTasks;
  final int pendingReviews;
  final int pendingLeaves;
  final int overdueTasks;

  AdminDashboardStats({
    this.totalEmployees = 0,
    this.activeTasks = 0,
    this.completedTasks = 0,
    this.pendingReviews = 0,
    this.pendingLeaves = 0,
    this.overdueTasks = 0,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    final employeesMap = json['employees'] as Map<String, dynamic>?;
    final tasksMap = json['tasks'] as Map<String, dynamic>?;

    final totalEmployees = parseInt(
      employeesMap?['total'] ?? json['totalEmployees'] ?? json['totalUsers'],
    );

    int activeTasks = 0;
    if (json['activeTasks'] != null) {
      activeTasks = parseInt(json['activeTasks']);
    } else if (tasksMap != null) {
      final inProgress = parseInt(tasksMap['inProgress']);
      final pending = parseInt(tasksMap['pending']);
      final review = parseInt(tasksMap['review']);
      final blocked = parseInt(tasksMap['blocked']);
      activeTasks = inProgress + pending + review + blocked;
      if (activeTasks == 0 && tasksMap['total'] != null) {
        final total = parseInt(tasksMap['total']);
        final completed = parseInt(tasksMap['completed']);
        activeTasks = total - completed;
      }
    }

    final completedTasks = parseInt(
      tasksMap?['completed'] ?? json['completedTasks'],
    );

    final pendingReviews = parseInt(
      tasksMap?['review'] ?? json['pendingReviews'],
    );

    final overdueTasks = parseInt(
      tasksMap?['overdue'] ?? json['overdueTasks'],
    );

    final pendingLeaves = parseInt(json['pendingLeaves']);

    return AdminDashboardStats(
      totalEmployees: totalEmployees,
      activeTasks: activeTasks,
      completedTasks: completedTasks,
      pendingReviews: pendingReviews,
      pendingLeaves: pendingLeaves,
      overdueTasks: overdueTasks,
    );
  }
}

class EmployeeDashboardStats {
  final int myPendingTasks;
  final int myInProgressTasks;
  final int myCompletedTasks;
  final int casualLeaveBalance;
  final int sickLeaveBalance;
  final int earnedLeaveBalance;

  EmployeeDashboardStats({
    this.myPendingTasks = 0,
    this.myInProgressTasks = 0,
    this.myCompletedTasks = 0,
    this.casualLeaveBalance = 0,
    this.sickLeaveBalance = 0,
    this.earnedLeaveBalance = 0,
  });

  factory EmployeeDashboardStats.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    final statsMap = json['stats'] as Map<String, dynamic>?;
    final balanceMap = json['leaveBalance'] as Map<String, dynamic>?;

    return EmployeeDashboardStats(
      myPendingTasks: parseInt(json['myPendingTasks'] ?? statsMap?['pending']),
      myInProgressTasks: parseInt(json['myInProgressTasks'] ?? statsMap?['inProgress']),
      myCompletedTasks: parseInt(json['myCompletedTasks'] ?? statsMap?['completed']),
      casualLeaveBalance: parseInt(balanceMap?['casual']),
      sickLeaveBalance: parseInt(balanceMap?['sick']),
      earnedLeaveBalance: parseInt(balanceMap?['earned']),
    );
  }
}
