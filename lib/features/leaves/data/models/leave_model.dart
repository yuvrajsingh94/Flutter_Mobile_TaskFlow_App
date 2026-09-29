import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';

enum LeaveType { casual, sick, earned, unpaid, maternity, paternity, compensatory }

enum LeaveStatus { pending, approved, rejected, cancelled }

extension LeaveTypeX on LeaveType {
  String get value {
    switch (this) {
      case LeaveType.casual:
        return 'Casual';
      case LeaveType.sick:
        return 'Sick';
      case LeaveType.earned:
        return 'Earned';
      case LeaveType.unpaid:
        return 'Unpaid';
      case LeaveType.maternity:
        return 'Maternity';
      case LeaveType.paternity:
        return 'Paternity';
      case LeaveType.compensatory:
        return 'Compensatory';
    }
  }

  static LeaveType fromString(String? str) {
    switch (str?.toLowerCase().trim()) {
      case 'sick':
        return LeaveType.sick;
      case 'earned':
        return LeaveType.earned;
      case 'unpaid':
        return LeaveType.unpaid;
      case 'maternity':
        return LeaveType.maternity;
      case 'paternity':
        return LeaveType.paternity;
      case 'compensatory':
        return LeaveType.compensatory;
      case 'casual':
      default:
        return LeaveType.casual;
    }
  }
}

extension LeaveStatusX on LeaveStatus {
  String get value {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.cancelled:
        return 'Cancelled';
    }
  }

  static LeaveStatus fromString(String? str) {
    switch (str?.toLowerCase().trim()) {
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      case 'cancelled':
        return LeaveStatus.cancelled;
      case 'pending':
      default:
        return LeaveStatus.pending;
    }
  }
}

class LeaveModel {
  final String id;
  final UserProfile? employee;
  final String? employeeId;
  final DateTime startDate;
  final DateTime endDate;
  final LeaveType leaveType;
  final String reason;
  final int totalDays;
  final LeaveStatus status;
  final UserProfile? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime? cancelledAt;
  final DateTime? createdAt;

  LeaveModel({
    required this.id,
    this.employee,
    this.employeeId,
    required this.startDate,
    required this.endDate,
    required this.leaveType,
    required this.reason,
    required this.totalDays,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.cancelledAt,
    this.createdAt,
  });

  String get employeeName {
    if (employee != null) {
      return employee!.fullName;
    }
    return 'Employee';
  }

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    UserProfile? employeeUser;
    String? employeeId;
    if (json['employee'] is Map<String, dynamic>) {
      employeeUser = UserProfile.fromJson(json['employee']);
    } else if (json['employee'] != null) {
      employeeId = json['employee'].toString();
    }

    UserProfile? approver;
    if (json['approvedBy'] is Map<String, dynamic>) {
      approver = UserProfile.fromJson(json['approvedBy']);
    }

    return LeaveModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      employee: employeeUser,
      employeeId: employeeId,
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime.now(),
      leaveType: LeaveTypeX.fromString(json['leaveType']?.toString()),
      reason: json['reason']?.toString() ?? '',
      totalDays: json['totalDays'] is int
          ? json['totalDays']
          : int.tryParse(json['totalDays']?.toString() ?? '1') ?? 1,
      status: LeaveStatusX.fromString(json['status']?.toString()),
      approvedBy: approver,
      approvedAt: json['approvedAt'] != null ? DateTime.tryParse(json['approvedAt'].toString()) : null,
      rejectionReason: json['rejectionReason']?.toString(),
      cancelledAt: json['cancelledAt'] != null ? DateTime.tryParse(json['cancelledAt'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'employee': employee != null ? employee!.toJson() : employeeId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'leaveType': leaveType.value,
      'reason': reason,
      'totalDays': totalDays,
      'status': status.value,
      'approvedBy': approvedBy?.toJson(),
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
