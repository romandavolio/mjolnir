import 'package:mjolnir/models/exercise.dart';

class Routine {
  final String id;
  String name;
  List<Exercise> exercises;

  Routine({
    required this.id,
    required this.name,
    List<Exercise>? exercises,
  }) : exercises = exercises ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      name: json['name'],
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
    );
  }
}