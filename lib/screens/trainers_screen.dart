import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/user_profile.dart';
import 'package:mjolnir/services/auth_service.dart';
import 'package:mjolnir/services/link_service.dart';
import 'package:mjolnir/services/notification_service.dart';
import 'package:mjolnir/services/routine_service.dart';
import 'package:mjolnir/services/user_service.dart';

class TrainersScreen extends StatefulWidget {
  const TrainersScreen({super.key});

  @override
  State<TrainersScreen> createState() => _TrainersScreenState();
}

class _TrainersScreenState extends State<TrainersScreen> {
  List<UserProfile> _trainers = [];
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await UserService.getCurrentProfile();
    final trainers = await LinkService.getLinkedTrainers(
      AuthService.currentUser!.uid,
    );
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _trainers = trainers;
      _loading = false;
    });
  }

  void _showUnlinkDialog(UserProfile trainer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundAppBar,
        title: const Text(
          'Desvincular trainer',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Querés desvincularte de ${trainer.name}?',
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
            onPressed: () {
              Navigator.pop(context);
              _showDeleteRoutinesDialog(trainer);
            },
            child: Text(
              'Continuar',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteRoutinesDialog(UserProfile trainer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundAppBar,
        title: const Text(
          '¿Qué hacemos con las rutinas?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Querés eliminar las rutinas que te asignó este trainer?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _unlink(trainer, deleteRoutines: false);
            },
            child: const Text(
              'Mantener rutinas',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _unlink(trainer, deleteRoutines: true);
            },
            child: const Text(
              'Eliminar rutinas',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unlink(
    UserProfile trainer, {
    required bool deleteRoutines,
  }) async {
    if (_profile == null) return;

    // Eliminar la solicitud de vinculación
    await LinkService.unlinkTrainer(
      trainerId: trainer.uid,
      alumnoId: _profile!.uid,
    );

    // Eliminar rutinas si el alumno lo eligió
    if (deleteRoutines) {
      await RoutineService.deleteAssignedRoutinesByTrainer(
        trainerId: trainer.uid,
        alumnoId: _profile!.uid,
      );
    }

    // Notificar al trainer
    await NotificationService.sendUnlinkNotification(
      targetUid: trainer.uid,
      senderName: _profile!.name,
      role: 'alumno',
    );

    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Te desvinculaste de ${trainer.name}'),
          backgroundColor: AppColors.primary.withValues(alpha: 0.8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trainers'),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _trainers.isEmpty
          ? const Center(
              child: Text(
                'No tenés trainers vinculados.\nAceptá una solicitud para vincularte.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _trainers.length,
              itemBuilder: (context, index) {
                final trainer = _trainers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.2,
                        ),
                        child: Text(
                          trainer.name[0].toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trainer.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              trainer.email,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showUnlinkDialog(trainer),
                        child: const Text(
                          'Desvincular',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
