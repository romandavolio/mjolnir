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
}