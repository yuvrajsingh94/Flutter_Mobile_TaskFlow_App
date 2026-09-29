import 'package:taskflow_flutter/core/config/api_config.dart';

class ApiEndpoints {
  // Auth endpoints
  static String get login => '${ApiConfig.baseUrl}/login';
  static String get register => '${ApiConfig.baseUrl}/register';
  static String get logout => '${ApiConfig.baseUrl}/logout';
  static String get refresh => '${ApiConfig.baseUrl}/refresh';
  static String get me => '${ApiConfig.baseUrl}/me';
  static String get users => '${ApiConfig.baseUrl}/users';

  // OTP & Password Reset
  static String get sendEmailOtp => '${ApiConfig.baseUrl}/send-email-otp';
  static String get verifyEmailOtpPublic => '${ApiConfig.baseUrl}/verify-email-otp-public';
  static String get sendPhoneOtpPublic => '${ApiConfig.baseUrl}/send-phone-otp-public';
  static String get forgotPasswordOtp => '${ApiConfig.baseUrl}/forgot-password-otp';
  static String get verifyForgotPasswordOtp => '${ApiConfig.baseUrl}/verify-forgot-password-otp';
  static String get resetPassword => '${ApiConfig.baseUrl}/reset-password';

  // Tasks
  static String get tasks => '${ApiConfig.baseUrl}/tasks';
  static String taskById(String id) => '${ApiConfig.baseUrl}/tasks/$id';
  static String taskStatus(String id) => '${ApiConfig.baseUrl}/tasks/$id/status';
  static String taskProgress(String id) => '${ApiConfig.baseUrl}/tasks/$id/progress';
  static String taskAssign(String id) => '${ApiConfig.baseUrl}/tasks/$id/assign';
  static String taskPriority(String id) => '${ApiConfig.baseUrl}/tasks/$id/priority';

  // Employees & Profile
  static String get employees => '${ApiConfig.baseUrl}/employees';
  static String get archivedEmployees => '${ApiConfig.baseUrl}/employees/archived';
  static String employeeById(String id) => '${ApiConfig.baseUrl}/employees/$id';
  static String blockEmployee(String id) => '${ApiConfig.baseUrl}/employees/$id/block';
  static String unblockEmployee(String id) => '${ApiConfig.baseUrl}/employees/$id/unblock';
  static String restoreEmployee(String id) => '${ApiConfig.baseUrl}/employees/$id/restore';
  static String employeeTasks(String id) => '${ApiConfig.baseUrl}/employees/$id/tasks';

  static String get myProfile => '${ApiConfig.baseUrl}/employees/profile';
  static String get changeTempPassword => '${ApiConfig.baseUrl}/employees/change-temporary-password';
  static String get sendVerificationEmail => '${ApiConfig.baseUrl}/employees/send-verification-email';
  static String get verifyEmail => '${ApiConfig.baseUrl}/employees/verify-email';
  static String get sendPhoneOtp => '${ApiConfig.baseUrl}/employees/send-phone-otp';
  static String get verifyPhoneOtp => '${ApiConfig.baseUrl}/employees/verify-phone-otp';
  static String get deleteAccount => '${ApiConfig.baseUrl}/employees/me';

  // Dashboard
  static String get adminDashboard => '${ApiConfig.baseUrl}/dashboard/admin';
  static String get employeeDashboard => '${ApiConfig.baseUrl}/dashboard/employee';

  // Notifications
  static String get notifications => '${ApiConfig.baseUrl}/notifications';
  static String get markAllNotificationsRead => '${ApiConfig.baseUrl}/notifications/read-all';
  static String get clearAllNotifications => '${ApiConfig.baseUrl}/notifications/clear-all';
  static String markNotificationRead(String id) => '${ApiConfig.baseUrl}/notifications/$id/read';
  static String archiveNotification(String id) => '${ApiConfig.baseUrl}/notifications/$id/archive';
  static String notificationById(String id) => '${ApiConfig.baseUrl}/notifications/$id';

  // Leaves
  static String get leaves => '${ApiConfig.baseUrl}/leaves';
  static String leaveById(String id) => '${ApiConfig.baseUrl}/leaves/$id';
  static String cancelLeave(String id) => '${ApiConfig.baseUrl}/leaves/$id/cancel';
  static String leaveStatus(String id) => '${ApiConfig.baseUrl}/leaves/$id/status';

  // Activity Logs
  static String get activity => '${ApiConfig.baseUrl}/activity';
}
