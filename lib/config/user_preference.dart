import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreference {
  final SharedPreferences prefs;
  UserPreference(this.prefs);

  setToken(String newToken) async {
    debugPrint("SAVED TOKEN => $newToken");
    await prefs.setString("token", newToken);
  }

  String? getToken() {
    return prefs.getString("token");
  }

  setOnChat(bool onChat) async {
    await prefs.setBool("chat", onChat);
  }

  bool? getStatusDontShowAgain() {
    return prefs.getBool("dontShowAgain");
  }

  setStatusDontShowAgain(bool dontShowAgain) async {
    await prefs.setBool("dontShowAgain", dontShowAgain);
  }

  bool getOnChat() {
    return prefs.getBool("chat") ?? false;
  }

  clearData() {
    prefs.clear();
  }
}
