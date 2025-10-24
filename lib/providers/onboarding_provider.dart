import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingProvider with ChangeNotifier {
  bool _isFirstTime = true;

  bool get isFirstTime => _isFirstTime;

  //
  Future<void> checkIsFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      _isFirstTime = !hasSeenOnboarding;
      notifyListeners();
    } catch (e) {
      throw Exception(e);
    }
  }

  //
  Future<void> setFirstTimeComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);
      _isFirstTime = false;
      notifyListeners();
    } catch (e) {
      throw Exception(e);
    }
  }
}
