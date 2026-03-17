class Exercise {
  final String name;
  final String muscle;
  final String equipment;
  final String variant;

  Exercise({
    required this.name,
    this.muscle = '',
    this.equipment = '',
    this.variant = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'muscle': muscle,
      'equipment': equipment,
      'variant': variant,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      muscle: json['muscle'] ?? '',
      equipment: json['equipment'] ?? '',
      variant: json['variant'] ?? '',
    );
  }
}