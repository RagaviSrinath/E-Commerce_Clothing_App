import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthLocalDataSource {
  Future<UserEntity> login({required String email, required String password});

  Future<void> logout();

  Future<UserEntity?> getCurrentUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserName = 'auth_user_name';
  static const String _keyUserEmail = 'auth_user_email';

  UserEntity? _currentUser;

  // Predefined dummy credentials as required by the specification
  static const Map<String, Map<String, String>> _dummyUsers = {
    'user@nextgen.com': {
      'password': 'Password123',
      'id': 'usr_001',
      'name': 'Aarav Sharma',
    },
  };

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    // Simulate real-world network latency
    await Future.delayed(const Duration(milliseconds: 700));

    final normalizedEmail = email.trim().toLowerCase();
    final userRecord = _dummyUsers[normalizedEmail];

    // If predefined demo user is used, validate password
    if (userRecord != null && userRecord['password'] != password) {
      throw const AuthFailure(
        'Invalid email or password. Please check your credentials.',
      );
    }

    final UserEntity user;
    if (userRecord != null) {
      user = UserEntity(
        id: userRecord['id']!,
        name: userRecord['name']!,
        email: normalizedEmail,
      );
    } else {
      // Dynamic user creation for any valid email
      final localPart = normalizedEmail.split('@').first;
      final words = localPart.split(RegExp(r'[._-]'));
      final formattedName = words
          .where((w) => w.isNotEmpty)
          .map(
            (w) => '${w[0].toUpperCase()}${w.length > 1 ? w.substring(1) : ''}',
          )
          .join(' ');

      final displayName = formattedName.isNotEmpty ? formattedName : 'Customer';
      user = UserEntity(
        id: 'usr_${(normalizedEmail.hashCode.abs() % 9000) + 1000}',
        name: displayName,
        email: normalizedEmail,
      );
    }

    _currentUser = user;

    // Persist login session locally in SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, user.id);
      await prefs.setString(_keyUserName, user.name);
      await prefs.setString(_keyUserEmail, user.email);
    } catch (_) {
      // Graceful fallback to in-memory session if SharedPreferences is unavailable
    }

    return user;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyUserEmail);
    } catch (_) {
      // Graceful fallback
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_keyUserId);
      final name = prefs.getString(_keyUserName);
      final email = prefs.getString(_keyUserEmail);

      if (id != null && name != null && email != null) {
        _currentUser = UserEntity(id: id, name: name, email: email);
        return _currentUser;
      }
    } catch (_) {
      // Graceful fallback
    }

    return null;
  }
}
