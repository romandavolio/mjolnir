import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/user_profile.dart';
import 'package:mjolnir/screens/welcome_screen.dart';
import 'package:mjolnir/services/auth_service.dart';
import 'package:flutter/cupertino.dart';

class ProfileSetupScreen extends StatefulWidget {
  final UserProfile profile;

  const ProfileSetupScreen({super.key, required this.profile});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  double _height = 170;
  double _weight = 70;
  double _targetWeight = 70;
  final _injuriesController = TextEditingController();

  String? _selectedSex;
  String? _selectedLevel;
  String? _selectedGoal;
  bool _loading = false;
  DateTime? _selectedBirthDate;

  final List<String> _sexOptions = ['Masculino', 'Femenino'];
  final List<String> _levelOptions = ['Principiante', 'Intermedio', 'Avanzado'];
  final List<String> _goalOptions = [
    'Perder peso',
    'Ganar músculo',
    'Mantenimiento',
    'Rendimiento',
  ];

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final updated = widget.profile.copyWith(
        height: _height,
        weight: _weight,
        birthDate: _selectedBirthDate,
        targetWeight: _targetWeight,
        biologicalSex: _selectedSex,
        experienceLevel: _selectedLevel,
        goal: _selectedGoal,
        injuries: _injuriesController.text.trim().isEmpty
            ? null
            : _injuriesController.text.trim(),
      );
      await AuthService.updateProfile(updated);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (_) => false,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.backgroundAppBar,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedBirthDate = picked);
  }

  void _showPicker({
    required String title,
    required double initialValue,
    required int minValue,
    required int maxValue,
    required String suffix,
    required Function(double) onSelected,
  }) {
    double tempValue = initialValue;
    final initialIndex = (initialValue - minValue).toInt().clamp(
      0,
      maxValue - minValue,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundAppBar,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onSelected(tempValue);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Listo',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: initialIndex,
              ),
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                tempValue = (minValue + index).toDouble();
              },
              children: List.generate(
                maxValue - minValue + 1,
                (i) => Center(
                  child: Text(
                    '${minValue + i} $suffix',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tu perfil'),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (_) => false,
            ),
            child: Text(
              'Omitir',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completá tu perfil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Esta información ayuda a tu trainer a conocerte mejor.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 28),

            // Datos básicos
            _sectionLabel('DATOS BÁSICOS'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showPicker(
                      title: 'Altura',
                      initialValue: _height,
                      minValue: 100,
                      maxValue: 220,
                      suffix: 'cm',
                      onSelected: (v) => setState(() => _height = v),
                    ),
                    child: _buildPickerField('Altura', '${_height.toInt()} cm'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickBirthDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedBirthDate == null
                                  ? 'Nacimiento'
                                  : '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}',
                              style: TextStyle(
                                color: _selectedBirthDate == null
                                    ? AppColors.textSecondary
                                    : Colors.white,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showPicker(
                      title: 'Peso actual',
                      initialValue: _weight,
                      minValue: 30,
                      maxValue: 200,
                      suffix: 'kg',
                      onSelected: (v) => setState(() => _weight = v),
                    ),
                    child: _buildPickerField(
                      'Peso actual',
                      '${_weight.toInt()} kg',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showPicker(
                      title: 'Peso objetivo',
                      initialValue: _targetWeight,
                      minValue: 30,
                      maxValue: 200,
                      suffix: 'kg',
                      onSelected: (v) => setState(() => _targetWeight = v),
                    ),
                    child: _buildPickerField(
                      'Peso objetivo',
                      '${_targetWeight.toInt()} kg',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sexo biológico
            _sectionLabel('SEXO BIOLÓGICO'),
            const SizedBox(height: 12),
            Row(
              children: _sexOptions.map((sex) {
                final isSelected = _selectedSex == sex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSex = sex),
                    child: Container(
                      margin: EdgeInsets.only(
                        right: sex == _sexOptions.first ? 12 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          sex,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Nivel de experiencia
            _sectionLabel('NIVEL DE EXPERIENCIA'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _levelOptions.map((level) {
                final isSelected = _selectedLevel == level;
                return GestureDetector(
                  onTap: () => setState(() => _selectedLevel = level),
                  child: _buildChip(level, isSelected),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Objetivo
            _sectionLabel('OBJETIVO'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _goalOptions.map((goal) {
                final isSelected = _selectedGoal == goal;
                return GestureDetector(
                  onTap: () => setState(() => _selectedGoal = goal),
                  child: _buildChip(goal, isSelected),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Lesiones
            _sectionLabel('LESIONES O LIMITACIONES (opcional)'),
            const SizedBox(height: 12),
            TextField(
              controller: _injuriesController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ej: Dolor lumbar, rodilla derecha...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Guardar perfil',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPickerField(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
