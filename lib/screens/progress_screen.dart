import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/exercise.dart';
import 'package:mjolnir/screens/progress_detail_screen.dart';
import 'package:mjolnir/services/routine_service.dart';
import 'package:mjolnir/services/stats_service.dart';
import 'package:mjolnir/screens/body_weight_screen.dart';

class ProgressScreen extends StatefulWidget {
  final String? viewAsUid;
  final String? title;

  const ProgressScreen({super.key, this.viewAsUid, this.title});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  List<Exercise> exercises = [];
  Map<String, double> _records = {};
  Map<String, Map<String, double>> _monthlyProgress = {};
  bool _loading = true;
  late TabController _tabController;
  Map<String, List<Map<String, dynamic>>> _sessions = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final saved = await RoutineService.loadExercises();
    final records = await StatsService.getPersonalRecords(
      uid: widget.viewAsUid,
    );
    final monthly = await StatsService.getMonthlyProgress(
      uid: widget.viewAsUid,
    );
    final sessions = await StatsService.getSessionHistory(
      uid: widget.viewAsUid,
    );

    if (!mounted) return;
    setState(() {
      exercises = saved;
      _records = records;
      _monthlyProgress = monthly;
      _loading = false;
      _sessions = sessions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title ?? 'Progreso'),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'EJERCICIOS'),
            Tab(text: 'ESTADÍSTICAS'),
            Tab(text: 'PESO'),
            Tab(text: 'SESIONES'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildExerciseList(),
                _buildStats(),
                _buildBodyWeight(),
                _buildSessions(),
              ],
            ),
    );
  }

  Widget _buildExerciseList() {
    if (exercises.isEmpty) {
      return const Center(
        child: Text(
          'No hay ejercicios todavía.\nCreá uno desde la pantalla Ejercicios.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 15),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProgressDetailScreen(
                exercise: exercise,
                viewAsUid: widget.viewAsUid,
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.show_chart,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (exercise.muscle.isNotEmpty)
                        Text(
                          exercise.muscle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_records.containsKey(exercise.name))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PR ${_records[exercise.name]!.toInt()} kg',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStats() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Récords personales
        if (_records.isNotEmpty) ...[
          _sectionLabel('RÉCORDS PERSONALES'),
          const SizedBox(height: 12),
          ..._records.entries.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value.toInt()} kg',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Progreso mensual
        if (_monthlyProgress.isNotEmpty) ...[
          _sectionLabel('PROGRESO MENSUAL'),
          const SizedBox(height: 12),
          ..._monthlyProgress.entries.map((entry) {
            final diff = entry.value['diff']!;
            final isPositive = diff >= 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: isPositive ? AppColors.secondary : Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Mes anterior: ${entry.value['lastMonth']!.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${entry.value['thisMonth']!.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${isPositive ? '+' : ''}${diff.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          color: isPositive
                              ? AppColors.secondary
                              : Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
        ],

        if (_records.isEmpty && _monthlyProgress.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 60),
              child: Text(
                'Todavía no hay estadísticas.\nEmpezá a registrar pesos en tus rutinas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBodyWeight() {
    return BodyWeightScreen(viewAsUid: widget.viewAsUid, embedded: true);
  }

  Widget _buildSessions() {
    if (_sessions.isEmpty) {
      return const Center(
        child: Text(
          'Todavía no hay sesiones registradas.\nEmpezá a cargar pesos en tus rutinas.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final date = _sessions.keys.elementAt(index);
        final entries = _sessions[date]!;

        // Agrupar por ejercicio
        final Map<String, double> exerciseMax = {};
        for (final entry in entries) {
          final name = entry['exerciseName'] as String;
          final weight = (entry['weight'] as num).toDouble();
          if (!exerciseMax.containsKey(name) || exerciseMax[name]! < weight) {
            exerciseMax[name] = weight;
          }
        }

        // Formatear fecha
        final parts = date.split('-');
        final formatted = '${parts[2]}/${parts[1]}/${parts[0]}';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatted,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${exerciseMax.length} ejercicios',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              ...exerciseMax.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        color: AppColors.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        'Máx: ${entry.value} kg',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
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
}
