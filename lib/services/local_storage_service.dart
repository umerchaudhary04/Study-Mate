import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyStudentName = 'student_name';
  static const String _keyWelcomeShown = 'welcome_shown';

  // Student name save karna
  static Future<bool> saveStudentName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyStudentName, name);
  }

  // Student name retrieve karna
  static Future<String?> getStudentName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStudentName);
  }

  // First-time onboarding flag save karna
  static Future<bool> setWelcomeShown(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyWelcomeShown, value);
  }

  static Future<bool> isWelcomeShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyWelcomeShown) ?? false;
  }
}