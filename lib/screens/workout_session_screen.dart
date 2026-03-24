import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/routine.dart';
import 'package:mjolnir/models/routine_exercise.dart';
import 'package:mjolnir/models/serie.dart';
import 'package:mjolnir/services/routine_service.dart';
import 'package:mjolnir/screens/workout_summary_screen.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final Routine routine;

  const WorkoutSessionScreen({super.key, required this.routine});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  int _currentIndex = 0;
  String _unit = 'kg';
  int? _activeTimer;
  bool _timerRunning = false;
  late DateTime _sessionStart;

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
    for (final routineExercise in widget.routine.exercises) {
      for (int i = 0; i < routineExercise.series.length; i++) {
        final weight = await RoutineService.loadSerieWeight(
          exerciseName: routineExercise.exercise.name,
          serieIndex: i,
          rutinaId: widget.routine.id,
        );
        routineExercise.series[i].weight = weight;
      }
    }
    if (!mounted) return;
    setState(() {});
  }

  RoutineExercise get _currentExercise =>
      widget.routine.exercises[_currentIndex];

  bool get _isLastExercise =>
      _currentIndex == widget.routine.exercises.length - 1;

  void _startTimer(int seconds) {
    setState(() {
      _activeTimer = seconds;
      _timerRunning = true;
    });
    _runTimer();
  }

  void _runTimer() async {
    while (_timerRunning && _activeTimer != null && _activeTimer! > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        if (_activeTimer != null) _activeTimer = _activeTimer! - 1;
        if (_activeTimer == 0) _timerRunning = false;
      });
    }
  }

  void _stopTimer() {
    setState(() {
      _activeTimer = null;
      _timerRunning = false;
    });
  }

  void _showTimerPicker() async {
    final exerciseName = _currentExercise.exercise.name;
    final currentSeconds = await RoutineService.loadRestTimer(exerciseName);
    int tempSeconds = currentSeconds;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundAppBar,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
                const Text(
                  'DESCANSO',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await RoutineService.saveRestTimer(
                      exerciseName,
                      tempSeconds,
                    );
                    _startTimer(tempSeconds);
                  },
                  child: Text(
                    'Iniciar',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: (tempSeconds ~/ 5) - 1,
              ),
              itemExtent: 40,
              looping: true,
              onSelectedItemChanged: (index) {
                tempSeconds = (index + 1) * 5;
              },
              children: List.generate(60, (i) {
                final secs = (i + 1) * 5;
                final mins = secs ~/ 60;
                final remaining = secs % 60;
                final label = mins > 0
                    ? remaining > 0
                          ? '${mins}m ${remaining}s'
                          : '${mins}m'
                    : '${secs}s';
                return Center(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _editSerieWeight(Serie serie, int serieIndex) {
    int selectedInt = serie.weight.toInt();
    int selectedDecimal = ((serie.weight - selectedInt) * 100).round();
    const decimals = [0, 25, 50, 75];
    if (!decimals.contains(selectedDecimal)) selectedDecimal = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundAppBar,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
                Text(
                  '${serie.reps} REPS',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final newWeight = selectedInt + selectedDecimal / 100.0;
                    setState(() => serie.weight = newWeight);
                    Navigator.pop(context);
                    await RoutineService.saveSerieWeight(
                      exerciseName: _currentExercise.exercise.name,
                      serieIndex: serieIndex,
                      weight: newWeight,
                      rutinaId: widget.routine.id,
                    );
                    await RoutineService.addWeightEntry(
                      _currentExercise.exercise.name,
                      newWeight,
                    );
                    final timerSeconds = await RoutineService.loadRestTimer(
                      _currentExercise.exercise.name,
                    );
                    if (mounted) _startTimer(timerSeconds);
                  },
                  child: Text(
                    'Listo',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 200,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedInt,
                    ),
                    itemExtent: 36,
                    looping: true,
                    onSelectedItemChanged: (index) {
                      selectedInt = index;
                    },
                    children: List.generate(
                      501,
                      (i) => Center(
                        child: Text(
                          '$i',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Text(
                  '.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 200,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: decimals.indexOf(selectedDecimal),
                    ),
                    itemExtent: 36,
                    looping: true,
                    onSelectedItemChanged: (index) {
                      selectedDecimal = decimals[index];
                    },
                    children: decimals
                        .map(
                          (d) => Center(
                            child: Text(
                              '$d',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    _unit,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _finishSession() {
    _stopTimer();
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
                      onPressed: _showTimerPicker,
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
                              color: serie.weight > 0
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
                                  color: serie.weight > 0
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
                              GestureDetector(
                                onTap: () => _editSerieWeight(serie, i),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: serie.weight > 0
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
                                    serie.weight == 0
                                        ? '— $_unit'
                                        : '${serie.weight} $_unit',
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
                        _stopTimer();
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

          // Banner del timer
          if (_activeTimer != null)
            Positioned(
              bottom: 90,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundAppBar,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _activeTimer! > 0
                        ? AppColors.primary
                        : AppColors.secondary,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _activeTimer! > 0
                          ? Icons.timer_outlined
                          : Icons.check_circle_outline,
                      color: _activeTimer! > 0
                          ? AppColors.primary
                          : AppColors.secondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _activeTimer! > 0
                            ? 'Descansando...'
                            : '¡Listo para la siguiente serie!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (_activeTimer! > 0)
                      Text(
                        '${_activeTimer}s',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _stopTimer,
                      child: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
