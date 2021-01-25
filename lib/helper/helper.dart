import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String userLoggedInKey = "USERLOGGEDINKEY";
  static String userApiKey = "USERAPIKEY";
  static String userRole = "USERROLE";

  static saveUserLoggedIn(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(userLoggedInKey, isLoggedIn);
  }

  static saveUserApiKey(String api_token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(userApiKey, api_token);
  }

  static saveUserRole(String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(userRole, role);
  }

  static Future<bool> getUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(userLoggedInKey);
  }

  static Future<String> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userRole);
  }

  static Future<String> getUserApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userApiKey);
  }
}
