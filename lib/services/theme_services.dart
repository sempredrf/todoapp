import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeServices {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  bool _loadThemFromBox() => _box.read(_key) ?? false;
  void _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  ThemeMode get theme => _loadThemFromBox() ? ThemeMode.dark : ThemeMode.light;

  void switchTheme() {
    Get.changeThemeMode(_loadThemFromBox() ? ThemeMode.light : ThemeMode.dark);
    _saveThemeToBox(!_loadThemFromBox());
  }
}
