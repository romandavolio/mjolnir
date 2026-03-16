class Exercise {
  final String name;
  final int sets;
  final int reps;
  double weight;
  final String muscle;
  final List<String> types;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.weight = 0,
    this.muscle = '',
    List<String>? types,
  }) : types = types ?? [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'muscle': muscle,
      'types': types,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight'] ?? 0,
      muscle: json['muscle'] ?? '',
      types: List<String>.from(json['types'] ?? []),
    );
  }
}