import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  
  static Future<void> saveWeight(String exerciseName, double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('weight_$exerciseName', weight);
  }

  static Future<double?> loadWeight(String exerciseName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('weight_$exerciseName');
  }
}