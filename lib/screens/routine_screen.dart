import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/exercise.dart';
import 'package:mjolnir/services/storage_service.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  List<Exercise> exercises = [];
  String _unit = 'kg';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final saved = await StorageService.loadExercises();
    final unit = await StorageService.loadUnit();
    for (final exercise in saved) {
      final savedWeight = await StorageService.loadWeight(exercise.name);
      if (savedWeight != null) exercise.weight = savedWeight;
    }
    setState(() {
      exercises = saved;
      _unit = unit;
    });
  }

  void _editWeight(Exercise exercise) {
    final controller = TextEditingController(
      text: exercise.weight.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundAppBar,
        title: Text(
          exercise.name,
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
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () async {
              final newWeight = double.tryParse(controller.text);
              if (newWeight != null) {
                await StorageService.saveWeight(exercise.name, newWeight);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rutinas'),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
      ),
      body: exercises.isEmpty
          ? const Center(
              child: Text(
                'No hay ejercicios todavía.\nCreá uno desde la pantalla Ejercicios.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 15),
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
                    trailing: GestureDetector(
                      onTap: () => _editWeight(exercise),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${exercise.weight} $_unit',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}