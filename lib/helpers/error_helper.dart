import 'package:pocketbase/pocketbase.dart';

/// Converts a PocketBase [ClientException] or any network error into a
/// user-friendly French message.
String parsePbError(dynamic error) {
  if (error is ClientException) {
    // statusCode == 0 means no HTTP response was received (network unreachable)
    if (error.statusCode == 0) {
      return "Impossible de contacter le serveur. Vérifiez votre connexion.";
    }

    switch (error.statusCode) {
      case 400:
        // Field-level validation errors from PocketBase
        final data = error.response['data'] as Map<String, dynamic>?;
        if (data != null && data.isNotEmpty) {
          final messages = data.values
              .whereType<Map>()
              .map((e) => e['message'] as String? ?? '')
              .where((m) => m.isNotEmpty)
              .toList();
          if (messages.isNotEmpty) return messages.first;
        }
        final msg400 = error.response['message'] as String? ?? '';
        if (msg400.isNotEmpty) return msg400;
        return "Données invalides. Vérifiez les champs.";
      case 401:
        return "Identifiants incorrects.";
      case 403:
        return "Accès refusé.";
      case 404:
        return "Ressource introuvable.";
      case 429:
        return "Trop de tentatives. Réessayez plus tard.";
    }

    if (error.statusCode >= 500) {
      return "Erreur serveur. Réessayez plus tard.";
    }

    final msg = error.response['message'] as String? ?? '';
    if (msg.isNotEmpty) return msg;
  }

  final errorStr = error.toString();
  if (errorStr.contains('SocketException') ||
      errorStr.contains('Failed host lookup') ||
      errorStr.contains('Connection refused')) {
    return "Pas de connexion internet.";
  }

  return "Une erreur inattendue s'est produite.";
}