class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String photoUrl;

  // Datos personales
  final double? height;
  final double? weight;
  final double? targetWeight;
  final String? biologicalSex;
  final String? experienceLevel;
  final String? goal;
  final String? injuries;
  final DateTime? birthDate;

  // Calculado automáticamente desde birthDate
  int? get age {
    if (birthDate == null) return null;
    final today = DateTime.now();
    int age = today.year - birthDate!.year;
    if (today.month < birthDate!.month ||
        (today.month == birthDate!.month && today.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl = '',
    this.height,
    this.weight,
    this.targetWeight,
    this.biologicalSex,
    this.experienceLevel,
    this.goal,
    this.injuries,
    this.birthDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'photoUrl': photoUrl,
      'height': height,
      'weight': weight,
      'targetWeight': targetWeight,
      'biologicalSex': biologicalSex,
      'experienceLevel': experienceLevel,
      'goal': goal,
      'injuries': injuries,
      'birthDate': birthDate?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      photoUrl: json['photoUrl'] ?? '',
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      targetWeight: json['targetWeight']?.toDouble(),
      biologicalSex: json['biologicalSex'],
      experienceLevel: json['experienceLevel'],
      goal: json['goal'],
      injuries: json['injuries'],
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
    );
  }

  UserProfile copyWith({
    String? name,
    String? photoUrl,
    int? age,
    double? height,
    double? weight,
    double? targetWeight,
    String? biologicalSex,
    String? experienceLevel,
    String? goal,
    String? injuries,
    DateTime? birthDate,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email,
      role: role,
      photoUrl: photoUrl ?? this.photoUrl,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      targetWeight: targetWeight ?? this.targetWeight,
      biologicalSex: biologicalSex ?? this.biologicalSex,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      goal: goal ?? this.goal,
      injuries: injuries ?? this.injuries,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}
