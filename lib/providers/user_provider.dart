import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/web_view/web_providers/home_web_provider.dart';
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

  ///
  bool _isOrgStillActive = false;
  bool _isLoading = false;

  bool get isOrgStillActive => _isOrgStillActive;

  bool get isLoading => _isLoading;

  Future<void> checkSubscription() async {
    if (_isLoading) return;
    //
    try {
      _isLoading = true;
      notifyListeners();
      //
      final currentUser = pb.authStore.record;
      if (currentUser == null) return;
      //
      final orgId = currentUser.getStringValue("organizationId");
      if (orgId.isEmpty) return;
      //
      final record = await pb.collection('organizations').getOne(orgId);
      //
      final orgSubscriptionDate = record.getStringValue("subscription_until");
      if (orgSubscriptionDate.isEmpty) return;
      final parsedDate = DateTime.parse(orgSubscriptionDate);
      //
      final currentDate = DateTime.now();
      //
      final isActive = record.getBoolValue("is_active");
      //
      _isOrgStillActive = isActive && currentDate.isBefore(parsedDate);
    } on ClientException catch (e) {
      if (e.statusCode == 403) {
        log("Accès refusé — règles PocketBase à vérifier");
        return; // ✅ ne change pas _isOrgStillActive
      }
      if (e.statusCode == 404) {
        log("Organisation introuvable");
        _isOrgStillActive = false;
        return;
      }
      log("Erreur ClientException: $e");
    } catch (e) {
      log("Erreur lors de la vérification de la souscription: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
        path: 'trackdepenses@gmail.com',
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

  /// Dialog for sign out

  Future<void> signOutDialog(BuildContext context) async {
    //
    final confirm = await showDialog<bool>(
      useSafeArea: true,
      context: context,
      fullscreenDialog: true,
      builder: (context) => AlertDialog(
        constraints: BoxConstraints(
          maxWidth: kIsWeb ? 500 : MediaQuery.sizeOf(context).width * 0.8,
        ),
        alignment: Alignment.center,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 30,
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xff11181C)
            : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedLogout02,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              "Êtes-vous sûr de vouloir vous déconnecter ?",
              softWrap: true,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.pop(context, false),
            minWidth: kIsWeb ? 200 : MediaQuery.sizeOf(context).width * 0.3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80),
              side: BorderSide(width: 1, color: Colors.grey.shade200),
            ),
            elevation: 0,
            height: kIsWeb ? 50 : null,
            color: Theme.of(context).colorScheme.surface,
            child: const Text("Annuler", style: TextStyle(color: Colors.red)),
          ),
          MaterialButton(
            onPressed: () => Navigator.pop(context, true),
            minWidth: kIsWeb ? 200 : MediaQuery.sizeOf(context).width * 0.3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80),
            ),
            elevation: 0,
            height: kIsWeb ? 50 : null,
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              "Oui",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
    //
    if (confirm == true) {
      if (!context.mounted) return;
      //
      resetIndex();
      if (kIsWeb) {
        final prov = Provider.of<HomeWebProvider>(context, listen: false);
        prov.selectedIndex = 0;
      }
      //
      PocketBaseDb.instance.pb.realtime.unsubscribe();
      PocketBaseDb.instance.pb.authStore.clear();
      //
      if (!context.mounted) return;
      //
      Navigator.pushReplacementNamed(context, "/authGate");
      //
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          width: kIsWeb ? 400 : null,
          content: const Text("👋🏾️ • Déconnexion réussie"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
        ),
      );
    }
  }

  ///

  /// Disposer
  @override
  void dispose() {
    _disposed = true;
    objectController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
