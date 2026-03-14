import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/exercise.dart';
import 'package:mjolnir/services/storage_service.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List<Exercise> exercises = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final saved = await StorageService.loadExercises();
    setState(() {
      exercises = saved;
    });
  }

  Future<void> _saveExercises() async {
    await StorageService.saveExercises(exercises);
  }

  void _showExerciseForm({Exercise? existing, int? index}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final setsController =
        TextEditingController(text: existing?.sets.toString() ?? '');
    final repsController =
        TextEditingController(text: existing?.reps.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundAppBar,
        title: Text(
          existing == null ? 'Nuevo ejercicio' : 'Editar ejercicio',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(nameController, 'Nombre'),
            const SizedBox(height: 12),
            _buildField(setsController, 'Series', isNumber: true),
            const SizedBox(height: 12),
            _buildField(repsController, 'Repeticiones', isNumber: true),
          ],
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

              if (name.isEmpty || sets == null || reps == null) return;

              final exercise = Exercise(
                name: name,
                sets: sets,
                reps: reps,
              );

              setState(() {
                if (index != null) {
                  exercises[index] = exercise;
                } else {
                  exercises.add(exercise);
                }
              });

              await _saveExercises();
              Navigator.pop(context);
            },
            child: Text('Guardar',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
              setState(() {
                exercises.removeAt(index);
              });
              await _saveExercises();
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
      body: exercises.isEmpty
          ? Center(
              child: Text(
                'No hay ejercicios todavía.\nTocá + para agregar uno.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return Card(
                  color: AppColors.backgroundAppBar,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      exercise.name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${exercise.sets} series x ${exercise.reps} reps',
                      style: const TextStyle(color: Colors.white60),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: AppColors.primary),
                          onPressed: () =>
                              _showExerciseForm(existing: exercise, index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.redAccent),
                          onPressed: () => _deleteExercise(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showExerciseForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}