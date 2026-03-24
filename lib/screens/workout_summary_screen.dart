import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/routine.dart';
import 'package:mjolnir/services/stats_service.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  final Routine routine;
  final Duration duration;
  final DateTime sessionStart;

  const WorkoutSummaryScreen({
    super.key,
    required this.routine,
    required this.duration,
    required this.sessionStart,
  });

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  Map<String, double> _personalRecords = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await StatsService.getPersonalRecords();
    if (!mounted) return;
    setState(() {
      _personalRecords = records;
      _loading = false;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    if (seconds == 0) return '${minutes}m';
    return '${minutes}m ${seconds}s';
  }

  double _calculateVolume() {
    double total = 0;
    for (final re in widget.routine.exercises) {
      for (final serie in re.series) {
        if (serie.weight > 0) {
          total += serie.weight * serie.reps;
        }
      }
    }
    return total;
  }

  bool _isPersonalRecord(String exerciseName, double weight) {
    final record = _personalRecords[exerciseName];
    if (record == null) return false;
    return weight >= record;
  }

  @override
  Widget build(BuildContext context) {
    final volume = _calculateVolume();
    final exercisesWithWeights = widget.routine.exercises
        .where((re) => re.series.any((s) => s.weight > 0))
        .toList();

    // Récords batidos en esta sesión
    final newRecords = <String>[];
    for (final re in exercisesWithWeights) {
      final maxWeight = re.series
          .map((s) => s.weight)
          .reduce((a, b) => a > b ? a : b);
      if (_isPersonalRecord(re.exercise.name, maxWeight)) {
        newRecords.add(re.exercise.name);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Resumen'),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(
                context, (route) => route.isFirst),
            child: Text('Cerrar',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.emoji_events,
                          color: AppColors.primary, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        '¡Rutina completada!',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.routine.name,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats rápidas
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.timer_outlined,
                        label: 'Duración',
                        value: _formatDuration(widget.duration),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        icon: Icons.fitness_center,
                        label: 'Ejercicios',
                        value: '${exercisesWithWeights.length}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        icon: Icons.bar_chart,
                        label: 'Volumen',
                        value: '${volume.toInt()} kg',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Récords personales batidos
                if (newRecords.isNotEmpty) ...[
                  const Text('RÉCORDS BATIDOS 🏆',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  ...newRecords.map((name) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.emoji_events,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 12),
                            Text(name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text(
                              '${_personalRecords[name]!.toStringAsFixed(1)} kg',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                ],

                // Ejercicios con pesos
                const Text('EJERCICIOS',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5)),
                const SizedBox(height: 12),
                ...exercisesWithWeights.map((re) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color:
                                AppColors.primary.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                re.exercise.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                              const Spacer(),
                              if (newRecords.contains(re.exercise.name))
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('PR 🏆',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...re.series.asMap().entries.map((entry) {
                            final i = entry.key;
                            final serie = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.15),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text('${i + 1}',
                                          style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('${serie.reps} reps',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13)),
                                  const Spacer(),
                                  Text(
                                    serie.weight == 0
                                        ? '—'
                                        : '${serie.weight} kg',
                                    style: TextStyle(
                                        color: serie.weight > 0
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    )),
              ],
            ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}