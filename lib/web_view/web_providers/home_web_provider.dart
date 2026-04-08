import 'dart:developer';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:track_depenses/helpers/pocketBaseHelper/pocketbase_db.dart';
import 'package:track_depenses/models/transaction_model.dart';
import 'package:track_depenses/models/user_model.dart';
import 'package:track_depenses/web_view/pages/home_web_contents.dart';

import '../pages/closed_mission_web.dart';
import '../pages/mes_agents_web.dart';
import '../pages/profile_web.dart';

class HomeWebProvider with ChangeNotifier {
  //
  final _navItems = [
    {"icon": HugeIcons.strokeRoundedHome04, "label": "Accueil"},
    {"icon": HugeIcons.strokeRoundedArchive02, "label": "Missions clôturées"},
    {"icon": HugeIcons.strokeRoundedUserMultiple02, "label": "Mes agents"},
    {"icon": HugeIcons.strokeRoundedUser03, "label": "Profile"},
  ];

  final List<Widget> _pages = [
    const HomeWebContents(),
    const ClosedMissionWeb(),
    const MesAgentsWeb(),
    const ProfileWeb(),
  ];

  List<Widget> get pages => _pages;

  List<Map<String, dynamic>> get navItems => _navItems;
  int _selectedIndex = 0;
  int _previousIndex = 0;

  int get selectedIndex => _selectedIndex;

  int get previousIndex => _previousIndex;

  set selectedIndex(int val) {
    if (val != -1) {
      _previousIndex = val;
    }
    _selectedIndex = val;
    notifyListeners();
  }

  ///
  void navigateWithFadeIn(BuildContext context, Widget page) {
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

  /// Greeting
  String get greetings {
    final now = DateTime.now();
    if (now.hour >= 6 && now.hour < 19) {
      return "Bonjour 🌞";
    } else {
      return "Bonsoir 🌚";
    }
  }

  ///
  final pb = PocketBaseDb.instance.pb;
  int _activeAgents = 0;

  int get activeAgents => _activeAgents;

  Future<void> getAllActiveAgents() async {
    try {
      final currentUser = pb.authStore.record;
      if (currentUser == null) return;
      //
      final countResults = await pb
          .collection("users")
          .getList(
            page: 1,
            perPage: 1,
            filter:
                'role = "agent" && organizationId = "${currentUser.getStringValue('organizationId')}"',
          );
      _activeAgents = countResults.totalItems;

      ///
      final records = await pb
          .collection("users")
          .getFullList(
            filter:
                'role = "agent" && organizationId = "${currentUser.getStringValue('organizationId')}"',
            sort: '-created',
          );
      //
      _agentList.clear();
      _agentList.addAll(records.map(UserModel.fromRecord));
      //
      notifyListeners();
    } catch (e) {
      log(e.toString());
    }
  }

  ///
  final List<Mission> _missions = [];

  List<Mission> get missions => _missions;

  Future<List<Mission>> getAllMissionsByOrganization() async {
    try {
      final currentUser = pb.authStore.record;
      if (currentUser == null) return [];
      //
      final records = await pb
          .collection("missions")
          .getFullList(expand: 'depenses(missionId),user');

      _missions.clear();
      _missions.addAll(records.map(Mission.fromRecord));

      notifyListeners();
      return _missions;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  final List<Mission> _onGoingMissions = [];

  List<Mission> get onGoingMissions => _onGoingMissions;

  final List<Mission> _closedMissions = [];

  List<Mission> get closedMissions => _closedMissions;

  Future<List<Mission>> fetchMissionsWeb({
    required bool isClosed,
    required String searchQuery,
    bool showLoading = true,
  }) async {
    final currentUser = pb.authStore.record;
    if (currentUser == null) return [];
    //
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      //
      final expand = "depenses(missionId),entrees(missionId),user";
      String filter =
          "organizationId = '${currentUser.getStringValue("organizationId")}' && isClosed = $isClosed";
      if (searchQuery.trim().isNotEmpty) {
        filter += " && nom ~ '$searchQuery'";
      }
      //
      final records = await pb
          .collection("missions")
          .getFullList(filter: filter, sort: '-created', expand: expand);

      final fetchedMissions = records.map(Mission.fromRecord).toList();

      if (isClosed) {
        _closedMissions.clear();
        _closedMissions.addAll(fetchedMissions);
      } else {
        _onGoingMissions.clear();
        _onGoingMissions.addAll(fetchedMissions);
      }

      return fetchedMissions;
    } catch (e) {
      dev.log("Error while fetching missions: $e");
      rethrow;
    } finally {
      if (showLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  double get totalBudget {
    double total = 0;
    for(var mission in _missions){
      total += mission.capitale;
    }
    return total;
  }

  double get totalConsumedBudget {
    double total = 0;
    for (var mission in _missions) {
      for (var depense in mission.depenses) {
        total += depense.montant;
      }
    }
    return total;
  }

  Mission? _selectedMission;

  Mission? get selectedMission => _selectedMission;

  set selectedMission(Mission? val) {
    _selectedMission = val;
    notifyListeners();
  }

  dynamic _selectedTrx;

  dynamic get selectedTrx => _selectedTrx;

  set selectedTrx(dynamic trx) {
    _selectedTrx = trx;
    notifyListeners();
  }

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initDashboard() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      //
      await Future.wait([
        getAllMissionsByOrganization(),
        getAllActiveAgents(),
        fetchMissionsWeb(isClosed: false, searchQuery: '', showLoading: false),
        fetchMissionsWeb(isClosed: true, searchQuery: '', showLoading: false),
      ]);

      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //
  final List<UserModel> _agentList = [];

  List<UserModel> get agentList => _agentList;

  //

  UserModel? _selectedAgent;

  UserModel? get selectedAgent => _selectedAgent;

  set selectedAgent(UserModel? val) {
    _selectedAgent = val;
    notifyListeners();
  }

  ///

  Future<void> resetUserDeviceIdDialog(BuildContext context) async {
    //
    final confirm = await showDialog<bool>(
      useSafeArea: true,
      context: context,
      fullscreenDialog: true,
      builder: (context) => AlertDialog(
        constraints: const BoxConstraints(maxWidth: 500),
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
              icon: HugeIcons.strokeRoundedAccountSetting02,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              "Êtes-vous sûr de vouloir réinitialiser l'appareil de l'agent ?",
              softWrap: true,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.pop(context, false),
            minWidth: 200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80),
              side: BorderSide(width: 1, color: Colors.grey.shade200),
            ),
            elevation: 0,
            height: 50,
            color: Theme.of(context).colorScheme.surface,
            child: const Text("Annuler", style: TextStyle(color: Colors.red)),
          ),
          MaterialButton(
            onPressed: () => Navigator.pop(context, true),
            minWidth: 200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80),
            ),
            elevation: 0,
            height: 50,
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
      if (_selectedAgent == null) return;
      //
      try {
        //
        await PocketBaseDb.instance.pb
            .collection("users")
            .update(_selectedAgent!.userRecord!.id, body: {"deviceId": ""});
        //
        if (!context.mounted) return;
        //
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            width: 400,
            content: const Text("📱️ • Réinitialisation réussie"),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: const StadiumBorder(),
          ),
        );
        //
        await getAllActiveAgents();
      } catch (e) {
        log(e.toString());
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            width: 400,
            content: Text("❌ • Erreur lors de la réinitialisation"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: StadiumBorder(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _selectedMission = null;
    _selectedTrx = null;
    super.dispose();
  }
}
