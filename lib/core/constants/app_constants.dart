class AppConstants {
  // App Info
  static const String appName = 'SafetyPro';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // API & URLs
  static const String apiBaseUrl = 'https://api.safetypro.com/v1';

  // Auth
  static const String dummyUsername = 'admin';
  static const String dummyPassword = 'admin123';

  // Features
  static const int alarmCheckIntervalSeconds = 60;
  static const int backgroundTaskInterval = 15;
  static const int locationUpdateIntervalSeconds = 30;
  static const int maxEmergencyContacts = 5;
  static const int maxIncidentsToStore = 100;

  // Notifications
  static const String notificationChannelId = 'safety_pro_alarms';
  static const String notificationChannelName = 'SafetyPro Alarms';
  static const String notificationChannelDescription =
      'Notifications for safety alarms and incidents';

  // Database
  static const String databaseName = 'safety_pro.db';
  static const int databaseVersion = 1;

  // Storage Keys
  static const String storageKeyUser = 'user_data';
  static const String storageKeyLastLocation = 'last_location';
  static const String storageKeyTheme = 'theme_mode';
  static const String storageKeyLanguage = 'language';
  static const String storageKeyIncidents = 'incidents';

  // Timing
  static const Duration sessionTimeout = Duration(minutes: 15);
  static const Duration apiRequestTimeout = Duration(seconds: 30);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Limits
  static const int maxLoginAttempts = 5;
  static const int passwordMinLength = 6;
  static const double locationAccuracyThreshold = 100.0; // meters

  // Error Messages
  static const String errorInvalidCredentials = 'Invalid credentials';
  static const String errorNetworkFailure = 'Network error. Please try again.';
  static const String errorLocationDenied = 'Location permission denied';
  static const String errorUnknown = 'An unexpected error occurred';
  static const String errorEmpty = 'This field cannot be empty';
}

class AppPaths {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String sos = '/sos';
  static const String camera = '/camera';
  static const String routine = '/routine';
  static const String profile = '/profile';
  static const String incidents = '/incidents';
  static const String settings = '/settings';
}
