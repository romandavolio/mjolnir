import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';
import 'package:mjolnir/core/muscle_data.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  List<Map<String, String>> get _searchResults {
    if (_searchQuery.isEmpty) return [];
    final results = <Map<String, String>>[];
    for (final muscle in ExerciseCatalog.muscles) {
      for (final element in ExerciseCatalog.elementsFor(muscle).keys) {
        for (final accompaniment in ExerciseCatalog.accompanimentFor(
          muscle,
          element,
        ).keys) {
          for (final exercise in ExerciseCatalog.exercisesFor(
            muscle,
            element,
            accompaniment,
          )) {
            if (exercise.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                muscle.toLowerCase().contains(_searchQuery.toLowerCase())) {
              results.add({
                'name': exercise,
                'muscle': muscle,
                'element': element,
                'accompaniment': accompaniment,
              });
            }
          }
        }
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ejercicios'),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Buscar ejercicio...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
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
          ),
          const SizedBox(height: 12),

          // Resultados de búsqueda o lista de músculos
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _searchResults.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron ejercicios.',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 15,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.25,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.fitness_center,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          result['name']!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${result['muscle']} · ${result['element']} · ${result['accompaniment']}',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      const Text(
                        'GRUPO MUSCULAR',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...ExerciseCatalog.muscles.map(
                        (muscle) => GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ExerciseElementScreen(muscle: muscle),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.fitness_center,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  muscle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// Segundo nivel — Elemento
class ExerciseElementScreen extends StatelessWidget {
  final String muscle;

  const ExerciseElementScreen({super.key, required this.muscle});

  @override
  Widget build(BuildContext context) {
    final elements = ExerciseCatalog.elementsFor(muscle);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(muscle),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'ELEMENTO',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...elements.keys.map(
            (element) => GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseAccompanimentScreen(
                    muscle: muscle,
                    element: element,
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
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
                        Icons.sports_gymnastics,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      element,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Tercer nivel — Acompañamiento
class ExerciseAccompanimentScreen extends StatelessWidget {
  final String muscle;
  final String element;

  const ExerciseAccompanimentScreen({
    super.key,
    required this.muscle,
    required this.element,
  });

  @override
  Widget build(BuildContext context) {
    final accompaniments = ExerciseCatalog.accompanimentFor(muscle, element);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(element),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'ACOMPAÑAMIENTO',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...accompaniments.keys.map(
            (accompaniment) => GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseListScreen(
                    muscle: muscle,
                    element: element,
                    accompaniment: accompaniment,
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
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
                        Icons.fitness_center,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      accompaniment,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Cuarto nivel — Lista de ejercicios
class ExerciseListScreen extends StatelessWidget {
  final String muscle;
  final String element;
  final String accompaniment;

  const ExerciseListScreen({
    super.key,
    required this.muscle,
    required this.element,
    required this.accompaniment,
  });

  @override
  Widget build(BuildContext context) {
    final exercises = ExerciseCatalog.exercisesFor(
      muscle,
      element,
      accompaniment,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(accompaniment),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'EJERCICIOS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...exercises.map(
            (exercise) => Container(
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
                      Icons.fitness_center,
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
                          exercise,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$muscle · $element · $accompaniment',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
