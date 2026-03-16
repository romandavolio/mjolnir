import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/core/muscle_data.dart';
import 'package:mjolnir/models/exercise.dart';
import 'package:mjolnir/models/routine.dart';
import 'package:mjolnir/services/storage_service.dart';

class RoutineDetailScreen extends StatefulWidget {
  final Routine routine;
  final Future<void> Function() onSave;

  const RoutineDetailScreen({
    super.key,
    required this.routine,
    required this.onSave,
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
    final unit = await StorageService.loadUnit();
    final catalog = await StorageService.loadExercises();
    for (final exercise in widget.routine.exercises) {
      final saved = await StorageService.loadWeight(exercise.name);
      if (saved != null) exercise.weight = saved;
    }
    setState(() {
      _unit = unit;
      _catalogExercises = catalog;
    });
  }

  Future<void> _save() async => await widget.onSave();

  // --- Flujo de selección desde catálogo ---

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
            const Text('AGREGAR EJERCICIO',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showNewExerciseForm();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    const Text('Crear ejercicio nuevo',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('ELEGIR DEL CATÁLOGO',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MuscleData.muscles.map((muscle) {
                final count = _catalogExercises
                    .where((e) =>
                        e.muscle == muscle &&
                        !widget.routine.exercises
                            .any((re) => re.name == e.name))
                    .length;
                if (count == 0) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showTypeSelector(muscle);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(muscle,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('$count',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
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

  void _showTypeSelector(String muscle) {
    final types = MuscleData.typesFor(muscle);
    final exercisesForMuscle = _catalogExercises
        .where((e) =>
            e.muscle == muscle &&
            !widget.routine.exercises.any((re) => re.name == e.name))
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
                    child: Icon(Icons.arrow_back_ios,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(muscle.toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2)),
                ],
              ),
              const SizedBox(height: 16),
              // Chips de tipo
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTypeChip('Todos', null, muscle,
                      exercisesForMuscle, scrollController),
                  ...types.map((type) {
                    final count = exercisesForMuscle
                        .where((e) => e.types.contains(type))
                        .length;
                    if (count == 0) return const SizedBox.shrink();
                    return _buildTypeChip(type, type, muscle,
                        exercisesForMuscle, scrollController);
                  }),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _ExerciseList(
                  exercises: exercisesForMuscle,
                  onSelect: (exercise) async {
                    setState(() =>
                        widget.routine.exercises.add(exercise));
                    await _save();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(
    String label,
    String? type,
    String muscle,
    List<Exercise> exercises,
    ScrollController scrollController,
  ) {
    return GestureDetector(
      onTap: () {},
      child: _TypeFilterChip(
        label: label,
        type: type,
        exercises: exercises,
        onSelect: (exercise) async {
          setState(() => widget.routine.exercises.add(exercise));
          await _save();
          Navigator.pop(context);
        },
      ),
    );
  }

  // --- Crear ejercicio nuevo ---

  void _showNewExerciseForm() {
    final nameController = TextEditingController();
    final setsController = TextEditingController();
    final repsController = TextEditingController();
    String? selectedMuscle;
    List<String> selectedTypes = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.backgroundAppBar,
          title: const Text('Nuevo ejercicio',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField(nameController, 'Nombre'),
                const SizedBox(height: 12),
                _buildField(setsController, 'Series',
                    isNumber: true),
                const SizedBox(height: 12),
                _buildField(repsController, 'Repeticiones',
                    isNumber: true),
                const SizedBox(height: 20),
                const Text('MÚSCULO',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 1.5)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedMuscle,
                  dropdownColor: AppColors.backgroundAppBar,
                  style: const TextStyle(color: Colors.white),
                  hint: const Text('Seleccioná un músculo',
                      style: TextStyle(
                          color: AppColors.textSecondary)),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                  items: MuscleData.muscles.map((m) {
                    return DropdownMenuItem(
                        value: m, child: Text(m));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedMuscle = value;
                      selectedTypes.clear();
                    });
                  },
                ),
                if (selectedMuscle != null) ...[
                  const SizedBox(height: 20),
                  const Text('TIPOS',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        MuscleData.typesFor(selectedMuscle!).map((type) {
                      final isSelected = selectedTypes.contains(type);
                      return GestureDetector(
                        onTap: () => setDialogState(() {
                          isSelected
                              ? selectedTypes.remove(type)
                              : selectedTypes.add(type);
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.2)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Text(type,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              )),
                        ),
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
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white60)),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final sets = int.tryParse(setsController.text);
                final reps = int.tryParse(repsController.text);
                if (name.isEmpty ||
                    sets == null ||
                    reps == null ||
                    selectedMuscle == null) return;

                final exercise = Exercise(
                  name: name,
                  sets: sets,
                  reps: reps,
                  muscle: selectedMuscle!,
                  types: selectedTypes,
                );

                setState(() => widget.routine.exercises.add(exercise));
                _catalogExercises.add(exercise);
                await StorageService.saveExercises(_catalogExercises);
                await _save();
                Navigator.pop(context);
              },
              child: Text('Guardar',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType:
          isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.primary),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  // --- Editar peso ---

  void _editWeight(Exercise exercise) {
    final controller =
        TextEditingController(text: exercise.weight.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundAppBar,
        title: Text(exercise.name,
            style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
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
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () async {
              final newWeight = double.tryParse(controller.text);
              if (newWeight != null) {
                await StorageService.saveWeight(
                    exercise.name, newWeight);
                setState(() => exercise.weight = newWeight);
              }
              Navigator.pop(context);
            },
            child: Text('Guardar',
                style: TextStyle(color: AppColors.primary)),
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
        title: const Text('Quitar ejercicio',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Querés quitar "${widget.routine.exercises[index].name}" de esta rutina?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () async {
              setState(() => widget.routine.exercises.removeAt(index));
              await _save();
              Navigator.pop(context);
            },
            child: const Text('Quitar',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
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
                final exercise = widget.routine.exercises[index];
                return Card(
                  color: AppColors.backgroundAppBar,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(exercise.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${exercise.sets} series x ${exercise.reps} reps',
                          style: const TextStyle(
                              color: AppColors.textSecondary),
                        ),
                        if (exercise.muscle.isNotEmpty)
                          Text(
                            exercise.muscle +
                                (exercise.types.isNotEmpty
                                    ? ' · ${exercise.types.join(', ')}'
                                    : ''),
                            style: TextStyle(
                              color: AppColors.primary.withOpacity(0.7),
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                    isThreeLine: exercise.muscle.isNotEmpty,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _editWeight(exercise),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${exercise.weight} $_unit',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.redAccent, size: 20),
                          onPressed: () => _removeExercise(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showMuscleSelector,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

// Widget separado para la lista con filtro por tipo
class _TypeFilterChip extends StatefulWidget {
  final String label;
  final String? type;
  final List<Exercise> exercises;
  final Future<void> Function(Exercise) onSelect;

  const _TypeFilterChip({
    required this.label,
    required this.type,
    required this.exercises,
    required this.onSelect,
  });

  @override
  State<_TypeFilterChip> createState() => _TypeFilterChipState();
}

class _TypeFilterChipState extends State<_TypeFilterChip> {
  bool _selected = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.type == null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _selected = true),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _selected
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: _selected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 12,
            fontWeight:
                _selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Lista de ejercicios con filtro por tipo activo
class _ExerciseList extends StatefulWidget {
  final List<Exercise> exercises;
  final Future<void> Function(Exercise) onSelect;

  const _ExerciseList({
    required this.exercises,
    required this.onSelect,
  });

  @override
  State<_ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends State<_ExerciseList> {
  String? _activeType;

  List<Exercise> get _filtered {
    if (_activeType == null) return widget.exercises;
    return widget.exercises
        .where((e) => e.types.contains(_activeType))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final allTypes = widget.exercises
        .expand((e) => e.types)
        .toSet()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (allTypes.isNotEmpty)
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chip('Todos', null),
                ...allTypes.map((t) => _chip(t, t)),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: _filtered.length,
            itemBuilder: (context, index) {
              final exercise = _filtered[index];
              return GestureDetector(
                onTap: () => widget.onSelect(exercise),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fitness_center,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exercise.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                            Text(
                              '${exercise.sets} series x ${exercise.reps} reps',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.add,
                          color: AppColors.primary, size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, String? type) {
    final isSelected = _activeType == type;
    return GestureDetector(
      onTap: () => setState(() => _activeType = type),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Text(label,
            style: TextStyle(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
              fontSize: 12,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
            )),
      ),
    );
  }
}