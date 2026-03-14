import 'package:mjolnir/models/exercise.dart';

class Routine {
  final String name;
  final List<Exercise> exercises;

  Routine({
    required this.name,
    required this.exercises,
  });
}