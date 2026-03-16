import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mjolnir/models/exercise.dart';
import 'package:mjolnir/models/weight_entry.dart';

class StorageService {

  // --- Pesos de ejercicios en rutinas ---

  static Future<void> saveWeight(String exerciseName, double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('weight_$exerciseName', weight);
    await addWeightEntry(exerciseName, weight);
  }

  static Future<double?> loadWeight(String exerciseName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('weight_$exerciseName');
  }

  // --- Catálogo de ejercicios personalizados ---

  static Future<void> saveExercises(List<Exercise> exercises) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = exercises.map((e) => e.toJson()).toList();
    await prefs.setString('custom_exercises', jsonEncode(jsonList));
  }

  static Future<List<Exercise>> loadExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('custom_exercises');
    if (jsonString == null) return [];
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((e) => Exercise.fromJson(e)).toList();
  }

  // --- Historial de pesos ---

  static Future<void> addWeightEntry(String exerciseName, double weight) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'history_$exerciseName';
    final jsonString = prefs.getString(key);
    
    List<WeightEntry> history = [];
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List;
      history = jsonList.map((e) => WeightEntry.fromJson(e)).toList();
    }

    history.add(WeightEntry(date: DateTime.now(), weight: weight));

    await prefs.setString(key, jsonEncode(history.map((e) => e.toJson()).toList()));
  }

  static Future<List<WeightEntry>> loadWeightHistory(String exerciseName) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('history_$exerciseName');
    if (jsonString == null) return [];
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((e) => WeightEntry.fromJson(e)).toList();
  }
}