import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/weight_entry.dart';
import 'package:mjolnir/models/exercise.dart';
import 'package:mjolnir/services/storage_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<Exercise> exercises = [];
  Exercise? selectedExercise;
  List<WeightEntry> history = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final saved = await StorageService.loadExercises();
    setState(() {
      exercises = saved;
      if (saved.isNotEmpty) {
        selectedExercise = saved.first;
        _loadHistory(saved.first.name);
      }
    });
  }

  Future<void> _loadHistory(String exerciseName) async {
    final saved = await StorageService.loadWeightHistory(exerciseName);
    setState(() {
      history = saved;
    });
  }

  List<FlSpot> _buildSpots() {
    return history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();
  }

  String _formatDate(int index) {
    if (index < 0 || index >= history.length) return '';
    final date = history[index].date;
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Progreso'),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Selector de ejercicio
            DropdownButtonFormField<Exercise>(
              value: selectedExercise,
              dropdownColor: AppColors.backgroundAppBar,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Ejercicio',
                labelStyle: TextStyle(color: AppColors.primary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              items: exercises.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e.name),
                );
              }).toList(),
              onChanged: (exercise) {
                if (exercise == null) return;
                setState(() => selectedExercise = exercise);
                _loadHistory(exercise.name);
              },
            ),

            const SizedBox(height: 32),

            // Gráfico o mensaje vacío
            if (history.length < 2)
              Expanded(
                child: Center(
                  child: Text(
                    history.isEmpty
                        ? 'Todavía no hay registros para este ejercicio.\nGuardá un peso desde Rutinas para empezar.'
                        : 'Necesitás al menos 2 registros para ver el gráfico.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white60, fontSize: 15),
                  ),
                ),
              )
            else
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Colors.white10,
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (_) => FlLine(
                        color: Colors.white10,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.white10),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, _) => Text(
                            '${value.toInt()} kg',
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) => Text(
                            _formatDate(value.toInt()),
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 10),
                          ),
                        ),
                      ),
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _buildSpots(),
                        isCurved: true,
                        preventCurveOverShooting: true,
                        curveSmoothness: 0.1,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (_, __, ___, ____) =>
                              FlDotCirclePainter(
                            radius: 5,
                            color: AppColors.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}