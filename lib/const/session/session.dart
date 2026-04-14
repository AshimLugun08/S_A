import 'package:shared_preferences/shared_preferences.dart';

class UserPref {
  // Keys
  static const String _isLoggedIn = "isLoggedIn";
  static const String _userId = "userId";
  static const String _phone = "phone";
  static const String _role = "role";

  // ── SAVE USER DATA ──
  static Future<void> saveUser(int id, String phone, String role) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedIn, true);
    await prefs.setInt(_userId, id);
    await prefs.setString(_phone, phone);
    await prefs.setString(_role, role);
  }

  // ── GET USER DATA ──
  static Future<Map<String, dynamic>> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      "userId": prefs.getInt(_userId),
      "phone": prefs.getString(_phone),
      "role": prefs.getString(_role),
      "isLoggedIn": prefs.getBool(_isLoggedIn) ?? false,
    };
  }

  // ── GET ROLE ONLY ──
  static Future<String?> getRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_role);
  }

  // ── LOGOUT ──
  static Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}