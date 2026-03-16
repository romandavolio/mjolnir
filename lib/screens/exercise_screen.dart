import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/core/muscle_data.dart';
import 'package:mjolnir/models/exercise.dart';
import 'package:mjolnir/services/storage_service.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List<Exercise> exercises = [];
  String? _selectedMuscleFilter;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final saved = await StorageService.loadExercises();
    setState(() => exercises = saved);
  }

  List<Exercise> get _filteredExercises {
    if (_selectedMuscleFilter == null) return exercises;
    return exercises
        .where((e) => e.muscle == _selectedMuscleFilter)
        .toList();
  }

  void _showExerciseForm({Exercise? existing, int? index}) {
    final nameController =
        TextEditingController(text: existing?.name ?? '');
    final setsController =
        TextEditingController(text: existing?.sets.toString() ?? '');
    final repsController =
        TextEditingController(text: existing?.reps.toString() ?? '');
    String? selectedMuscle = existing?.muscle.isNotEmpty == true
        ? existing!.muscle
        : null;
    List<String> selectedTypes = List.from(existing?.types ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.backgroundAppBar,
          title: Text(
            existing == null ? 'Nuevo ejercicio' : 'Editar ejercicio',
            style: const TextStyle(color: Colors.white),
          ),
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

                // Selector de músculo
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
                      style:
                          TextStyle(color: AppColors.textSecondary)),
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

                // Selector de tipos
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
                    children: MuscleData.typesFor(selectedMuscle!)
                        .map((type) {
                      final isSelected =
                          selectedTypes.contains(type);
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            isSelected
                                ? selectedTypes.remove(type)
                                : selectedTypes.add(type);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                    .withOpacity(0.2)
                                : AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.primary
                                      .withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
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

                setState(() {
                  if (index != null) {
                    exercises[index] = exercise;
                  } else {
                    exercises.add(exercise);
                  }
                });

                await StorageService.saveExercises(exercises);
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

  void _deleteExercise(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundAppBar,
        title: const Text('Eliminar ejercicio',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Seguro que querés eliminar "${exercises[index].name}"?',
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
              setState(() => exercises.removeAt(index));
              await StorageService.saveExercises(exercises);
              Navigator.pop(context);
            },
            child: const Text('Eliminar',
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
        title: const Text('Ejercicios'),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // Filtro por músculo
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildFilterChip('Todos', null),
                ...MuscleData.muscles
                    .map((m) => _buildFilterChip(m, m)),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: _filteredExercises.isEmpty
                ? Center(
                    child: Text(
                      _selectedMuscleFilter == null
                          ? 'No hay ejercicios.\nTocá + para agregar uno.'
                          : 'No hay ejercicios de $_selectedMuscleFilter.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      final realIndex = exercises.indexOf(exercise);
                      return Card(
                        color: AppColors.backgroundAppBar,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            exercise.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
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
                                    color: AppColors.primary
                                        .withOpacity(0.7),
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                          isThreeLine: exercise.muscle.isNotEmpty,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit,
                                    color: AppColors.primary),
                                onPressed: () => _showExerciseForm(
                                    existing: exercise,
                                    index: realIndex),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () =>
                                    _deleteExercise(realIndex),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showExerciseForm(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _selectedMuscleFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMuscleFilter = value),
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
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 12,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}