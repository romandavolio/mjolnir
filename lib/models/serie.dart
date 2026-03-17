class Serie {
  int reps;
  double weight;

  Serie({
    required this.reps,
    this.weight = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
    };
  }

  factory Serie.fromJson(Map<String, dynamic> json) {
    return Serie(
      reps: json['reps'],
      weight: json['weight'] ?? 0,
    );
  }
}
