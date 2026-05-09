class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!re.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Include at least one uppercase letter';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Include at least one number';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final re = RegExp(r'^\+?[0-9]{10,13}$');
    if (!re.hasMatch(value.replaceAll(' ', ''))) return 'Enter a valid phone number';
    return null;
  }

  static String? quantity(String? value) {
    if (value == null || value.trim().isEmpty) return 'Quantity is required';
    final n = int.tryParse(value);
    if (n == null || n <= 0) return 'Enter a valid quantity greater than 0';
    return null;
  }

  static String? sanitise(String? value) {
    if (value == null) return null;
    return value
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .trim();
  }
}
