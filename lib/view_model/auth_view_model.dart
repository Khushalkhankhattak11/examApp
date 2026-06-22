// lib/view_model/auth_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const/const.dart';
import '../model/model.dart';
import '../repository/auth_repository.dart';
import '../repository/onboarding_repository.dart';
import 'providers.dart';

// ───────────────── STATE ─────────────────
class AuthState {
  final String email;
  final String password;
  final String displayName;

  final bool isLoading;
  final String? errorMessage;

  final UserModel? user;
  final bool onboardingDone;

  final bool isPasswordVisible;
  final bool termsAccepted;

  const AuthState({
    this.email = '',
    this.password = '',
    this.displayName = '',
    this.isLoading = false,
    this.errorMessage,
    this.user,
    this.onboardingDone = false,
    this.isPasswordVisible = false,
    this.termsAccepted = false,
  });

  bool get canRegister =>
      email.trim().isNotEmpty && password.isNotEmpty && termsAccepted;

  AuthState copyWith({
    String? email,
    String? password,
    String? displayName,
    bool? isLoading,
    String? errorMessage,
    UserModel? user,
    bool? onboardingDone,
    bool? isPasswordVisible,
    bool? termsAccepted,
    bool clearError = false,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }
}

// ───────────────── PROVIDER ─────────────────
final authViewModelProvider =
    StateNotifierProvider.autoDispose<AuthViewModel, AuthState>((ref) {
      return AuthViewModel(ref);
    });

class AuthViewModel extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthViewModel(this._ref) : super(const AuthState());

  IAuthRepository get _auth => _ref.read(authRepositoryProvider);

  // FIX: reads the SAME singleton instance that onboardingProvider uses,
  // so loadLocal() inside pushToFirebase() finds the data saveLocally() wrote.
  IOnboardingRepository get _onboarding =>
      _ref.read(onboardingRepositoryProvider);

  // ───────── INPUT HANDLERS ─────────
  void onEmailChanged(String v) =>
      _update((s) => s.copyWith(email: v, clearError: true));

  void onPasswordChanged(String v) =>
      _update((s) => s.copyWith(password: v, clearError: true));

  void onDisplayNameChanged(String v) =>
      _update((s) => s.copyWith(displayName: v, clearError: true));

  void togglePasswordVisibility() =>
      _update((s) => s.copyWith(isPasswordVisible: !s.isPasswordVisible));

  void toggleTermsAccepted(bool? value) =>
      _update((s) => s.copyWith(termsAccepted: value ?? false));

  // ───────── SIGN IN ─────────
  Future<bool> signIn() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _auth.signIn(
      email: state.email.trim(),
      password: state.password,
    );

    if (result is Failure<UserModel>) {
      state = state.copyWith(isLoading: false, errorMessage: result.message);
      return false;
    }

    final user = (result as Success<UserModel>).data;
    final done = await _onboarding.isCompleted(user.uid);

    state = state.copyWith(isLoading: false, user: user, onboardingDone: done);
    return true;
  }

  // ───────── REGISTER ─────────
  Future<bool> register() async {
    if (!state.canRegister) {
      state = state.copyWith(
        errorMessage: 'Complete email, password and accept the terms',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final onboardingData = await _onboarding.loadLocal();
    final displayName = onboardingData?.fullName.trim().isNotEmpty == true
        ? onboardingData!.fullName.trim()
        : state.displayName.trim();

    if (displayName.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Full name is missing from profile setup',
      );
      return false;
    }

    // ── 1. Create Firebase Auth account ──────────────────────────────────
    final result = await _auth.register(
      email: state.email.trim(),
      password: state.password,
      displayName: displayName,
    );

    if (result is Failure<UserModel>) {
      state = state.copyWith(isLoading: false, errorMessage: result.message);
      return false;
    }

    final user = (result as Success<UserModel>).data;

    // ── 2. Push locally-saved onboarding data to Firestore ────────────────
    // loadLocal() reads SharedPreferences key 'onboarding_data' written by
    // saveLocally() during the onboarding steps. Because both providers now
    // share the same OnboardingRepository instance this is guaranteed to find
    // the data.
    final pushResult = await _onboarding.pushToFirebase(user.uid);

    if (!pushResult.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: pushResult.errorOrNull ?? 'Failed to save onboarding',
      );
      return false;
    }

    if (kDebugMode) {
      final localCheck = await _onboarding.loadLocal();
      debugPrint(
        '[AuthVM] localData after push: $localCheck',
      ); // should be null (cleared)
      debugPrint('[AuthVM] pushToFirebase success: ${pushResult.isSuccess}');
    }

    // ── 3. Set SharedPreferences flag ────────────────────────────────────
    // Splash screen reads this to skip onboarding on subsequent cold starts.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.kOnboarded, true);

    if (!mounted) return false;

    state = state.copyWith(isLoading: false, user: user, onboardingDone: true);

    return true;
  }

  // ───────── LOGOUT ─────────
  Future<void> signOut() async {
    await _auth.signOut();
    state = const AuthState();
  }

  // ───────── DELETE ACCOUNT ─────────
  Future<bool> deleteAccount(String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _auth.deleteAccount(password: password);

    if (result is Failure<void>) {
      state = state.copyWith(isLoading: false, errorMessage: result.message);
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.kOnboarded);
    state = const AuthState();
    return true;
  }

  // ───────── INTERNAL UPDATE ─────────
  void _update(AuthState Function(AuthState) fn) {
    if (!mounted) return;
    state = fn(state);
  }
}
