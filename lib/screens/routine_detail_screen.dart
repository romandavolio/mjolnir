import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/core/muscle_data.dart';
import 'package:mjolnir/models/exercise.dart';
import 'package:mjolnir/models/routine.dart';
import 'package:mjolnir/models/routine_exercise.dart';
import 'package:mjolnir/models/serie.dart';
import 'package:mjolnir/services/storage_service.dart';
import 'package:mjolnir/services/routine_service.dart';

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
  List<Exercise> _catalogExercises = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final unit = await RoutineService.loadUnit();
    final catalog = await StorageService.loadExercises();

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
      _catalogExercises = catalog;
    });
  }

  Future<void> _save() async => await widget.onSave();

  // --- Formulario de series ---

  void _showSeriesForm(RoutineExercise? existing, Exercise exercise) {
    List<TextEditingController> repsControllers = existing != null
        ? existing.series
              .map((s) => TextEditingController(text: s.reps.toString()))
              .toList()
        : [TextEditingController()];

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
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Repeticiones',
                              labelStyle: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (repsControllers.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.redAccent,
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
                    () => repsControllers.add(TextEditingController()),
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
    final controller = TextEditingController(text: serie.weight.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundAppBar,
        title: Text(
          '${serie.reps} reps',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Peso ($_unit)',
            labelStyle: TextStyle(color: AppColors.primary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
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
              final newWeight = double.tryParse(controller.text);
              if (newWeight != null) {
                setState(() => serie.weight = newWeight);
                await RoutineService.saveSerieWeight(
                  exerciseName: exerciseName,
                  serieIndex: serieIndex,
                  weight: newWeight,
                  rutinaId: widget.routine.id,
                );
                await StorageService.addWeightEntry(exerciseName, newWeight);
              }
              Navigator.pop(context);
            },
            child: Text('Guardar', style: TextStyle(color: AppColors.primary)),
          ),
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
              'AGREGAR EJERCICIO',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showNewExerciseForm();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Crear ejercicio nuevo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ELEGIR DEL CATÁLOGO',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MuscleData.muscles.map((muscle) {
                final count = _catalogExercises
                    .where(
                      (e) =>
                          e.muscle == muscle &&
                          !widget.routine.exercises.any(
                            (re) => re.exercise.name == e.name,
                          ),
                    )
                    .length;
                if (count == 0) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showExerciseSelector(muscle);
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          muscle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

  void _showExerciseSelector(String muscle) {
    final exercises = _catalogExercises
        .where(
          (e) =>
              e.muscle == muscle &&
              !widget.routine.exercises.any((re) => re.exercise.name == e.name),
        )
        .toList();

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
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
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
                                    exercise.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (exercise.equipment.isNotEmpty ||
                                      exercise.variant.isNotEmpty)
                                    Text(
                                      [
                                        if (exercise.equipment.isNotEmpty)
                                          exercise.equipment,
                                        if (exercise.variant.isNotEmpty)
                                          exercise.variant,
                                      ].join(' · '),
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

  // --- Crear ejercicio nuevo desde rutina ---

  void _showNewExerciseForm() {
    final nameController = TextEditingController();
    String? selectedMuscle;
    String? selectedEquipment;
    String? selectedVariant;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.backgroundAppBar,
          title: const Text(
            'Nuevo ejercicio',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(color: AppColors.primary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'MÚSCULO',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedMuscle,
                  dropdownColor: AppColors.backgroundAppBar,
                  style: const TextStyle(color: Colors.white),
                  hint: const Text(
                    'Seleccioná un músculo',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: MuscleData.muscles.map((m) {
                    return DropdownMenuItem(value: m, child: Text(m));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedMuscle = value;
                      selectedEquipment = null;
                      selectedVariant = null;
                    });
                  },
                ),
                if (selectedMuscle != null) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'EQUIPAMIENTO',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MuscleData.equipmentFor(selectedMuscle!).map((
                      item,
                    ) {
                      final isSelected = selectedEquipment == item;
                      return GestureDetector(
                        onTap: () => setDialogState(() {
                          selectedEquipment = isSelected ? null : item;
                        }),
                        child: _buildChip(item, isSelected),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'VARIANTE',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MuscleData.variantsFor(selectedMuscle!).map((
                      item,
                    ) {
                      final isSelected = selectedVariant == item;
                      return GestureDetector(
                        onTap: () => setDialogState(() {
                          selectedVariant = isSelected ? null : item;
                        }),
                        child: _buildChip(item, isSelected),
                      );
                    }).toList(),
                  ),
                ],
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
                final name = nameController.text.trim();
                if (name.isEmpty || selectedMuscle == null) return;
                final exercise = Exercise(
                  name: name,
                  muscle: selectedMuscle!,
                  equipment: selectedEquipment ?? '',
                  variant: selectedVariant ?? '',
                );
                _catalogExercises.add(exercise);
                await StorageService.saveExercises(_catalogExercises);
                Navigator.pop(context);
                _showSeriesForm(null, exercise);
              },
              child: Text(
                'Siguiente',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
      ),
      body: widget.routine.exercises.isEmpty
          ? const Center(
              child: Text(
                'No hay ejercicios en esta rutina.\nTocá + para agregar uno.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.routine.exercises.length,
              itemBuilder: (context, index) {
                final routineExercise = widget.routine.exercises[index];
                final exercise = routineExercise.exercise;
                return Card(
                  color: AppColors.backgroundAppBar,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        color: AppColors.primary.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                              onPressed: () =>
                                  _showSeriesForm(routineExercise, exercise),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                              onPressed: () => _removeExercise(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Lista de series
                        ...routineExercise.series.asMap().entries.map((entry) {
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
                                    entry.key,
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
                                      borderRadius: BorderRadius.circular(8),
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
      floatingActionButton: widget.readOnly
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: _showMuscleSelector,
              child: const Icon(Icons.add, color: Colors.black),
            ),
    );
  }
}
