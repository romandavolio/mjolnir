import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/services/routine_service.dart';
import 'package:mjolnir/screens/profile_edit_screen.dart';
import 'package:mjolnir/services/user_service.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  String _selectedUnit = 'kg';

  @override
  void initState() {
    super.initState();
    _loadUnit();
  }

  Future<void> _loadUnit() async {
    final unit = await RoutineService.loadUnit();
    setState(() => _selectedUnit = unit);
  }

  Future<void> _selectUnit(String unit) async {
    await RoutineService.saveUnit(unit);
    setState(() => _selectedUnit = unit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Editar perfil
            GestureDetector(
              onTap: () async {
                final profile = await UserService.getCurrentProfile();
                if (profile != null && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileEditScreen(profile: profile),
                    ),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
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
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.person_outline,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Editar perfil',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            // Unidad de peso
            const Text(
              'UNIDAD DE PESO',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildUnitOption('kg', 'Kilogramos')),
                const SizedBox(width: 12),
                Expanded(child: _buildUnitOption('lb', 'Libras')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitOption(String unit, String label) {
    final isSelected = _selectedUnit == unit;
    return GestureDetector(
      onTap: () => _selectUnit(unit),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              unit,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.7)
                    : AppColors.textSecondary,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
