class Exercise {
  final String name;
  final String muscle;
  final List<String> types;

  Exercise({
    required this.name,
    this.muscle = '',
    List<String>? types,
  }) : types = types ?? [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'muscle': muscle,
      'types': types,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      muscle: json['muscle'] ?? '',
      types: List<String>.from(json['types'] ?? []),
    );
  }
}
