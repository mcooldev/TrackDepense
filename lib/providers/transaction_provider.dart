import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:track_depenses/providers/user_provider.dart';

import '../helpers/pocketBaseHelper/pocketbase_db.dart';
import '../helpers/pocketBaseHelper/trx_db.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  ///
  final List<Mission> _missions = [];

  List<Mission> get missions => [..._missions];

  //
  final List<dynamic> _allTrx = [];

  List<dynamic> get allTrx => [..._allTrx];

  /// Trx to pocketbase database

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  final pb = PocketBaseDb.instance.pb;

  /// Fetch missions
  Future<List<Mission>> fetchMissions({
    required bool isClosed,
    required String searchQuery,
  }) async {
    if (isLoading) return [];
    if (pb.authStore.record == null) return [];
    //
    _isLoading = true;
    notifyListeners();
    try {
      //
      final expand = "depenses_via_missionId,entrees_via_missionId";
      String filter =
          "user = '${pb.authStore.record?.id}' && isClosed = $isClosed";
      if (searchQuery.isNotEmpty) {
        filter += " && nom ~ '$searchQuery'";
      }
      //
      final records = await pb
          .collection("missions")
          .getFullList(filter: filter, sort: '-created', expand: expand);
      //
      return _missions
        ..clear()
        ..addAll(records.map(Mission.fromRecord));
      //
    } catch (e) {
      dev.log("Error while fetching missions: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<dynamic>> fetchTrx({
    required String missionId,
    required String queryString,
  }) async {
    if (isLoading) return [];
    if (pb.authStore.record == null) return [];
    if (missionId.isEmpty) return [];
    //
    _isLoading = true;
    notifyListeners();
    try {
      //
      String filter = "missionId = '$missionId'";
      if (queryString.isNotEmpty) {
        filter += " && (description ~ '$queryString')";
      }
      //
      final lists = await Future.wait([
        pb.collection("entrees").getFullList(sort: "-created", filter: filter),
        pb.collection("depenses").getFullList(sort: "-created", filter: filter),
      ]);
      final entreeList = lists[0];
      //
      final depenseList = lists[1];
      //

      final fetchedTrx = [
        ...entreeList.map((e) => Entree.fromRecord(e)),
        ...depenseList.map((d) => Depense.fromRecord(d)),
      ];
      return _allTrx
        ..clear()
        ..addAll(fetchedTrx)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      //
    } catch (e) {
      dev.log("Error while fetching transactions: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
      dev.log("✅ Mission ajoutée avec succès");
    } catch (e) {
      dev.log("Erreur lors de l'ajout de la mission : $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add entree to pocketbase
  Future<void> addEntreeToPb({
    required Entree entree,
    required Mission mission,
  }) async {
    _isLoading = true;
    notifyListeners();
    //
    final File? image = _imageJustificatif;
    //
    try {
      await pb
          .collection("entrees")
          .create(
            body: entree.toMap(),
            expand: "missionId",
            files: image == null
                ? []
                : [
                    await http.MultipartFile.fromPath(
                      'justificatif',
                      _imageJustificatif!.path,
                    ),
                  ],
          );
      //
      updateTrxLocally(entree);
      //
      await updateMissionCapital(mission);
      //
      _imageJustificatif = null;
    } catch (e) {
      dev.log("Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add depense to pocketbase
  Future<void> addDepenseToPb({
    required Depense depense,
    required Mission mission,
  }) async {
    _isLoading = true;
    notifyListeners();
    //
    final File? image = _imageJustificatif;
    //
    try {
      //
      await pb
          .collection("depenses")
          .create(
            body: depense.toMap(),
            expand: "missionId",
            files: image == null
                ? []
                : [
                    await http.MultipartFile.fromPath(
                      'justificatif',
                      _imageJustificatif!.path,
                    ),
                  ],
          );
      //
      updateTrxLocally(depense);
      //
      await updateMissionCapital(mission);
      //
      _imageJustificatif = null;
    } catch (e) {
      dev.log("Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Mission?> updateMissionToPb({
    required Mission mission,
    Map<String, dynamic>? data,
  }) async {
    if (isLoading) return null;
    //
    _isLoading = true;
    notifyListeners();
    //
    try {
      final updatedRecord = await pb
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
      final updatedMission = Mission.fromRecord(updatedRecord);
      //
      await updateMissionCapital(updatedMission);
      //
      dev.log("✅ Mission mise à jour avec succès");
      //
      return updatedMission;
    } catch (e) {
      dev.log("Erreur lors de la mise à jour de la mission : $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //
  void updateTrxLocally(dynamic trxUpdated) {
    final index = _allTrx.indexWhere((trx) => trx.id == trxUpdated.id);
    if (index != -1) {
      _allTrx[index] = trxUpdated;
    } else {
      _allTrx.add(trxUpdated);
    }
    notifyListeners();
  }

  //
  Future<void> updateMissionCapital(Mission mission) async {
    try {
      //
      final results = await Future.wait([
        pb
            .collection('entrees')
            .getFullList(filter: 'missionId = "${mission.id}"'),
        pb
            .collection('depenses')
            .getFullList(filter: 'missionId = "${mission.id}"'),
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
      final newCapital = max(0, totalEntrees - totalDepenses);
      //
      final updatedRecord = await pb
          .collection('missions')
          .update(mission.id!, body: {'capitale': newCapital});
      //
      final updatedMission = Mission.fromRecord(updatedRecord);
      final index = _missions.indexWhere(
        (mission) => mission.id == updatedMission.id,
      );
      if (index != -1) {
        _missions[index] = updatedMission;
        notifyListeners();
      }
      //
      dev.log("✅ Capital recalculé: $newCapital");
      //
    } catch (e) {
      dev.log("❌ Erreur de recalcul: $e");
    }
  }

  //
  Future<void> updateEntreeOnPb({
    required Mission mission,
    required String entreeId,
    required Map<String, dynamic> data,
  }) async {
    if (isLoading) return;
    //
    _isLoading = true;
    notifyListeners();
    //
    final File? image = _imageJustificatif;
    //
    try {
      //
      final trxUpdated = await pb
          .collection("entrees")
          .update(
            entreeId,
            expand: "missionId",
            body: data,
            files: image == null
                ? []
                : [
                    await http.MultipartFile.fromPath(
                      'justificatif',
                      _imageJustificatif!.path,
                    ),
                  ],
          );
      //
      updateTrxLocally(trxUpdated);
      //
      await updateMissionCapital(mission);
      //
      _imageJustificatif = null;
    } catch (e) {
      dev.log("Erreur lors de la mise à jour de l'entrée : $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //
  Future<void> updateDepenseOnPb({
    required Mission mission,
    required String depenseId,
    required Map<String, dynamic> data,
  }) async {
    if (isLoading) return;
    //
    _isLoading = true;
    notifyListeners();
    //
    final File? image = _imageJustificatif;
    //
    try {
      //
      final trxUpdated = await pb
          .collection("depenses")
          .update(
            depenseId,
            body: data,
            expand: "missionId",
            files: image == null
                ? []
                : [
                    await http.MultipartFile.fromPath(
                      'justificatif',
                      _imageJustificatif!.path,
                    ),
                  ],
          );
      //
      updateTrxLocally(trxUpdated);
      //
      await updateMissionCapital(mission);
      //
      _imageJustificatif = null;
    } catch (e) {
      dev.log("Erreur lors de la mise à jour de la dépense : $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Diadev.logs

  void deleteMissionLocally(String missionId) {
    _missions.removeWhere((mission) => mission.id == missionId);
    notifyListeners();
  }

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
            child: const Text("Annuler", style: TextStyle(color: Colors.red)),
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
      await TrxDb.instance.deleteMissionOnPb(mission.id!);
      deleteMissionLocally(mission.id!);
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

  Future<bool> closeMissionDialog({
    required BuildContext context,
    required Mission mission,
    required UserProvider prov,
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
            child: const Text("Annuler", style: TextStyle(color: Colors.red)),
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
      if (!context.mounted) return false;
      await updateMissionToPb(mission: mission, data: {'isClosed': true});
      //
      notifyListeners();
      //
      if (!context.mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("🗃️ • Mission clôturée avec succès"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
        ),
      );
    }
    return false;
  }

  /// Delete depense diadev.log

  void deleteTrxLocally(String trxId) {
    _allTrx.removeWhere((t) => t.id == trxId);
    notifyListeners();
  }

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
            child: const Text("Annuler", style: TextStyle(color: Colors.red)),
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
      deleteTrxLocally(trx.id);
      //
      await updateMissionCapital(trx.missionId);
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
  final montanEntreeController = TextEditingController();
  final descriptionEntreeController = TextEditingController();

  /// Controllers for depense
  final montantDepenseController = TextEditingController();
  final descriptionDepenseController = TextEditingController();

  /// Controllers & date for mission
  final nomController = TextEditingController();
  final capitaleController = TextEditingController();
  final dateDebutController = TextEditingController();
  final dateFinController = TextEditingController();
  DateTime? dateDebut;
  DateTime? dateFin;

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
    montanEntreeController.clear();
    descriptionEntreeController.clear();
    montantDepenseController.clear();
    amountGoalController.clear();
    _isAmountGoalSet = false;
    descriptionDepenseController.clear();
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
    montanEntreeController.dispose();
    descriptionEntreeController.dispose();
    _imageJustificatif = null;
    _selectedIndex = -1;
    super.dispose();
  }
}
