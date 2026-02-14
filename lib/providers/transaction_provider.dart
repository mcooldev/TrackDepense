import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../helpers/pocketBaseHelper/pocketbase_db.dart';
import '../helpers/pocketBaseHelper/trx_db.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  ///
  final List<Mission> _missions = [];

  List<Mission> get missions => [..._missions];

  /// Trx to pocketbase database

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  final pb = PocketBaseDb.instance.pb;

  // Add mission to pocketbase
  Future<void> addMissionToPb(Mission mission) async {
    if (isLoading) return;
    //
    _isLoading = true;
    notifyListeners();
    //
    try {
      final record = await pb
          .collection("missions")
          .create(body: mission.toMap());
      //
      await pb
          .collection('entrees')
          .create(
            body: {
              'missionId': record.id,
              'categorie': 'Budget_Initial',
              'montant': mission.capitaleInitial,
              'description': "Budget initial",
            },
          );
      //
      log("✅ Mission ajoutée avec succès");
    } catch (e) {
      log("Erreur lors de l'ajout de la mission : $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add entree to pocketbase
  Future<void> addEntreeToPb({
    required Entree entree,
    required String missionId,
  }) async {
    _isLoading = true;
    notifyListeners();
    //
    try {
      await pb
          .collection("entrees")
          .create(
            body: entree.toMap(),
            expand: 'missionId',
            files: _imageJustificatif == null
                ? []
                : [
                    await http.MultipartFile.fromPath(
                      'justificatif',
                      _imageJustificatif!.path,
                    ),
                  ],
          );
      //
      await _updateMissionCapital(missionId);
      //
    } catch (e) {
      log("Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add depense to pocketbase
  Future<void> addDepenseToPb({
    required Depense depense,
    required String missionId,
  }) async {
    _isLoading = true;
    notifyListeners();
    //
    try {
      //
      await pb
          .collection("depenses")
          .create(
            expand: 'missionId',
            body: depense.toMap(),
            files: _imageJustificatif == null
                ? []
                : [
                    await http.MultipartFile.fromPath(
                      'justificatif',
                      _imageJustificatif!.path,
                    ),
                  ],
          );
      //
      await _updateMissionCapital(missionId);
      //
    } catch (e) {
      log("Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMissionToPb({
    required Mission mission,
    Map<String, dynamic>? data,
  }) async {
    if (isLoading) return;
    //
    _isLoading = true;
    notifyListeners();
    //
    try {
      await pb
          .collection('missions')
          .update(mission.id!, body: data ?? mission.toMap());
      //
      final recordEntree = await pb
          .collection("entrees")
          .getFirstListItem(
            "missionId = '${mission.id}' && categorie = 'Budget_Initial'",
          );
      await pb
          .collection('entrees')
          .update(recordEntree.id, body: {'montant': mission.capitaleInitial});
      //
      await _updateMissionCapital(mission.id!);
      //
      notifyListeners();
      //
      log("✅ Mission mise à jour avec succès");
    } catch (e) {
      log("Erreur lors de la mise à jour de la mission : $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //
  Future<void> _updateMissionCapital(String missionId) async {
    try {
      //
      final results = await Future.wait([
        pb
            .collection('entrees')
            .getFullList(filter: 'missionId = "$missionId"'),
        pb
            .collection('depenses')
            .getFullList(filter: 'missionId = "$missionId"'),
      ]);
      //
      final entreeList = results[0];
      final depenseList = results[1];
      //
      final totalEntrees = entreeList.fold<double>(
        0,
        (prev, current) => prev + current.getDoubleValue('montant'),
      );
      final totalDepenses = depenseList.fold<double>(
        0,
        (pre, current) => pre + current.getDoubleValue("montant"),
      );
      //
      final newCapital = totalEntrees - totalDepenses;
      //
      await pb
          .collection('missions')
          .update(missionId, body: {'capitale': newCapital});
      //
      log("✅ Capital recalculé: $newCapital");
      //
    } catch (e) {
      log("❌ Erreur de recalcul: $e");
    }
  }

  //
  Future<void> updateEntreeOnPb({
    required String missionId,
    required String entreeId,
    required Map<String, dynamic> data,
  }) async {
    if (isLoading) return;
    //
    _isLoading = true;
    notifyListeners();
    //
    try {
      //
      await pb
          .collection("entrees")
          .update(
            entreeId,
            body: data,
            files: _imageJustificatif == null
                ? []
                : [
                    await http.MultipartFile.fromPath(
                      'justificatif',
                      _imageJustificatif!.path,
                    ),
                  ],
          );
      //
      await _updateMissionCapital(missionId);
      //
    } catch (e) {
      log("Erreur lors de la mise à jour de l'entrée : $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //
  Future<void> updateDepenseOnPb({
    required String missionId,
    required String depenseId,
    required Map<String, dynamic> data,
  }) async {
    if (isLoading) return;
    //
    _isLoading = true;
    notifyListeners();
    //
    try {
      //
      await pb
          .collection("depenses")
          .update(
            depenseId,
            body: data,
            files: _imageJustificatif == null
                ? []
                : [
                    await http.MultipartFile.fromPath(
                      'justificatif',
                      _imageJustificatif!.path,
                    ),
                  ],
          );
      //
      await _updateMissionCapital(missionId);
      //
    } catch (e) {
      log("Erreur lors de la mise à jour de la dépense : $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Dialogs

  Future<void> deleteMissionDialog(
    BuildContext context,
    Mission mission,
  ) async {
    //
    final confirm = await showDialog<bool>(
      useSafeArea: true,
      context: context,
      builder: (context) => AlertDialog(
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
            Text("🗑️", style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16),
            Text(
              "Êtes-vous sûr de vouloir supprimer cette mission ?",
              softWrap: true,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.pop(context, false),
            minWidth: MediaQuery.sizeOf(context).width * 0.3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80),
              side: BorderSide(width: 1, color: Colors.grey.shade200),
            ),
            elevation: 0,
            color: Theme.of(context).colorScheme.surface,
            child: Text(
              "Annuler",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          MaterialButton(
            onPressed: () => Navigator.pop(context, true),
            minWidth: MediaQuery.sizeOf(context).width * 0.3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80),
            ),
            elevation: 0,
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              "Supprimer",
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
      if (mission.id == null) return;
      TrxDb.instance.deleteMissionOnPb(mission.id!);
      clearControllers();
      //
      if (!context.mounted) return;
      Navigator.of(context).pop();
      //
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("🗑️️ • Mission supprimée avec succès"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
        ),
      );
    }
  }

  Future<void> closeMissionDialog({
    required BuildContext context,
    required Mission mission,
  }) async {
    //
    final confirm = await showDialog<bool>(
      useSafeArea: true,
      context: context,
      builder: (context) => AlertDialog(
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
            Text("🗃️", style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16),
            Text(
              "Êtes-vous sûr de vouloir clôturer cette mission ?",
              softWrap: true,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.pop(context, false),
            minWidth: MediaQuery.sizeOf(context).width * 0.3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80),
              side: BorderSide(width: 1, color: Colors.grey.shade200),
            ),
            elevation: 0,
            color: Theme.of(context).colorScheme.surface,
            child: Text(
              "Annuler",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          MaterialButton(
            onPressed: () => Navigator.pop(context, true),
            minWidth: MediaQuery.sizeOf(context).width * 0.3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80),
            ),
            elevation: 0,
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              "Clôturer",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
    //
    if (confirm == true) {
      if (!context.mounted) return;
      // todo: close mission method from pocketbase
      await updateMissionToPb(mission: mission, data: {'isClosed': true});
      clearControllers();
      //
      if (!context.mounted) return;
      Navigator.of(context).pushReplacementNamed('/closedMissions');
      //
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("🗃️ • Mission clôturée avec succès"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
        ),
      );
    }
  }

  // Delete depense dialog
  Future<void> deleteTrxDialog(
    BuildContext context,
    dynamic trx,
    bool isEntree,
  ) async {
    //
    final confirm = await showDialog<bool>(
      useSafeArea: true,
      context: context,
      builder: (context) => AlertDialog(
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
            Text("🗑️", style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16),
            Text(
              isEntree
                  ? "Êtes-vous sûr de vouloir supprimer cette entrée ?"
                  : "Êtes-vous sûr de vouloir supprimer cette dépense ?",
              softWrap: true,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.pop(context, false),
            minWidth: MediaQuery.sizeOf(context).width * 0.3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80),
              side: BorderSide(width: 1, color: Colors.grey.shade200),
            ),
            elevation: 0,
            color: Theme.of(context).colorScheme.surface,
            child: Text(
              "Annuler",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          MaterialButton(
            onPressed: () => Navigator.pop(context, true),
            minWidth: MediaQuery.sizeOf(context).width * 0.3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80),
            ),
            elevation: 0,
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              "Supprimer",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
    //
    if (confirm == true) {
      //
      await TrxDb.instance.deleteTrxOnPb(trx.id, isEntree);
      //
      clearControllers();
      await Future.wait([
        _updateMissionCapital(trx.missionId),
        Future.delayed(const Duration(milliseconds: 500)),
      ]);
      //
      if (!context.mounted) return;
      Navigator.of(context).pop();
      //
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEntree
                ? "🗑️ • Entrée supprimée avec succès"
                : "🗑️ • Dépense supprimée avec succès",
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
        ),
      );
      //
    }
  }

  /// Controllers for entree
  final montanEntreetController = TextEditingController();
  final descriptionEntreeController = TextEditingController();

  /// Controllers for depense
  final montantDepenseController = TextEditingController();
  final descriptionDepenseController = TextEditingController();

  /// Controllers & date for mission
  final nomController = TextEditingController();
  final capitaleController = TextEditingController();
  final dateDebutController = TextEditingController();
  final dateFinController = TextEditingController();
  DateTime? dateDebut = DateTime.now();
  DateTime? dateFin = DateTime.now();

  String _hintValueDebut = "";
  String _hintValueFin = "";

  String get hintValueDebut =>
      _hintValueDebut.isEmpty ? "Date de début" : _hintValueDebut;

  String get hintValueFin =>
      _hintValueFin.isEmpty ? "Date de fin" : _hintValueFin;

  void setHintValueDebut(String value) {
    _hintValueDebut = value;
    notifyListeners();
  }

  void setHintValueFin(String value) {
    _hintValueFin = value;
    notifyListeners();
  }

  void clearControllers() {
    nomController.clear();
    capitaleController.clear();
    dateDebutController.clear();
    dateFinController.clear();
    montanEntreetController.clear();
    descriptionEntreeController.clear();
    montantDepenseController.clear();
    amountGoalController.clear();
    _isAmountGoalSet = false;
    descriptionDepenseController.clear();
    dateDebut = DateTime.now();
    dateFin = DateTime.now();
    _hintValueDebut = "";
    _hintValueFin = "";
    _selectedIndex = -1;
    _imageJustificatif = null;
    notifyListeners();
  }

  /// Mission type
  int _selectedIndex = -1;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  /// Justificatif de la dépense
  File? _imageJustificatif;

  File? get imageJustificatif => _imageJustificatif;

  set imageJustificatif(File? value) {
    _imageJustificatif = value;
    notifyListeners();
  }

  Future<void> pickImageJustificatifFromGallery() async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxHeight: 1280,
      maxWidth: 1280,
    );
    if (pickedImage != null) {
      _imageJustificatif = File(pickedImage.path);
      notifyListeners();
    }
  }

  Future<void> pickImageJustificatifFromCamera() async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxHeight: 1280,
      maxWidth: 1280,
    );
    if (pickedImage != null) {
      _imageJustificatif = File(pickedImage.path);
      notifyListeners();
    }
  }

  void showBottomSheetJustificatif(
    BuildContext context,
    Widget child,
    bool isScroll,
  ) {
    showModalBottomSheet(
      isScrollControlled: isScroll,
      useSafeArea: true,
      showDragHandle: true,
      context: context,
      builder: (context) {
        return child;
      },
    );
  }

  /// Set amount goal for mission
  final amountGoalController = TextEditingController();
  bool _isAmountGoalSet = false;

  bool get isAmountGoalSet => _isAmountGoalSet;

  set isAmountGoalSet(bool value) {
    _isAmountGoalSet = value;
    notifyListeners();
  }

  void setAmountGoalSet(bool value) {
    _isAmountGoalSet = value;
    notifyListeners();
  }

  /// Percent indicator
  double calculatePercent(double capitalAmount, double amountGoal) {
    if (capitalAmount == 0 || amountGoal == 0) {
      return 0.0;
    }
    double percent = (capitalAmount / amountGoal);
    return percent.clamp(0.0, 1.0);
  }

  /// Disposer
  @override
  void dispose() {
    nomController.dispose();
    capitaleController.dispose();
    dateDebutController.dispose();
    dateFinController.dispose();
    montanEntreetController.dispose();
    descriptionEntreeController.dispose();
    _imageJustificatif = null;
    _selectedIndex = -1;
    super.dispose();
  }
}
