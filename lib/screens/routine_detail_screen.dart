import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/core/muscle_data.dart';
import 'package:mjolnir/models/exercise.dart';
import 'package:mjolnir/models/routine.dart';
import 'package:mjolnir/models/routine_exercise.dart';
import 'package:mjolnir/models/serie.dart';
import 'package:mjolnir/services/routine_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:mjolnir/screens/workout_session_screen.dart';

class RoutineDetailScreen extends StatefulWidget {
  final Routine routine;
  final Future<void> Function() onSave;
  final bool readOnly;
  final String? viewAsUid;

  const RoutineDetailScreen({
    super.key,
    required this.routine,
    required this.onSave,
    this.readOnly = false,
    this.viewAsUid,
  });

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  String _unit = 'kg';
  int? _activeTimer;
  String? _activeTimerExercise;
  bool _timerRunning = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final unit = await RoutineService.loadUnit();

    for (final routineExercise in widget.routine.exercises) {
      for (int i = 0; i < routineExercise.series.length; i++) {
        final weight = await RoutineService.loadSerieWeight(
          exerciseName: routineExercise.exercise.name,
          serieIndex: i,
          rutinaId: widget.routine.id,
          uid: widget.viewAsUid,
        );
        routineExercise.series[i].weight = weight;
      }
    }

    if (!mounted) return;
    setState(() {
      _unit = unit;
    });
  }

  Future<void> _save() async => await widget.onSave();

  // --- Formulario de series ---

  void _showSeriesForm(RoutineExercise? existing, Exercise exercise) {
    List<TextEditingController> repsControllers = existing != null
        ? existing.series
              .map((s) => TextEditingController(text: s.reps.toString()))
              .toList()
        : [TextEditingController(text: '10')];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.backgroundAppBar,
          title: Text(
            exercise.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SERIES',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                ...repsControllers.asMap().entries.map((entry) {
                  final i = entry.key;
                  final controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              int tempReps =
                                  int.tryParse(controller.text) ?? 10;
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: AppColors.backgroundAppBar,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (ctx) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text(
                                              'Cancelar',
                                              style: TextStyle(
                                                color: Colors.white60,
                                              ),
                                            ),
                                          ),
                                          const Text(
                                            'REPETICIONES',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 11,
                                              letterSpacing: 1.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              controller.text = tempReps
                                                  .toString();
                                              setDialogState(() {});
                                              Navigator.pop(ctx);
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
                                    SizedBox(
                                      height: 200,
                                      child: CupertinoPicker(
                                        scrollController:
                                            FixedExtentScrollController(
                                              initialItem: tempReps - 1,
                                            ),
                                        itemExtent: 40,
                                        onSelectedItemChanged: (index) {
                                          tempReps = index + 1;
                                        },
                                        children: List.generate(
                                          50,
                                          (i) => Center(
                                            child: Text(
                                              '${i + 1} reps',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.text.isEmpty
                                        ? 'Seleccionar reps'
                                        : '${controller.text} reps',
                                    style: TextStyle(
                                      color: controller.text.isEmpty
                                          ? AppColors.textSecondary
                                          : Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Icon(
                                    Icons.expand_more,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (repsControllers.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () => setDialogState(() {
                              repsControllers.removeAt(i);
                            }),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setDialogState(
                    () => repsControllers.add(
                      TextEditingController(
                        text: repsControllers.isNotEmpty
                            ? repsControllers.last.text
                            : '10',
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Agregar serie',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            TextButton(
              onPressed: () async {
                final series = repsControllers
                    .map((c) => int.tryParse(c.text))
                    .where((r) => r != null && r > 0)
                    .map((r) => Serie(reps: r!))
                    .toList();

                if (series.isEmpty) return;

                setState(() {
                  if (existing != null) {
                    existing.series = series;
                  } else {
                    widget.routine.exercises.add(
                      RoutineExercise(exercise: exercise, series: series),
                    );
                  }
                });

                await _save();
                Navigator.pop(context);
              },
              child: Text(
                'Guardar',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Editar peso de una serie ---

  void _editSerieWeight(Serie serie, String exerciseName, int serieIndex) {
    int selectedInt = serie.weight.toInt();
    int selectedDecimal = ((serie.weight - selectedInt) * 100).round();
    // Normalizar decimal a opciones válidas
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
                      exerciseName: exerciseName,
                      serieIndex: serieIndex,
                      weight: newWeight,
                      rutinaId: widget.routine.id,
                    );
                    await RoutineService.addWeightEntry(
                      exerciseName,
                      newWeight,
                    );

                    // Activar timer automáticamente
                    final timerSeconds = await RoutineService.loadRestTimer(
                      exerciseName,
                    );
                    if (mounted) _startTimer(timerSeconds, exerciseName);
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
                // Parte entera
                SizedBox(
                  width: 80,
                  height: 200,
                  child: CupertinoPicker(
                    looping: true,
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedInt,
                    ),
                    itemExtent: 36,
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
                // Separador
                const Text(
                  '.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Parte decimal
                SizedBox(
                  width: 80,
                  height: 200,
                  child: CupertinoPicker(
                    looping: true,
                    scrollController: FixedExtentScrollController(
                      initialItem: decimals.indexOf(selectedDecimal),
                    ),
                    itemExtent: 36,
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
                // Unidad
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

  // --- Quitar ejercicio de rutina ---

  void _removeExercise(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundAppBar,
        title: const Text(
          'Quitar ejercicio',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Querés quitar "${widget.routine.exercises[index].exercise.name}" de esta rutina?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () async {
              setState(() => widget.routine.exercises.removeAt(index));
              await _save();
              Navigator.pop(context);
            },
            child: const Text(
              'Quitar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  // --- Selector de músculo → tipo → ejercicio ---

  void _showMuscleSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundAppBar,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GRUPO MUSCULAR',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExerciseCatalog.muscles.map((muscle) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showElementSelector(muscle);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      muscle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showElementSelector(String muscle) {
    final elements = ExerciseCatalog.elementsFor(muscle);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundAppBar,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showMuscleSelector();
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  muscle.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: elements.keys.map((element) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showAccompanimentSelector(muscle, element);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      element,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAccompanimentSelector(String muscle, String element) {
    final accompaniments = ExerciseCatalog.accompanimentFor(muscle, element);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundAppBar,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showElementSelector(muscle);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  element.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: accompaniments.keys.map((accompaniment) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showExerciseSelector(muscle, element, accompaniment);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      accompaniment,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showExerciseSelector(
    String muscle,
    String element,
    String accompaniment,
  ) {
    final exercises = ExerciseCatalog.exercisesFor(
      muscle,
      element,
      accompaniment,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundAppBar,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showAccompanimentSelector(muscle, element);
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    accompaniment.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exerciseName = exercises[index];
                    final exercise = Exercise(
                      name: exerciseName,
                      muscle: muscle,
                      equipment: element,
                      variant: accompaniment,
                    );
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _showSeriesForm(null, exercise);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.fitness_center,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exerciseName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '$muscle · $element · $accompaniment',
                                    style: TextStyle(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.add,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.routine.name),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
        actions: [
          if (!widget.readOnly)
            TextButton(
              onPressed: widget.routine.exercises.isEmpty
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WorkoutSessionScreen(routine: widget.routine),
                      ),
                    ),
              child: Text(
                'Comenzar',
                style: TextStyle(
                  color: widget.routine.exercises.isEmpty
                      ? AppColors.textSecondary
                      : AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          widget.routine.exercises.isEmpty
              ? const Center(
                  child: Text(
                    'No hay ejercicios en esta rutina.\nTocá + para agregar uno.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 15),
                  ),
                )
              : Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.routine.exercises.length,
                    onReorder: (oldIndex, newIndex) async {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = widget.routine.exercises.removeAt(
                          oldIndex,
                        );
                        widget.routine.exercises.insert(newIndex, item);
                      });
                      await _save();
                    },
                    itemBuilder: (context, index) {
                      final routineExercise = widget.routine.exercises[index];
                      final exercise = routineExercise.exercise;
                      return Card(
                        key: ValueKey(exercise.name),
                        color: AppColors.backgroundAppBar,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: const Icon(
                                      Icons.drag_handle,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (exercise.muscle.isNotEmpty)
                                          Text(
                                            [
                                              if (exercise.muscle.isNotEmpty)
                                                exercise.muscle,
                                              if (exercise.equipment.isNotEmpty)
                                                exercise.equipment,
                                              if (exercise.variant.isNotEmpty)
                                                exercise.variant,
                                            ].join(' · '),
                                            style: TextStyle(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.7),
                                              fontSize: 11,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  FutureBuilder<int>(
                                    future: RoutineService.loadRestTimer(
                                      exercise.name,
                                    ),
                                    builder: (context, snapshot) {
                                      final seconds = snapshot.data ?? 60;
                                      return IconButton(
                                        icon: const Icon(
                                          Icons.timer_outlined,
                                          color: AppColors.textSecondary,
                                          size: 18,
                                        ),
                                        onPressed: () => _showTimerPicker(
                                          exercise.name,
                                          seconds,
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: AppColors.textSecondary,
                                      size: 18,
                                    ),
                                    onPressed: () => _showSeriesForm(
                                      routineExercise,
                                      exercise,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    onPressed: () => _removeExercise(index),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...routineExercise.series.asMap().entries.map((
                                entry,
                              ) {
                                final i = entry.key;
                                final serie = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${i + 1}',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${serie.reps} reps',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () => _editSerieWeight(
                                          serie,
                                          exercise.name,
                                          i,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppColors.primary,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            serie.weight == 0
                                                ? '— $_unit'
                                                : '${serie.weight} $_unit',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

          // Banner del timer
          if (_activeTimer != null)
            Positioned(
              bottom: 80,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activeTimer! > 0
                                ? 'Descansando...'
                                : '¡Listo para la siguiente serie!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          if (_activeTimerExercise != null)
                            Text(
                              _activeTimerExercise!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                        ],
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
      floatingActionButton: widget.readOnly
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: _showMuscleSelector,
              child: const Icon(Icons.add, color: Colors.black),
            ),
    );
  }

  void _startTimer(int seconds, String exerciseName) {
    setState(() {
      _activeTimer = seconds;
      _activeTimerExercise = exerciseName;
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
      _activeTimerExercise = null;
      _timerRunning = false;
    });
  }

  void _showTimerPicker(String exerciseName, int currentSeconds) {
    int tempSeconds = currentSeconds;

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
                    _startTimer(tempSeconds, exerciseName);
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
}
