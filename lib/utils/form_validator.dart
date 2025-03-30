/// Form validator for authentication
class AppFormValidator {
  static String? validateServerUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter server URL';
    }
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      return 'URL must start with http:// or https://';
    }
    return null;
  }

  static String? validateNotEmpty(String? value) {
    if (value?.isEmpty ?? false) {
      return 'Please fill in this field';
    }
    return null;
  }
}
