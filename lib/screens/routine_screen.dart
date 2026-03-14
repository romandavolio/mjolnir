import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/exercise.dart';
import 'package:mjolnir/models/routine.dart';
import 'package:mjolnir/services/storage_service.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  final List<Routine> routines = [
    Routine(
      name: 'Día de pecho',
      exercises: [
        Exercise(name: 'Press banca', sets: 4, reps: 10, weight: 0),
        Exercise(name: 'Aperturas', sets: 3, reps: 12, weight: 0),
      ],
    ),
    Routine(
      name: 'Día de piernas',
      exercises: [
        Exercise(name: 'Sentadilla', sets: 4, reps: 8, weight: 0),
        Exercise(name: 'Prensa', sets: 3, reps: 12, weight: 0),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadAllWeights();
  }

  Future<void> _loadAllWeights() async {
    for (final routine in routines) {
      for (final exercise in routine.exercises) {
        final saved = await StorageService.loadWeight(exercise.name);
        if (saved != null) {
          setState(() {
            exercise.weight = saved;
          });
        }
      }
    }
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
            labelText: 'Peso (kg)',
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
                setState(() {
                  exercise.weight = newWeight;
                });
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: routines.length,
        itemBuilder: (context, index) {
          final routine = routines[index];
          return Card(
            color: AppColors.backgroundAppBar,
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(
                routine.name,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: routine.exercises.map((exercise) {
                return ListTile(
                  title: Text(
                    exercise.name,
                    style: const TextStyle(color: Colors.white),
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
                        '${exercise.weight} kg',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}