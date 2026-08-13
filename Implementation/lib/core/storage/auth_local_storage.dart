import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalStorage {
  static const _keyRole = 'user_role';
  static const _keyLoggedIn = 'is_logged_in';
  static const _keyName = 'user_name';

  Future<void> saveSession(String role, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyName, name);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
  }


  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  // ✅ ADD THIS BACK
  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  // ✅ FOR NAME ON RESTART
  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }


}
