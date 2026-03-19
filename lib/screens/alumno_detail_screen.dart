import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/assigned_routine.dart';
import 'package:mjolnir/models/routine.dart';
import 'package:mjolnir/models/user_profile.dart';
import 'package:mjolnir/screens/routine_detail_screen.dart';
import 'package:mjolnir/services/auth_service.dart';
import 'package:mjolnir/services/routine_service.dart';
import 'package:mjolnir/screens/progress_screen.dart';
import 'package:mjolnir/screens/body_weight_screen.dart';

class AlumnoDetailScreen extends StatefulWidget {
  final UserProfile alumno;

  const AlumnoDetailScreen({super.key, required this.alumno});

  @override
  State<AlumnoDetailScreen> createState() => _AlumnoDetailScreenState();
}

class _AlumnoDetailScreenState extends State<AlumnoDetailScreen> {
  List<Routine> _myRoutines = [];
  List<MapEntry<AssignedRoutine, Routine>> _assignedRoutines = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final myRoutines = await RoutineService.loadMyRoutines();
    final assignments = await RoutineService.getAssignedByTrainer(
      AuthService.currentUser!.uid,
      widget.alumno.uid,
    );

    final List<MapEntry<AssignedRoutine, Routine>> assignedWithRoutines = [];
    for (final assignment in assignments) {
      final routine = await RoutineService.loadRoutine(
        assignment.trainerId,
        assignment.rutinaId,
      );
      if (routine != null) {
        assignedWithRoutines.add(MapEntry(assignment, routine));
      }
    }

    if (!mounted) return;
    setState(() {
      _myRoutines = myRoutines;
      _assignedRoutines = assignedWithRoutines;
      _loading = false;
    });
  }

  void _showAssignDialog() {
    final available = _myRoutines
        .where((r) => !_assignedRoutines.any((e) => e.value.id == r.id))
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay rutinas disponibles para asignar'),
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
              'ASIGNAR RUTINA',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            ...available.map(
              (routine) => GestureDetector(
                onTap: () async {
                  await RoutineService.assignRoutine(
                    alumnoId: widget.alumno.uid,
                    rutinaId: routine.id,
                  );
                  Navigator.pop(context);
                  _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '"${routine.name}" asignada a ${widget.alumno.name}',
                        ),
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
                      Icon(
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
                              routine.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                      const Icon(Icons.add, color: AppColors.primary, size: 18),
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

  void _deleteAssignment(AssignedRoutine assignment, Routine routine) async {
    final hasWeights = await RoutineService.routineHasWeights(
      alumnoId: widget.alumno.uid,
      rutinaId: routine.id,
      exercises: routine.exercises,
    );

    if (hasWeights) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se puede eliminar una rutina con pesos cargados'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundAppBar,
        title: const Text(
          'Eliminar rutina',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Querés eliminar "${routine.name}" de este alumno?',
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
              await RoutineService.unassignRoutine(assignment.id);
              Navigator.pop(context);
              _loadData();
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
        title: Text(widget.alumno.name),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info del alumno
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                          child: Text(
                            widget.alumno.name[0].toUpperCase(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.alumno.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.alumno.email,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Datos personales del alumno
                  if (widget.alumno.age != null ||
                      widget.alumno.height != null ||
                      widget.alumno.weight != null ||
                      widget.alumno.goal != null ||
                      widget.alumno.experienceLevel != null ||
                      widget.alumno.injuries != null) ...[
                    const Text(
                      'DATOS PERSONALES',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        children: [
                          if (widget.alumno.age != null ||
                              widget.alumno.height != null)
                            _buildDataRow([
                              if (widget.alumno.age != null)
                                _dataItem('Edad', '${widget.alumno.age} años'),
                              if (widget.alumno.height != null)
                                _dataItem(
                                  'Altura',
                                  '${widget.alumno.height!.toInt()} cm',
                                ),
                            ]),
                          if (widget.alumno.weight != null ||
                              widget.alumno.targetWeight != null)
                            _buildDataRow([
                              if (widget.alumno.weight != null)
                                _dataItem(
                                  'Peso',
                                  '${widget.alumno.weight!.toInt()} kg',
                                ),
                              if (widget.alumno.targetWeight != null)
                                _dataItem(
                                  'Objetivo',
                                  '${widget.alumno.targetWeight!.toInt()} kg',
                                ),
                            ]),
                          if (widget.alumno.experienceLevel != null)
                            _buildDataRow([
                              _dataItem(
                                'Nivel',
                                widget.alumno.experienceLevel!,
                              ),
                            ]),
                          if (widget.alumno.goal != null)
                            _buildDataRow([
                              _dataItem('Meta', widget.alumno.goal!),
                            ]),
                          if (widget.alumno.injuries != null) ...[
                            const Divider(color: Colors.white10),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Lesiones / limitaciones',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.alumno.injuries!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProgressScreen(
                          viewAsUid: widget.alumno.uid,
                          title:
                              'Progreso de ${widget.alumno.name.split(' ').first}',
                        ),
                      ),
                    ),
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
                          color: AppColors.secondary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.show_chart,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Ver progreso del alumno',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right, color: AppColors.secondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BodyWeightScreen(
                          viewAsUid: widget.alumno.uid,
                          title:
                              'Peso de ${widget.alumno.name.split(' ').first}',
                        ),
                      ),
                    ),
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
                          color: AppColors.secondary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.monitor_weight_outlined,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Ver peso corporal',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right, color: AppColors.secondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'RUTINAS ASIGNADAS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _assignedRoutines.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay rutinas asignadas todavía.\nTocá + para asignar una.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 15,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _assignedRoutines.length,
                            itemBuilder: (context, index) {
                              final entry = _assignedRoutines[index];
                              final assignment = entry.key;
                              final routine = entry.value;
                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RoutineDetailScreen(
                                        routine: routine,
                                        onSave: () =>
                                            RoutineService.saveRoutine(routine),
                                        viewAsUid: widget.alumno.uid,
                                      ),
                                    ),
                                  );
                                  _loadData();
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.25,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.fitness_center,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              routine.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
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
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                          size: 20,
                                        ),
                                        onPressed: () => _deleteAssignment(
                                          assignment,
                                          routine,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: AppColors.textSecondary,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAssignDialog,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildDataRow(List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: items
            .expand(
              (item) => [Expanded(child: item), const SizedBox(width: 12)],
            )
            .take(items.length * 2 - 1)
            .toList(),
      ),
    );
  }

  Widget _dataItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
