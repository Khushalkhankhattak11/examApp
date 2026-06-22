// lib/repository/auth_repository.dart

import '../data/remote/auth_remote_data_source.dart';
import '../model/model.dart';

abstract interface class IAuthRepository {
  Future<Result<UserModel>> signIn({
    required String email,
    required String password,
  });

  Future<Result<UserModel>> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Result<void>> signOut();

  Future<Result<void>> deleteAccount({required String password});

  Stream<bool> get isAuthenticated;
}

class AuthRepository implements IAuthRepository {
  final AuthRemoteDataSource _remote;

  AuthRepository({AuthRemoteDataSource? remote})
    : _remote = remote ?? AuthRemoteDataSource();

  @override
  Future<Result<UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remote.signIn(email: email, password: password);
      return Success(user);
    } catch (e) {
      return Failure(_mapError(e), error: e);
    }
  }

  @override
  Future<Result<UserModel>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = await _remote.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      return Success(user);
    } catch (e) {
      return Failure(_mapError(e), error: e);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remote.signOut();
      return const Success(null);
    } catch (e) {
      return Failure(_mapError(e), error: e);
    }
  }

  @override
  Future<Result<void>> deleteAccount({required String password}) async {
    try {
      await _remote.deleteAccount(password: password);
      return const Success(null);
    } catch (e) {
      return Failure(_mapError(e), error: e);
    }
  }

  @override
  Stream<bool> get isAuthenticated =>
      _remote.authStateChanges.map((u) => u != null);

  String _mapError(Object e) {
    final msg = e.toString();

    if (msg.contains('user-not-found')) return 'User not found';
    if (msg.contains('wrong-password')) return 'Wrong password';
    if (msg.contains('email-already')) return 'Email already exists';
    if (msg.contains('weak-password')) return 'Weak password';
    if (msg.contains('invalid-email')) return 'Invalid email';
    if (msg.contains('invalid-credential')) return 'Incorrect password';
    if (msg.contains('requires-recent-login')) {
      return 'Please sign in again before deleting your account';
    }

    return 'Something went wrong';
  }
}
