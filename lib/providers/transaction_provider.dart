import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/transaction_model.dart';

enum FilterType { mixed, entrees, depenses }

class TransactionProvider with ChangeNotifier {
  ///
  final List<Mission> _missions = [];

  List<Mission> get missions => [..._missions];
  final List<Depense> _depenses = [];

  List<Depense> get depenses => [..._depenses];
  final List<Entree> _entrees = [];

  List<Entree> get entrees => [..._entrees];

  /// Add item to the list
  void add<T>(T item) {
    if (item is Mission) {
      _missions.add(item);
    } else if (item is Depense) {
      _depenses.add(item);
    } else if (item is Entree) {
      _entrees.add(item);
    }
    notifyListeners();
  }

  /// Remove item from the list
  void removeMission(Mission mission) async {
    final missionIndex = _missions.indexWhere((m) => m.id == mission.id);
    final closedMissionIndex = _closedMissions.indexWhere(
      (m) => m.id == mission.id,
    );
    if (missionIndex != -1) {
      _missions.removeAt(missionIndex);
      notifyListeners();
    }
    //
    if (closedMissionIndex != -1) {
      _closedMissions.removeAt(closedMissionIndex);
      notifyListeners();
    }
  }

  /// Controllers for entree
  final montanEntreetController = TextEditingController();
  final descriptionEntreeController = TextEditingController();

  void addEntreeToMission(Mission missionId, Entree entree) {
    final missionIndex = _missions.indexWhere((m) => m.id == missionId.id);
    if (missionIndex != -1) {
      _missions[missionIndex]
        ..entrees.add(entree)
        ..capitale += entree.montant;
      notifyListeners();
    }
  }

  void updateEntree(Mission missionId, Entree entreeToUpdate) {
    final missionIndex = _missions.indexWhere((m) => m.id == missionId.id);
    if (missionIndex != -1) {
      //
      final mission = _missions[missionIndex];
      final entreeIndex = mission.entrees.indexWhere(
        (e) => e.id == entreeToUpdate.id,
      );
      //
      if (entreeIndex != -1) {
        final oldAmount = mission.entrees[entreeIndex].montant;
        //
        _missions[missionIndex].capitale -= oldAmount;
        _missions[missionIndex].capitale += entreeToUpdate.montant;
        //
        mission.entrees[entreeIndex] = entreeToUpdate;
        notifyListeners();
      }
    }
  }

  void removeEntree(Mission missionId, Entree entree) {
    final missionIndex = _missions.indexWhere((m) => m.id == missionId.id);
    if (missionIndex != -1) {
      _missions[missionIndex].entrees.removeWhere((e) => e.id == entree.id);
      _missions[missionIndex].capitale -= entree.montant;
      notifyListeners();
    }
  }

  /// Controllers for depense
  final montantDepenseController = TextEditingController();
  final descriptionDepenseController = TextEditingController();

  void addDepenseToMission(Mission missionId, Depense depense) {
    final missionIndex = _missions.indexWhere((m) => m.id == missionId.id);
    if (missionIndex != -1) {
      _missions[missionIndex]
        ..depenses.add(depense)
        ..capitale -= depense.montant;
      notifyListeners();
    }
  }

  void updateDepense(Mission missionId, Depense depenseToUpdate) {
    final missionIndex = _missions.indexWhere((m) => m.id == missionId.id);
    if (missionIndex != -1) {
      //
      final mission = _missions[missionIndex];
      final depenseIndex = mission.depenses.indexWhere(
        (d) => d.id == depenseToUpdate.id,
      );
      //
      if (depenseIndex != -1) {
        final oldAmount = mission.depenses[depenseIndex].montant;
        //
        mission.capitale += oldAmount;
        mission.capitale -= depenseToUpdate.montant;
        //
        mission.depenses[depenseIndex] = depenseToUpdate;
        //
        notifyListeners();
      }
    }
  }

  void removeDepense(Mission missionId, Depense depense) {
    final missionIndex = _missions.indexWhere((m) => m.id == missionId.id);
    if (missionIndex != -1) {
      _missions[missionIndex].depenses.removeWhere((d) => d.id == depense.id);
      _missions[missionIndex].capitale += depense.montant;
      notifyListeners();
    }
  }

  Depense? findDepenseById(String depenseId) {
    for (final mission in _missions) {
      try {
        return mission.depenses.firstWhere(
          (element) => element.id == depenseId,
        );
      } catch (e) {
        continue;
      }
    }
    //
    for (final closedMission in _closedMissions) {
      try {
        return closedMission.depenses.firstWhere(
          (element) => element.id == depenseId,
        );
      } catch (e) {
        continue;
      }
    }
    //
    return null;
  }

  /// Controllers & date for mission
  final nomController = TextEditingController();
  final capitaleController = TextEditingController();
  final dateDebutController = TextEditingController();
  final dateFinController = TextEditingController();
  DateTime dateDebut = DateTime.now();
  DateTime dateFin = DateTime.now();

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

  /// find mission by id
  Mission? findMissionById({required String missionId}) {
    //
    for (final mission in _missions) {
      if (mission.id == missionId) {
        return mission;
      }
    }
    //
    for (final closedMission in _closedMissions) {
      if (closedMission.id == missionId) {
        return closedMission;
      }
    }
    //
    return null;
  }

  /// Sort list
  FilterType _currentFilter = FilterType.mixed;

  FilterType get currentFilter => _currentFilter;

  void toggleFilter() {
    if (_currentFilter == FilterType.mixed) {
      _currentFilter = FilterType.entrees;
    } else if (_currentFilter == FilterType.entrees) {
      _currentFilter = FilterType.depenses;
    } else {
      _currentFilter = FilterType.mixed;
    }
    notifyListeners();
  }

  /// Justificatif de la dépense
  File? _imageJustificatif;

  File? get imageJustificatif => _imageJustificatif;

  set imageJustificatif(File? value) {
    _imageJustificatif = value;
    notifyListeners();
  }

  void pickImageJustificatif() async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      _imageJustificatif = File(pickedImage.path);
      notifyListeners();
    }
  }

  /// Clôturer une mission
  final List<Mission> _closedMissions = [];

  List<Mission> get closedMissions =>
      [..._closedMissions]..sort((a, b) => b.dateFin.compareTo(a.dateFin));

  void closeMission(Mission mission) {
    final missionIndex = _missions.indexWhere((m) => m.id == mission.id);
    if (missionIndex != -1) {
      final closedMission = _missions[missionIndex].copyWith(
        isClosed: true,
        dateFin: DateTime.now(),
      );
      //
      _closedMissions.add(closedMission);
      _missions.removeAt(missionIndex);
      notifyListeners();
    }
  }

  /// Filter transaction by name
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searchMissionController =
      TextEditingController();

  TextEditingController get searchController => _searchController;

  TextEditingController get searchMissionController => _searchMissionController;

  List<Mission> _filteredOnGoingMission = [];

  List<Mission> get filteredOnGoingMission => _filteredOnGoingMission.isEmpty
      ? ([..._missions]..sort((a, b) => b.id.compareTo(a.id)))
      : [..._filteredOnGoingMission];

  List<dynamic> _filteredOp = [];

  List<dynamic> get filteredOp => _filteredOp;

  Timer? _debounce;

  bool _isSearching = false;

  bool get isSearching => _isSearching;

  void filterOnGoingMissionByName(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    //
    _isSearching = true;
    notifyListeners();
    //
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (query.isEmpty) {
        _filteredOnGoingMission = [];
      } else {
        _filteredOnGoingMission = _missions.where((mission) {
          return mission.nom.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      //
      _isSearching = false;
      notifyListeners();
    });
  }

  void filterTxnByName(List<dynamic> list, String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (query.isEmpty) {
        _filteredOp = List.from(list);
      } else {
        _filteredOp = list.where((op) {
          if (op is Entree) {
            return op.description.toLowerCase().contains(query.toLowerCase());
          } else if (op is Depense) {
            return op.description.toLowerCase().contains(query.toLowerCase());
          }
          return false;
        }).toList();
      }
      //
      notifyListeners();
    });
  }

  /// Set amount goal for mission
  final amountGoalController = TextEditingController();
  bool _isAmountGoalSet = false;

  bool get isAmountGoalSet => _isAmountGoalSet;

  void setAmountGoalSet(bool value) {
    _isAmountGoalSet = value;
    notifyListeners();
  }

  /// Percent indicator
  double calculatePercent (double capitalAmount, double amountGoal) {
    if (capitalAmount == 0 || amountGoal == 0) {
      return 0.0;
    }
    double percent = (capitalAmount / amountGoal);
    return percent.clamp(0.0, 1.0);
  }

  /// Disposer
  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    nomController.dispose();
    capitaleController.dispose();
    dateDebutController.dispose();
    dateFinController.dispose();
    montanEntreetController.dispose();
    descriptionEntreeController.dispose();
    super.dispose();
  }
}
