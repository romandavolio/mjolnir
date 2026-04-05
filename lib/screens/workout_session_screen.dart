import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/routine.dart';
import 'package:mjolnir/models/routine_exercise.dart';
import 'package:mjolnir/models/serie.dart';
import 'package:mjolnir/services/routine_service.dart';
import 'package:mjolnir/screens/workout_summary_screen.dart';
import 'package:mjolnir/core/workout_mixin.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final Routine routine;

  const WorkoutSessionScreen({super.key, required this.routine});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen>
    with WorkoutMixin {
  int _currentIndex = 0;
  String _unit = 'kg';
  int? _activeTimer;
  bool _timerRunning = false;
  late DateTime _sessionStart;
  Map<String, DateTime?> _weightDates = {};
  Map<String, double> _lastWeights = {};

  @override
  void initState() {
    super.initState();
    _sessionStart = DateTime.now();
    _loadUnit();
    _loadWeights();
  }

  @override
  void dispose() {
    _timerRunning = false;
    super.dispose();
  }

  Future<void> _loadUnit() async {
    final unit = await RoutineService.loadUnit();
    if (!mounted) return;
    setState(() => _unit = unit);
  }

  Future<void> _loadWeights() async {
    final Map<String, DateTime?> dates = {};
    final Map<String, double> lastWeights = {};
    for (final routineExercise in widget.routine.exercises) {
      for (int i = 0; i < routineExercise.series.length; i++) {
        final result = await RoutineService.loadSerieWeightWithDate(
          exerciseName: routineExercise.exercise.name,
          serieIndex: i,
          rutinaId: widget.routine.id,
        );
        routineExercise.series[i].weight = result['weight'];
        dates['${routineExercise.exercise.name}_$i'] = result['date'];
        if (result['previousWeight'] != null) {
          lastWeights['${routineExercise.exercise.name}_$i'] =
              result['previousWeight'];
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _weightDates = dates;
      _lastWeights = lastWeights;
    });
  }

  RoutineExercise get _currentExercise =>
      widget.routine.exercises[_currentIndex];

  bool get _isLastExercise =>
      _currentIndex == widget.routine.exercises.length - 1;

  void _finishSession() {
    stopTimer();
    final duration = DateTime.now().difference(_sessionStart);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutSummaryScreen(
          routine: widget.routine,
          duration: duration,
          sessionStart: _sessionStart,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _currentExercise;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.routine.name),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
        actions: [
          TextButton(
            onPressed: _finishSession,
            child: const Text(
              'Finalizar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progreso
                Row(
                  children: [
                    Text(
                      '${_currentIndex + 1} / ${widget.routine.exercises.length}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value:
                              (_currentIndex + 1) /
                              widget.routine.exercises.length,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.15,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nombre del ejercicio
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.exercise.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (exercise.exercise.muscle.isNotEmpty)
                            Text(
                              [
                                exercise.exercise.muscle,
                                if (exercise.exercise.equipment.isNotEmpty)
                                  exercise.exercise.equipment,
                                if (exercise.exercise.variant.isNotEmpty)
                                  exercise.exercise.variant,
                              ].join(' · '),
                              style: TextStyle(
                                color: AppColors.primary.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.timer_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () async {
                        final seconds = await RoutineService.loadRestTimer(
                          exercise.exercise.name,
                        );
                        if (mounted) {
                          showTimerPicker(
                            context,
                            exercise.exercise.name,
                            seconds,
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Series
                const Text(
                  'SERIES',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: exercise.series.length,
                    itemBuilder: (context, i) {
                      final serie = exercise.series[i];
                      final dateKey = '${exercise.exercise.name}_$i';
                      final weightDate = _weightDates[dateKey];
                      final isToday =
                          weightDate != null &&
                          weightDate.year == DateTime.now().year &&
                          weightDate.month == DateTime.now().month &&
                          weightDate.day == DateTime.now().day;
                      final hasWeight = serie.weight > 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isToday && hasWeight
                                  ? AppColors.primary.withValues(alpha: 0.5)
                                  : AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isToday && hasWeight
                                      ? AppColors.primary.withValues(alpha: 0.2)
                                      : AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${serie.reps} reps',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              const Spacer(),
                              if (hasWeight)
                                GestureDetector(
                                  onTap: () => showSerieHistory(
                                    context,
                                    exercise.exercise.name,
                                    i,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: SizedBox(
                                      width: 70,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'último',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 9,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          Text(
                                            _lastWeights.containsKey(dateKey)
                                                ? '${_lastWeights[dateKey]} $unit'
                                                : '${serie.weight} $unit',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              GestureDetector(
                                onTap: () => showWeightPicker(
                                  context,
                                  serie: isToday
                                      ? serie
                                      : Serie(reps: serie.reps),
                                  exerciseName: exercise.exercise.name,
                                  serieIndex: i,
                                  rutinaId: widget.routine.id,
                                  originalSerie: serie,
                                  onWeightSaved: (newWeight) {
                                    setState(() {
                                      _weightDates[dateKey] = DateTime.now();
                                    });
                                  },
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isToday && hasWeight
                                        ? AppColors.primary.withValues(
                                            alpha: 0.15,
                                          )
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: AppColors.primary,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    isToday && hasWeight
                                        ? '${serie.weight} $unit'
                                        : '— $unit',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Botón siguiente / finalizar
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isLastExercise) {
                        _finishSession();
                      } else {
                        stopTimer();
                        setState(() => _currentIndex++);
                        _loadWeights();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLastExercise
                          ? AppColors.secondary
                          : AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isLastExercise
                          ? '¡Finalizar rutina!'
                          : 'Siguiente ejercicio',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          buildTimerBanner(),
        ],
      ),
    );
  }
}
