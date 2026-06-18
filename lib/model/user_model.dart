// lib/model/user_model.dart

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final bool onboardingCompleted;

  // Onboarding fields (merged from Firestore)
  final String selectedExam;
  final String fullName;
  final String age;
  final String city;
  final String educationLevel;
  final String educationSubject;

  // Stats fields (written by quiz engine, read here)
  final int testsTaken;
  final int streakDays;
  final int bestScore; // 0–100
  final int totalSolved;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    DateTime? createdAt,
    this.onboardingCompleted = false,
    this.selectedExam = '',
    this.fullName = '',
    this.age = '',
    this.city = '',
    this.educationLevel = '',
    this.educationSubject = '',
    this.testsTaken = 0,
    this.streakDays = 0,
    this.bestScore = 0,
    this.totalSolved = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  // ── Firestore serialization ────────────────────
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'User',
      photoUrl: map['photoUrl'] as String?,
      createdAt: _dateTimeFromValue(map['createdAt']),
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
      selectedExam: map['selectedExam'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      age: map['age'] as String? ?? '',
      city: map['city'] as String? ?? '',
      educationLevel: map['educationLevel'] as String? ?? '',
      educationSubject: map['educationSubject'] as String? ?? '',
      testsTaken: (map['testsTaken'] as num?)?.toInt() ?? 0,
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 0,
      bestScore: (map['bestScore'] as num?)?.toInt() ?? 0,
      totalSolved: (map['totalSolved'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'createdAt': createdAt.toIso8601String(),
    'onboardingCompleted': onboardingCompleted,
    'selectedExam': selectedExam,
    'fullName': fullName,
    'age': age,
    'city': city,
    'educationLevel': educationLevel,
    'educationSubject': educationSubject,
    'testsTaken': testsTaken,
    'streakDays': streakDays,
    'bestScore': bestScore,
    'totalSolved': totalSolved,
  };

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    bool? onboardingCompleted,
    String? selectedExam,
    String? fullName,
    String? age,
    String? city,
    String? educationLevel,
    String? educationSubject,
    int? testsTaken,
    int? streakDays,
    int? bestScore,
    int? totalSolved,
  }) => UserModel(
    uid: uid ?? this.uid,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    photoUrl: photoUrl ?? this.photoUrl,
    createdAt: createdAt ?? this.createdAt,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    selectedExam: selectedExam ?? this.selectedExam,
    fullName: fullName ?? this.fullName,
    age: age ?? this.age,
    city: city ?? this.city,
    educationLevel: educationLevel ?? this.educationLevel,
    educationSubject: educationSubject ?? this.educationSubject,
    testsTaken: testsTaken ?? this.testsTaken,
    streakDays: streakDays ?? this.streakDays,
    bestScore: bestScore ?? this.bestScore,
    totalSolved: totalSolved ?? this.totalSolved,
  );

  // Get initials for avatar from fullName or displayName
  String get initials {
    final name = fullName.isNotEmpty ? fullName : displayName;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserModel && uid == other.uid);

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() =>
      'UserModel(uid: $uid, email: $email, name: $displayName, onboarding: $onboardingCompleted, exam: $selectedExam)';

  static DateTime? _dateTimeFromValue(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);

    try {
      final converted = (value as dynamic).toDate();
      if (converted is DateTime) return converted;
    } catch (_) {
      return null;
    }

    return null;
  }
}
