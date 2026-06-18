// lib/view_model/onboarding_view_model.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/onboarding_model.dart';
import '../repository/onboarding_repository.dart';
import 'providers.dart';

// ── Provider ───────────────────────────────────
// FIX: pass `ref` into the notifier so it reads from the SAME
// onboardingRepositoryProvider instance that authViewModelProvider uses.
// Previously this did `OnboardingRepository()` which created a brand-new
// object — its loadLocal() always returned null when authVM called push.
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
      (ref) => OnboardingNotifier(
        repository: ref.read(onboardingRepositoryProvider),
      ),
    );

// ── State ──────────────────────────────────────
class OnboardingState {
  final int currentStep;
  final String selectedExam;
  final String fullName;
  final String age;
  final String city;
  final String educationLevel;
  final String educationSubject;
  final String academicStatus;
  final bool isLoading;
  final String? errorMessage;

  const OnboardingState({
    this.currentStep = 0,
    this.selectedExam = '',
    this.fullName = '',
    this.age = '',
    this.city = '',
    this.educationLevel = '',
    this.educationSubject = '',
    this.academicStatus = '',
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isStep1Valid => selectedExam.isNotEmpty;
  bool get isStep2Valid =>
      fullName.trim().isNotEmpty &&
      age.trim().isNotEmpty &&
      city.trim().isNotEmpty;
  bool get isStep3Valid =>
      educationLevel.isNotEmpty &&
      educationSubject.isNotEmpty &&
      academicStatus.isNotEmpty;

  OnboardingState copyWith({
    int? currentStep,
    String? selectedExam,
    String? fullName,
    String? age,
    String? city,
    String? educationLevel,
    String? educationSubject,
    String? academicStatus,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) => OnboardingState(
    currentStep: currentStep ?? this.currentStep,
    selectedExam: selectedExam ?? this.selectedExam,
    fullName: fullName ?? this.fullName,
    age: age ?? this.age,
    city: city ?? this.city,
    educationLevel: educationLevel ?? this.educationLevel,
    educationSubject: educationSubject ?? this.educationSubject,
    academicStatus: academicStatus ?? this.academicStatus,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  OnboardingModel toModel() => OnboardingModel(
    selectedExam: selectedExam,
    fullName: fullName,
    age: age,
    city: city,
    educationLevel: educationLevel,
    educationSubject: educationSubject,
    academicStatus: academicStatus,
  );
}

// ── Notifier ───────────────────────────────────
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final IOnboardingRepository _repository;

  OnboardingNotifier({required IOnboardingRepository repository})
    : _repository = repository,
      super(const OnboardingState());

  // ── Step 1 ────────────────────────────────────
  void selectExam(String exam) =>
      state = state.copyWith(selectedExam: exam, clearError: true);

  // ── Step 2 ────────────────────────────────────
  void onFullNameChanged(String v) => state = state.copyWith(fullName: v);
  void onAgeChanged(String v) => state = state.copyWith(age: v);
  void onCityChanged(String v) => state = state.copyWith(city: v);

  void updateProfile({
    required String fullName,
    required String age,
    required String city,
  }) => state = state.copyWith(fullName: fullName, age: age, city: city);

  // ── Step 3 ────────────────────────────────────
  void onEducationLevelChanged(String v) =>
      state = state.copyWith(educationLevel: v);
  void onEducationSubjectChanged(String v) =>
      state = state.copyWith(educationSubject: v);
  void onAcademicStatusChanged(String v) =>
      state = state.copyWith(academicStatus: v);

  void updateEducation({
    required String educationLevel,
    required String educationSubject,
    required String academicStatus,
  }) => state = state.copyWith(
    educationLevel: educationLevel,
    educationSubject: educationSubject,
    academicStatus: academicStatus,
  );

  // ── Navigation ────────────────────────────────
  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  // ── Persist locally ───────────────────────────
  Future<void> saveLocally() => _repository.saveLocally(state.toModel());

  // ── Push to Firebase + clear local ────────────
  Future<bool> pushToFirebase(String uid) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.pushToFirebase(uid);
    if (!mounted) return false;
    if (result.isSuccess) {
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorOrNull,
      );
      return false;
    }
  }
}
