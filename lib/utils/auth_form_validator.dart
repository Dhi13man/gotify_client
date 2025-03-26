/// Form validator for authentication
class AuthFormValidator {
  static String? validateServerUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter server URL';
    }
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      return 'URL must start with http:// or https://';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter username';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    return null;
  }

  static String? validateToken(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter client token';
    }
    return null;
  }
}
