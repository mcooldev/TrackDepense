import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/pocketBaseHelper/pocketbase_db.dart';

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

  final List<IconData> icons = [
    CupertinoIcons.arrow_right,
    CupertinoIcons.archivebox,
    CupertinoIcons.person,
  ];

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int index) {
    if (!_disposed) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void setSelectedIndex(int val) {
    _selectedIndex = val;
    notifyListeners();
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

  /// Send message support
  final GlobalKey<FormState> supportFormKey = GlobalKey<FormState>();
  final TextEditingController objectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final pb = PocketBaseDb.instance.pb;

  Future<bool> onSubmitForm() async {
    if (!supportFormKey.currentState!.validate()) return false;
    try {
      //
      final email = pb.authStore.record?.getStringValue("email");
      if (email == null || email.isEmpty) {
        log("❌ Email utilisateur non disponible");
        return false;
      }
      //
      final object = objectController.text.trim();
      final message = messageController.text.trim();
      //
      final queries = {
        'subject': object,
        'body': "Email de l'utilisateur: $email\n\n$message",
      };
      //
      final emailToSubmit = Uri(
        scheme: 'mailto',
        path: 'mcooldev96@gmail.com',
        query: queries.entries
            .map(
              (e) =>
                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
            )
            .join('&'),
      );
      //
      final launched = await launchUrl(emailToSubmit);
      if (launched) {
        log("✅ App mail ouverte avec succès");
        //
        objectController.clear();
        messageController.clear();
        //
        notifyListeners();
        return true;
      } else {
        log("❌ Impossible d'ouvrir l'app mail");
        return false;
      }
    } catch (e) {
      log("Erreur lors de l'envoi du message: $e");
      return false;
    }
  }

  /// Disposer
  @override
  void dispose() {
    _disposed = true;
    objectController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
