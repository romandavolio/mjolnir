class Exercise {
  final String name;
  final int sets;
  final int reps;
  double weight;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.weight = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight'] ?? 0,
    );
  }
}