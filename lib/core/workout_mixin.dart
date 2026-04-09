import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/serie.dart';
import 'package:mjolnir/models/weight_entry.dart';
import 'package:mjolnir/services/routine_service.dart';
import 'package:vibration/vibration.dart';

mixin WorkoutMixin<T extends StatefulWidget> on State<T> {
  String unit = 'kg';
  int? activeTimer;
  bool timerRunning = false;

  // --- Timer ---

  void startTimer(int seconds) {
    setState(() {
      activeTimer = seconds;
      timerRunning = true;
    });
    runTimer();
  }

  void runTimer() async {
    while (timerRunning && activeTimer != null && activeTimer! > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        if (activeTimer != null) activeTimer = activeTimer! - 1;
        if (activeTimer == 0) {
          timerRunning = false;
          vibrate();
        }
      });
    }
  }

  void stopTimer() {
    setState(() {
      activeTimer = null;
      timerRunning = false;
    });
  }

  void vibrate() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(pattern: [0, 400, 200, 400]);
    }
  }

  // --- Timer picker ---

  void showTimerPicker(
    BuildContext context,
    String exerciseName,
    int currentSeconds,
  ) {
    int tempSeconds = currentSeconds;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundAppBar,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
                const Text(
                  'DESCANSO',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await RoutineService.saveRestTimer(
                      exerciseName,
                      tempSeconds,
                    );
                    startTimer(tempSeconds);
                  },
                  child: Text(
                    'Iniciar',
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
                initialItem: (tempSeconds ~/ 5) - 1,
              ),
              itemExtent: 40,
              looping: true,
              onSelectedItemChanged: (index) {
                tempSeconds = (index + 1) * 5;
              },
              children: List.generate(60, (i) {
                final secs = (i + 1) * 5;
                final mins = secs ~/ 60;
                final remaining = secs % 60;
                final label = mins > 0
                    ? remaining > 0
                          ? '${mins}m ${remaining}s'
                          : '${mins}m'
                    : '${secs}s';
                return Center(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Selector de peso ---
  void showWeightPicker(
    BuildContext context, {
    required Serie serie,
    required String exerciseName,
    required int serieIndex,
    required String rutinaId,
    Serie? originalSerie,
    Function(double)? onWeightSaved,
  }) {
    // Usar el peso de la serie original como referencia
    final referenceSerie = originalSerie ?? serie;
    int selectedInt = referenceSerie.weight.toInt();
    int selectedDecimal = ((referenceSerie.weight - selectedInt) * 100).round();
    const decimals = [0, 25, 50, 75];
    if (!decimals.contains(selectedDecimal)) selectedDecimal = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundAppBar,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
                Text(
                  '${serie.reps} REPS',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final newWeight = selectedInt + selectedDecimal / 100.0;
                    final targetSerie = originalSerie ?? serie;
                    setState(() => targetSerie.weight = newWeight);
                    Navigator.pop(ctx);
                    await RoutineService.saveSerieWeight(
                      exerciseName: exerciseName,
                      serieIndex: serieIndex,
                      weight: newWeight,
                      rutinaId: rutinaId,
                    );
                    await RoutineService.addWeightEntry(
                      '${exerciseName}_serie_$serieIndex',
                      newWeight,
                    );
                    setState(() {});
                    final timerSeconds = await RoutineService.loadRestTimer(
                      exerciseName,
                    );
                    if (mounted) startTimer(timerSeconds);
                    if (onWeightSaved != null) onWeightSaved(newWeight);
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 200,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedInt,
                    ),
                    itemExtent: 36,
                    looping: true,
                    onSelectedItemChanged: (index) {
                      selectedInt = index;
                    },
                    children: List.generate(
                      501,
                      (i) => Center(
                        child: Text(
                          '$i',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Text(
                  '.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 200,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: decimals.indexOf(selectedDecimal),
                    ),
                    itemExtent: 36,
                    looping: true,
                    onSelectedItemChanged: (index) {
                      selectedDecimal = decimals[index];
                    },
                    children: decimals
                        .map(
                          (d) => Center(
                            child: Text(
                              '$d',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Historial de serie ---

  void showSerieHistory(
    BuildContext context,
    String exerciseName,
    int serieIndex,
  ) async {
    final history = await RoutineService.loadSerieHistory(
      exerciseName: exerciseName,
      serieIndex: serieIndex,
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundAppBar,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HISTORIAL — SERIE ${serieIndex + 1}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            if (history.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No hay registros todavía.',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
              )
            else
              ...history.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${entry.weight} $unit',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // --- Banner del timer ---

  Widget buildTimerBanner({String? exerciseName}) {
    if (activeTimer == null) return const SizedBox.shrink();
    return Positioned(
      bottom: 80,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundAppBar,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: activeTimer! > 0 ? AppColors.primary : AppColors.secondary,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              activeTimer! > 0
                  ? Icons.timer_outlined
                  : Icons.check_circle_outline,
              color: activeTimer! > 0 ? AppColors.primary : AppColors.secondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeTimer! > 0
                        ? 'Descansando...'
                        : '¡Listo para la siguiente serie!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (exerciseName != null)
                    Text(
                      exerciseName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            if (activeTimer! > 0)
              Text(
                '${activeTimer}s',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: stopTimer,
              child: const Icon(
                Icons.close,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
