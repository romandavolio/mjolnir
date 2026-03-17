import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/models/user_profile.dart';
import 'package:mjolnir/services/auth_service.dart';
import 'package:mjolnir/services/link_service.dart';
import 'package:mjolnir/services/user_service.dart';
import 'package:mjolnir/screens/alumno_detail_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<UserProfile> _linkedAlumnos = [];
  List<UserProfile> _searchResults = [];
  final _searchController = TextEditingController();
  bool _loading = true;
  bool _searching = false;
  UserProfile? _trainerProfile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await UserService.getCurrentProfile();
    final alumnos = await LinkService.getLinkedAlumnos(
      AuthService.currentUser!.uid,
    );
    setState(() {
      _trainerProfile = profile;
      _linkedAlumnos = alumnos;
      _loading = false;
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    final results = await UserService.searchUsers(query);
    setState(() {
      _searchResults = results.where((u) => u.role == 'alumno').toList();
      _searching = false;
    });
  }

  Future<void> _sendRequest(UserProfile alumno) async {
    if (_trainerProfile == null) return;

    final exists = await LinkService.requestExists(
      trainerId: _trainerProfile!.uid,
      alumnoId: alumno.uid,
    );

    if (exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya existe una solicitud para este alumno'),
          ),
        );
      }
      return;
    }

    await LinkService.sendRequest(trainer: _trainerProfile!, alumno: alumno);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud enviada a ${alumno.name}'),
          backgroundColor: AppColors.primary.withValues(alpha: 0.8),
        ),
      );
      _searchController.clear();
      setState(() => _searchResults = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alumnos'),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Buscador
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: _search,
                    decoration: InputDecoration(
                      hintText: 'Buscar alumno por nombre...',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _searching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
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

                  // Resultados de búsqueda
                  if (_searchResults.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'RESULTADOS',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._searchResults.map(
                      (alumno) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.2,
                              ),
                              child: Text(
                                alumno.name[0].toUpperCase(),
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alumno.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    alumno.email,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AlumnoDetailScreen(alumno: alumno),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.primary),
                                ),
                                child: Text(
                                  'Vincular',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Alumnos vinculados
                  const Text(
                    'MIS ALUMNOS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _linkedAlumnos.isEmpty
                        ? const Center(
                            child: Text(
                              'No tenés alumnos vinculados todavía.\nBuscá un alumno para enviarle una solicitud.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 15,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _linkedAlumnos.length,
                            itemBuilder: (context, index) {
                              final alumno = _linkedAlumnos[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.primary
                                          .withValues(alpha: 0.2),
                                      child: Text(
                                        alumno.name[0].toUpperCase(),
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            alumno.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            alumno.email,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
