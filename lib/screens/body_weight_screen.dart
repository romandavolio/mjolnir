import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/body_weight_entry.dart';
import 'package:mjolnir/services/body_weight_service.dart';

class BodyWeightScreen extends StatefulWidget {
  final String? viewAsUid;
  final String? title;

  const BodyWeightScreen({
    super.key,
    this.viewAsUid,
    this.title,
  });

  @override
  State<BodyWeightScreen> createState() => _BodyWeightScreenState();
}

class _BodyWeightScreenState extends State<BodyWeightScreen> {
  List<BodyWeightEntry> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history =
        await BodyWeightService.loadHistory(uid: widget.viewAsUid);
    if (!mounted) return;
    setState(() {
      _history = history;
      _loading = false;
    });
  }

  void _showAddWeight() {
    double selectedWeight = 70;

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
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.white60)),
                ),
                const Text('REGISTRAR PESO',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () async {
                    await BodyWeightService.addEntry(selectedWeight);
                    Navigator.pop(context);
                    _loadHistory();
                  },
                  child: Text('Guardar',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                  initialItem: (selectedWeight - 30).toInt()),
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                selectedWeight = (30 + index).toDouble();
              },
              children: List.generate(
                171,
                (i) => Center(
                  child: Text('${30 + i} kg',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 20)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<FlSpot> _buildSpots() {
    return _history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();
  }

  String _formatDate(int index) {
    if (index < 0 || index >= _history.length) return '';
    final date = _history[index].date;
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly = widget.viewAsUid != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title ?? 'Peso corporal'),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Último peso registrado
                  if (_history.isNotEmpty) ...[
                    Container(
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Último registro',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                '${_history.last.weight.toInt()} kg',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (_history.length > 1)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Cambio',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                                const SizedBox(height: 4),
                                Builder(builder: (context) {
                                  final diff = _history.last.weight -
                                      _history[_history.length - 2].weight;
                                  final isPositive = diff >= 0;
                                  return Text(
                                    '${isPositive ? '+' : ''}${diff.toStringAsFixed(1)} kg',
                                    style: TextStyle(
                                        color: isPositive
                                            ? Colors.redAccent
                                            : AppColors.secondary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  );
                                }),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Gráfico
                  if (_history.length < 2)
                    Expanded(
                      child: Center(
                        child: Text(
                          _history.isEmpty
                              ? 'No hay registros todavía.\nTocá + para registrar tu peso.'
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
                                  '${value.toInt()} kg',
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
                                color:
                                    AppColors.primary.withValues(alpha: 0.15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: isReadOnly
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: _showAddWeight,
              child: const Icon(Icons.add, color: Colors.black),
            ),
    );
  }
}