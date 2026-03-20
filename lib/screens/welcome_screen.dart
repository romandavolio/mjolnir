import 'package:flutter/material.dart';
import 'package:mjolnir/components/grid_button.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/user_profile.dart';
import 'package:mjolnir/screens/auth/login_screen.dart';
import 'package:mjolnir/screens/config_screen.dart';
import 'package:mjolnir/screens/exercise_screen.dart';
import 'package:mjolnir/screens/progress_screen.dart';
import 'package:mjolnir/screens/routine_screen.dart';
import 'package:mjolnir/services/auth_service.dart';
import 'package:mjolnir/services/user_service.dart';
import 'package:mjolnir/screens/students_screen.dart';
import 'package:mjolnir/screens/notifications_screen.dart';
import 'package:mjolnir/services/notification_service.dart';
import 'package:mjolnir/screens/profile_screen.dart';
import 'package:mjolnir/screens/trainers_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  UserProfile? _profile;
  bool _loading = true;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    NotificationService.initialize();
  }

  Future<void> _loadProfile() async {
    final profile = await UserService.getCurrentProfile();
    final notifications = await NotificationService.getUnreadNotifications();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _unreadNotifications = notifications.length;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 8),
                    _buildDivider(),
                    const SizedBox(height: 28),
                    Expanded(child: _buildGrid()),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CustomPaint(painter: _HammerPainter()),
            ),
            const SizedBox(width: 12),
            const Text(
              'MJOLNIR',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
              ),
            ),
            const Spacer(),
            // Nombre y logout
            if (_profile != null)
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(profile: _profile!),
                      ),
                    ),
                    child: Text(
                      _profile!.name.split(' ').first,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_profile!.role == 'alumno')
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                        _loadProfile();
                      },
                      child: Stack(
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.textSecondary,
                            size: 24,
                          ),
                          if (_unreadNotifications > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _logout,
                    child: const Icon(
                      Icons.logout,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 44),
          child: Text(
            _profile?.role.toUpperCase() == 'TRAINER'
                ? 'PANEL DE TRAINER'
                : 'TU ENTRENAMIENTO, TU PROGRESO',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

Widget _buildGrid() {
  final isTrainer = _profile?.role == 'trainer';

  final buttons = [
    GridButton(
      label: 'RUTINAS',
      subtitle: isTrainer ? 'Gestionar rutinas' : 'Ver mis rutinas',
      icon: Icons.fitness_center,
      onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const RoutineScreen())),
    ),
    GridButton(
      label: 'EJERCICIOS',
      subtitle: 'Catálogo',
      icon: Icons.format_list_bulleted,
      onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ExerciseScreen())),
    ),
    GridButton(
      label: 'PROGRESO',
      subtitle: 'Ver evolución',
      icon: Icons.show_chart,
      onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ProgressScreen())),
    ),
    GridButton(
      label: isTrainer ? 'ALUMNOS' : 'TRAINERS',
      subtitle: 'Gestionar',
      icon: isTrainer ? Icons.people_outline : Icons.sports,
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => isTrainer
                  ? const StudentsScreen()
                  : const TrainersScreen())),
    ),
    GridButton(
      label: 'ALIMENTACIÓN',
      subtitle: 'Próximamente',
      icon: Icons.restaurant_outlined,
      onPressed: () {},
    ),
    GridButton(
      label: 'CONFIG',
      subtitle: 'Preferencias',
      icon: Icons.settings_outlined,
      onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ConfigScreen())),
    ),
  ];

return GridView.count(
  crossAxisCount: 2,
  mainAxisSpacing: 10,
  crossAxisSpacing: 10,
  childAspectRatio: 1.1,
  physics: const NeverScrollableScrollPhysics(),
  children: buttons,
);
}
}

class _HammerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final darkPaint = Paint()
      ..color = AppColors.complement
      ..style = PaintingStyle.fill;

    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.25,
        size.height * 0.05,
        size.width * 0.6,
        size.height * 0.38,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(headRect, paint);

    final leftRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.02,
        size.height * 0.12,
        size.width * 0.28,
        size.height * 0.24,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(leftRect, paint);

    final handleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.42,
        size.height * 0.42,
        size.width * 0.18,
        size.height * 0.54,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(handleRect, darkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
