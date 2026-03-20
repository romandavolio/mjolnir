import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/routine.dart';
import 'package:mjolnir/models/user_profile.dart';
import 'package:mjolnir/screens/routine_detail_screen.dart';
import 'package:mjolnir/services/link_service.dart';
import 'package:mjolnir/services/routine_service.dart';
import 'package:mjolnir/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  List<Routine> _myRoutines = [];
  List<MapEntry<String, Routine>> _assignedRoutines = [];
  List<UserProfile> _linkedTrainers = [];
  UserProfile? _profile;
  bool _loading = true;
  bool _checkedUnlinkedTrainers = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await UserService.getCurrentProfile();
    final myRoutines = await RoutineService.loadMyRoutines();

    List<MapEntry<String, Routine>> assignedRoutines = [];
    List<UserProfile> linkedTrainers = [];

    if (profile?.role == 'alumno') {
      final assignments = await RoutineService.getAssignedToAlumno(
        profile!.uid,
      );
      for (final assignment in assignments) {
        final routine = await RoutineService.loadRoutine(
          assignment.trainerId,
          assignment.rutinaId,
        );
        if (routine != null) {
          assignedRoutines.add(MapEntry(assignment.trainerName, routine));
        }
      }
      // Cargar trainers vinculados
      final linkedAlumnos = await LinkService.getLinkedTrainers(profile.uid);
      linkedTrainers = linkedAlumnos;
    }

    if (!mounted) return;
    setState(() {
      _profile = profile;
      _myRoutines = myRoutines;
      _assignedRoutines = assignedRoutines;
      _linkedTrainers = linkedTrainers;
      _loading = false;
    });

    _checkUnlinkedTrainerRoutines();
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

  void _showShareDialog(Routine routine) {
    if (_profile == null) return;
    if (_linkedTrainers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tenés trainers vinculados para compartir'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundAppBar,
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
              'COMPARTIR CON TRAINER',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            ..._linkedTrainers.map(
              (trainer) => GestureDetector(
                onTap: () async {
                  final alreadyShared =
                      await RoutineService.isRoutineSharedWithTrainer(
                        trainerId: trainer.uid,
                        alumnoId: _profile!.uid,
                        rutinaId: routine.id,
                      );

                  if (alreadyShared) {
                    if (context.mounted) Navigator.pop(context);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Ya compartiste esta rutina con ${trainer.name}',
                          ),
                        ),
                      );
                    }
                    return;
                  }

                  await RoutineService.shareRoutineWithTrainer(
                    trainerId: trainer.uid,
                    trainerName: trainer.name,
                    alumnoId: _profile!.uid,
                    alumnoName: _profile!.name,
                    rutinaId: routine.id,
                  );

                  if (context.mounted) Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Rutina compartida con ${trainer.name}'),
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.2,
                        ),
                        child: Text(
                          trainer.name[0].toUpperCase(),
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        trainer.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.share,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAlumno = _profile?.role == 'alumno';

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
                    (entry) => _buildRoutineCard(
                      entry.value,
                      trainerName: entry.key,
                      assigned: true,
                    ),
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
                    (r) => _buildRoutineCard(
                      r,
                      assigned: false,
                      canShare: isAlumno,
                    ),
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

  Widget _buildRoutineCard(
    Routine routine, {
    required bool assigned,
    String? trainerName,
    bool canShare = false,
  }) {
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
                  if (trainerName != null)
                    Text(
                      'Trainer: $trainerName',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
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
            if (canShare)
              IconButton(
                icon: const Icon(
                  Icons.share,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => _showShareDialog(routine),
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

  Future<void> _checkUnlinkedTrainerRoutines() async {
    if (_profile?.role != 'alumno') return;
    if (_assignedRoutines.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final linkedTrainerIds = _linkedTrainers.map((t) => t.uid).toSet();

    final assignments = await RoutineService.getAssignedToAlumno(_profile!.uid);
    final unlinkedAssignments = assignments
        .where((a) => !linkedTrainerIds.contains(a.trainerId))
        .toList();

    if (unlinkedAssignments.isEmpty) return;

    // Verificar si ya se mostró el aviso para estos trainers
    final unlinkedKey = unlinkedAssignments
        .map((a) => a.trainerId)
        .toSet()
        .join('_');
    final shownKey = 'unlinked_shown_${_profile!.uid}_$unlinkedKey';
    final alreadyShown = prefs.getBool(shownKey) ?? false;
    if (alreadyShown) return;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundAppBar,
        title: const Text(
          'Rutinas de trainers desvinculados',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tenés rutinas asignadas por trainers con los que ya no estás vinculado.\n\n¿Querés eliminarlas?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await prefs.setBool(shownKey, true);
              Navigator.pop(context);
            },
            child: const Text(
              'Mantener',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () async {
              await prefs.setBool(shownKey, true);
              Navigator.pop(context);
              for (final assignment in unlinkedAssignments) {
                await RoutineService.deleteAssignedRoutinesByTrainer(
                  trainerId: assignment.trainerId,
                  alumnoId: _profile!.uid,
                );
              }
              await _loadData();
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
}
