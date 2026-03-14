import 'package:flutter/material.dart';
import 'package:mjolnir/components/menu_button.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/screens/exercise_screen.dart';
import 'package:mjolnir/screens/routine_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: 2, // 2 columnas → 2x2
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            MenuButton(
              title: 'RUTINAS',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RoutineScreen()),
                );
              },
            ),
            MenuButton(
              title: 'EJERCICIOS',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExerciseScreen()),
                );
              },
            ),
            MenuButton(title: 'PROGRESO', onPressed: () {}),
            MenuButton(title: 'CONFIGURACION', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
