// lib/model/onboarding_model.dart

class OnboardingModel {
  final String selectedExam;
  final String fullName;
  final String age;
  final String city;
  final String educationLevel; // ← NEW
  final String educationSubject; // ← NEW
  final String academicStatus; // ← NEW  ('studying' | 'graduated')

  const OnboardingModel({
    this.selectedExam = '',
    this.fullName = '',
    this.age = '',
    this.city = '',
    this.educationLevel = '',
    this.educationSubject = '',
    this.academicStatus = '',
  });

  factory OnboardingModel.fromMap(Map<String, dynamic> map) => OnboardingModel(
    selectedExam: map['selectedExam'] as String? ?? '',
    fullName: map['fullName'] as String? ?? '',
    age: map['age'] as String? ?? '',
    city: map['city'] as String? ?? '',
    educationLevel: map['educationLevel'] as String? ?? '',
    educationSubject: map['educationSubject'] as String? ?? '',
    academicStatus: map['academicStatus'] as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    'selectedExam': selectedExam,
    'fullName': fullName,
    'age': age,
    'city': city,
    'educationLevel': educationLevel,
    'educationSubject': educationSubject,
    'academicStatus': academicStatus,
  };

  OnboardingModel copyWith({
    String? selectedExam,
    String? fullName,
    String? age,
    String? city,
    String? educationLevel,
    String? educationSubject,
    String? academicStatus,
  }) => OnboardingModel(
    selectedExam: selectedExam ?? this.selectedExam,
    fullName: fullName ?? this.fullName,
    age: age ?? this.age,
    city: city ?? this.city,
    educationLevel: educationLevel ?? this.educationLevel,
    educationSubject: educationSubject ?? this.educationSubject,
    academicStatus: academicStatus ?? this.academicStatus,
  );
}
