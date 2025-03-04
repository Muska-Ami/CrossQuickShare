import 'package:shared_preferences/shared_preferences.dart';

class SettingsPrefs {
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();

  Future<String?> getDeviceName() async => await prefs.getString('device_name');
  void setDeviceName(String value) async =>
      await prefs.setString('device_name', value);

  Future<String?> getSavePath() async => await prefs.getString('save_path');
  void setSavePath(String value) async =>
      await prefs.setString('save_path', value);

  Future<int?> getVisibility() async => await prefs.getInt('visibility');
  void setVisibility(int value) async =>
      await prefs.setInt('visibility', value);
}
