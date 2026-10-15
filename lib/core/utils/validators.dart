class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  static bool isValidEmail(String? email) {
    if (email == null) return false;
    final trimmed = email.trim();
    if (trimmed.isEmpty) return false;
    return _emailRegExp.hasMatch(trimmed);
  }

  static bool isValidPassword(String? password) {
    if (password == null) return false;
    return password.trim().length >= 4;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email address is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      return 'Password is required';
    }
    if (password.trim().length < 4) {
      return 'Password must be at least 4 characters';
    }
    return null;
  }
}
