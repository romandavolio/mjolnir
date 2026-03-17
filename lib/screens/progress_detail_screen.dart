import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/exercise.dart';
import 'package:mjolnir/models/weight_entry.dart';
import 'package:mjolnir/services/storage_service.dart';

class ProgressDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ProgressDetailScreen({super.key, required this.exercise});

  @override
  State<ProgressDetailScreen> createState() => _ProgressDetailScreenState();
}

class _ProgressDetailScreenState extends State<ProgressDetailScreen> {
  List<WeightEntry> history = [];
  String _unit = 'kg';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final saved =
        await StorageService.loadWeightHistory(widget.exercise.name);
    final unit = await StorageService.loadUnit();
    setState(() {
      history = saved;
      _unit = unit;
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
        title: Text(widget.exercise.name),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.exercise.muscle.isNotEmpty ? widget.exercise.muscle : 'Sin músculo asignado',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            if (history.length < 2)
              Expanded(
                child: Center(
                  child: Text(
                    history.isEmpty
                        ? 'Todavía no hay registros.\nGuardá un peso desde Rutinas para empezar.'
                        : 'Necesitás al menos 2 registros para ver el gráfico.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 15),
                  ),
                ),
              )
            else
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (_) =>
                          FlLine(color: Colors.white10, strokeWidth: 1),
                      getDrawingVerticalLine: (_) =>
                          FlLine(color: Colors.white10, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.white10),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, _) => Text(
                            '${value.toInt()} $_unit',
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, _) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _formatDate(value.toInt()),
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 10),
                            ),
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
                          color: AppColors.primary.withValues(alpha: 0.15),
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
