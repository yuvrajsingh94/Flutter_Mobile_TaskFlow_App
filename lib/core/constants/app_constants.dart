/// System-wide constants for TaskFlow Enterprise.
class AppConstants {
  AppConstants._();

  /// Default API pagination limit across queries
  static const int defaultPaginationLimit = 1000;

  /// Default network timeout durations
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Cooldown timer duration for OTP resends (seconds)
  static const int otpCooldownSeconds = 60;

  /// Validation constraints
  static const int minPasswordLength = 8;
  static const int minNameLength = 2;
  static const int maxNameLength = 30;
  static const int minTaskTitleLength = 3;
  static const int maxTaskTitleLength = 100;
  static const int maxTaskDescriptionLength = 1000;
  static const int minLeaveReasonLength = 5;

  /// Storage keys
  static const String keyAuthToken = 'taskflow_auth_token';
  static const String keyUserData = 'taskflow_user_data';
  static const String keyCustomApiUrl = 'taskflow_custom_api_url';
  static const String keyThemeMode = 'taskflow_theme_mode';
}
