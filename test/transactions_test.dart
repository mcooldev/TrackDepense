// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:track_depenses/providers/transaction_provider.dart';
import 'package:track_depenses/models/transaction_model.dart';

void main() {
  group("Transaction provider", () {
    late TransactionProvider provider;
    late Entree entree;
    late Depense depense;
    late Mission mission;

    /// Create environment before each test
    setUp(() {
      provider = TransactionProvider();
      //
      mission = Mission(
        id: "1",
        nom: "Gamou Thiakho",
        capitaleInitial: 100000,
        capitale: 100000,
        depenses: [],
        entrees: [],
        dateDebut: DateTime.now(),
        dateFin: DateTime.now(),
      );
      //
      entree = Entree(
        id: "1",
        description: "Salaire",
        montant: 100000,
        date: DateTime.now(),
      );
      //
      depense = Depense(
        id: "1",
        description: "Loyer",
        categorie: "Logement",
        montant: 50000,
        date: DateTime.now(),
        justificatif: "assets/images/logo.png",
      );
      //
    });

    ///
    // testing add mission
    test("add mission", () {
      provider.add(mission);
      expect(provider.missions.length, 1);
      expect(mission.nom, "Gamou Thiakho");
    });
    // testing add entree
    test("add entree", () {
      provider.add(entree);
      expect(provider.entrees.first.description, "Salaire");
    });
    // testing add depense
    test("add depense", () {
      provider.add(depense);
      expect(provider.depenses.first.categorie, "Logement");
    });
  });
}
