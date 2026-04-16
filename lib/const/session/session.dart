import 'package:shared_preferences/shared_preferences.dart';
class UserPref {
  // Keys
  static const String _isLoggedIn = "isLoggedIn";
  static const String _userId = "userId";
  static const String _phone = "phone";
  static const String _role = "role";
  static const String _name = "userName";
  static const String _address = "address"; // New
  static const String _city = "city";       // New
  static const String _state = "state";     // New

  // ── SAVE USER DATA ──
  static Future<void> saveUser({
    required int id,
    required String phone,
    required String role,
    required String name,
    String? address, // Optional
    String? city,    // Optional
    String? state,   // Optional
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedIn, true);
    await prefs.setInt(_userId, id);
    await prefs.setString(_phone, phone);
    await prefs.setString(_role, role);
    await prefs.setString(_name, name);

    // Save location data if available
    if (address != null) await prefs.setString(_address, address);
    if (city != null) await prefs.setString(_city, city);
    if (state != null) await prefs.setString(_state, state);
  }

  // ── GET USER DATA ──
  static Future<Map<String, dynamic>> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      "userId": prefs.getInt(_userId),
      "phone": prefs.getString(_phone),
      "role": prefs.getString(_role),
      "name": prefs.getString(_name),
      "address": prefs.getString(_address) ?? "", // Default to empty string
      "city": prefs.getString(_city) ?? "",
      "state": prefs.getString(_state) ?? "",
      "isLoggedIn": prefs.getBool(_isLoggedIn) ?? false,
    };
  }

  static Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}