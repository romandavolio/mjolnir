class Serie {
  int reps;
  double weight;
  bool completed;

  Serie({
    required this.reps,
    this.weight = 0,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
    'reps': reps,
    'weight': weight,
    'completed': completed,
  };

  factory Serie.fromJson(Map<String, dynamic> json) => Serie(
    reps: json['reps'],
    weight: (json['weight'] as num?)?.toDouble() ?? 0,
    completed: json['completed'] ?? false,
  );
}