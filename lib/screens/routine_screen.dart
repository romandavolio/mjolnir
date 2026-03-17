import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/routine.dart';
import 'package:mjolnir/models/user_profile.dart';
import 'package:mjolnir/screens/routine_detail_screen.dart';
import 'package:mjolnir/services/routine_service.dart';
import 'package:mjolnir/services/user_service.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  List<Routine> _myRoutines = [];
  List<Routine> _assignedRoutines = [];
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await UserService.getCurrentProfile();
    final myRoutines = await RoutineService.loadMyRoutines();

    List<Routine> assignedRoutines = [];
    if (profile?.role == 'alumno') {
      final assignments = await RoutineService.getAssignedToAlumno(
        profile!.uid,
      );
      for (final assignment in assignments) {
        final routine = await RoutineService.loadRoutine(
          assignment.trainerId,
          assignment.rutinaId,
        );
        if (routine != null) assignedRoutines.add(routine);
      }
    }

    if (!mounted) return;
    setState(() {
      _profile = profile;
      _myRoutines = myRoutines;
      _assignedRoutines = assignedRoutines;
      _loading = false;
    });
  }

  void _createRoutine() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundAppBar,
        title: const Text(
          'Nueva rutina',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Nombre (ej: Pecho y tríceps)',
            labelStyle: TextStyle(color: AppColors.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
            focusedBorder: UnderlineInputBorder(
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
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final routine = Routine(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
              );
              await RoutineService.saveRoutine(routine);
              setState(() => _myRoutines.add(routine));
              Navigator.pop(context);
            },
            child: Text('Crear', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _deleteRoutine(Routine routine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundAppBar,
        title: const Text(
          'Eliminar rutina',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Seguro que querés eliminar "${routine.name}"?',
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
              await RoutineService.deleteRoutine(routine.id);
              setState(() => _myRoutines.remove(routine));
              Navigator.pop(context);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
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
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _myRoutines.isEmpty && _assignedRoutines.isEmpty
          ? const Center(
              child: Text(
                'No hay rutinas todavía.\nTocá + para crear una.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_assignedRoutines.isNotEmpty) ...[
                  const Text(
                    'ASIGNADAS POR MI TRAINER',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._assignedRoutines.map(
                    (r) => _buildRoutineCard(r, assigned: true),
                  ),
                  const SizedBox(height: 24),
                ],
                if (_myRoutines.isNotEmpty) ...[
                  const Text(
                    'MIS RUTINAS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._myRoutines.map(
                    (r) => _buildRoutineCard(r, assigned: false),
                  ),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _createRoutine,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildRoutineCard(Routine routine, {required bool assigned}) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoutineDetailScreen(
              routine: routine,
              onSave: () => RoutineService.saveRoutine(routine),
              readOnly: assigned && _profile?.role == 'alumno',
            ),
          ),
        );
        _loadData();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: assigned
                ? AppColors.secondary.withValues(alpha: 0.4)
                : AppColors.primary.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: assigned
                    ? AppColors.secondary.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: assigned
                      ? AppColors.secondary.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.fitness_center,
                color: assigned ? AppColors.secondary : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${routine.exercises.length} ejercicios',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!assigned)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: () => _deleteRoutine(routine),
              ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
