class SettingKeys {
  static const googleVersion = 'USER_APP_GOOGLE_PLAY_VERSION';
  static const urgentAndroid = 'USER_APP_ANDROID_URGENT_UPDATE';
  static const appStoreVersion = 'USER_APP_STORE_VERSION';
  static const urgentIos = 'USER_APP_IOS_URGENT_UPDATE';
  static const googleLink = 'USER_APP_GOOGLE_PLAY_LINK';
  static const iosLink = 'USER_APP_APP_STORE_LINK';
}

/// Validation constants for form inputs and data validation
class ValidationConstants {
  // Password validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;

  // OTP validation
  static const int otpLength = 4;

  // Phone number validation
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;

  // Name validation
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Email validation
  static const int maxEmailLength = 100;

  // Regular expressions for validation
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp phoneRegex = RegExp(
    r'^\+?[1-9]\d{1,14}$',
  );

  static final RegExp nameRegex = RegExp(
    r'^[a-zA-ZÀ-ÿ\u00C0-\u017F\u0100-\u024F\u1E00-\u1EFF\s]+$',
  );

  // Password strength requirements
  static final RegExp passwordUpperCase = RegExp(r'[A-Z]');
  static final RegExp passwordLowerCase = RegExp(r'[a-z]');
  static final RegExp passwordDigit = RegExp(r'\d');
  static final RegExp passwordSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
}
