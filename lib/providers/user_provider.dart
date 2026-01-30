import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';


class UserProvider with ChangeNotifier {
  /// Greeting
  String get greeting {
    final now = DateTime.now();
    if (now.hour >= 6 && now.hour < 19) {
      return "Bonjour ☀️";
    } else {
      return "Bonsoir 🌙";
    }
  }

  ///
  bool _disposed = false;

  ///
  final List<IconData> icons = [CupertinoIcons.house, CupertinoIcons.person];

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int index) {
    if (!_disposed) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void resetIndex() {
    if (!_disposed) {
      selectedIndex = 0;
      notifyListeners();
    }
  }

  //
  void navigateWithFade(BuildContext context, Widget page) {
    if (!_disposed) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  File? _image;

  File? get image => _image;

  void pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      _image = File(pickedImage.path);
      notifyListeners();
    }
  }

  /// Disposer
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
