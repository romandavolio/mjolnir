import 'package:mjolnir/models/exercise.dart';
import 'package:mjolnir/models/serie.dart';

class RoutineExercise {
  Exercise exercise;
  List<Serie> series;

  RoutineExercise({required this.exercise, List<Serie>? series})
    : series = series ?? [];

  String get setsDisplay {
    if (series.isEmpty) return 'Sin series';
    final grouped = <int, int>{};
    for (final s in series) {
      grouped[s.reps] = (grouped[s.reps] ?? 0) + 1;
    }
    return grouped.entries.map((e) => '${e.value}x${e.key}').join(' ');
  }

  Map<String, dynamic> toJson() => {
    'exercise': exercise.toJson(),
    'series': series.map((s) => s.toJson()).toList(),
  };

  factory RoutineExercise.fromJson(Map<String, dynamic> json) =>
      RoutineExercise(
        exercise: Exercise.fromJson(json['exercise']),
        series: (json['series'] as List).map((s) => Serie.fromJson(s)).toList(),
      );
}
