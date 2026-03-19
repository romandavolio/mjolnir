import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/user_profile.dart';
import 'package:mjolnir/screens/body_weight_screen.dart';
import 'package:mjolnir/screens/profile_edit_screen.dart';

class ProfileScreen extends StatelessWidget {
  final UserProfile profile;

  const ProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileEditScreen(profile: profile),
              ),
            ),
            child: Text('Editar',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar y nombre
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(
                      profile.name[0].toUpperCase(),
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 36,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(profile.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      profile.role == 'trainer' ? 'Trainer' : 'Alumno',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Datos físicos
            if (profile.height != null ||
                profile.weight != null ||
                profile.birthDate != null) ...[
              _sectionLabel('DATOS FÍSICOS'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Column(
                  children: [
                    if (profile.age != null || profile.height != null)
                      _dataRow([
                        if (profile.age != null)
                          _dataItem('Edad', '${profile.age} años'),
                        if (profile.height != null)
                          _dataItem(
                              'Altura', '${profile.height!.toInt()} cm'),
                      ]),
                    if (profile.weight != null || profile.targetWeight != null)
                      _dataRow([
                        if (profile.weight != null)
                          _dataItem(
                              'Peso actual', '${profile.weight!.toInt()} kg'),
                        if (profile.targetWeight != null)
                          _dataItem('Peso objetivo',
                              '${profile.targetWeight!.toInt()} kg'),
                      ]),
                    if (profile.birthDate != null)
                      _dataRow([
                        _dataItem('Nacimiento',
                            '${profile.birthDate!.day}/${profile.birthDate!.month}/${profile.birthDate!.year}'),
                      ]),
                    if (profile.biologicalSex != null)
                      _dataRow([
                        _dataItem('Sexo', profile.biologicalSex!),
                      ]),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Entrenamiento
            if (profile.experienceLevel != null || profile.goal != null) ...[
              _sectionLabel('ENTRENAMIENTO'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Column(
                  children: [
                    if (profile.experienceLevel != null)
                      _dataRow([
                        _dataItem('Nivel', profile.experienceLevel!),
                      ]),
                    if (profile.goal != null)
                      _dataRow([
                        _dataItem('Objetivo', profile.goal!),
                      ]),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Lesiones
            if (profile.injuries != null) ...[
              _sectionLabel('LESIONES / LIMITACIONES'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Text(profile.injuries!,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
              ),
              const SizedBox(height: 24),
            ],

            // Historial de peso corporal
            _sectionLabel('PESO CORPORAL'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const BodyWeightScreen()),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.monitor_weight_outlined,
                        color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Ver historial de peso corporal',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5));
  }

  Widget _dataRow(List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: items
            .expand((item) =>
                [Expanded(child: item), const SizedBox(width: 12)])
            .take(items.length * 2 - 1)
            .toList(),
      ),
    );
  }

  Widget _dataItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}