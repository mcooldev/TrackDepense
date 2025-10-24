import 'package:flutter/material.dart';
import 'package:track_depenses/helpers/themeHelper/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _theme = ThemeHelper().lightMode;

  ThemeData get theme => _theme;

  bool isSwitched = false;

  void toggleTheme() {
    if (_theme == ThemeHelper().lightMode) {
      _theme = ThemeHelper().darkMode;
      isSwitched = true;
    } else {
      _theme = ThemeHelper().lightMode;
      isSwitched = false;
    }
    notifyListeners();
  }
}
