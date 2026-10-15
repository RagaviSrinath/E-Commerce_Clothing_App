import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl(this.localDataSource);

  @override
  Future<UserEntity> login({required String email, required String password}) {
    return localDataSource.login(email: email, password: password);
  }

  @override
  Future<void> logout() {
    return localDataSource.logout();
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return localDataSource.getCurrentUser();
  }
}
