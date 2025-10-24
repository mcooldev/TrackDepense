import 'package:uuid/uuid.dart';

const uuid = Uuid();

enum MissionType {
  transport,
  prime,
  urgence,
  sante,
  evenement,
  logement,
  nouriture,
  autre,
}

final Map<MissionType, String> missionTypeIcon = {
  MissionType.transport: "🚌",
  MissionType.prime: "💰",
  MissionType.urgence: "⚠️",
  MissionType.sante: "🤒",
  MissionType.evenement: "🎉",
  MissionType.logement: "🛌",
  MissionType.nouriture: "🍔",
  MissionType.autre: "🤑",
};

final Map<MissionType, String> missionTypeName = {
  MissionType.transport: "Transport",
  MissionType.prime: "Prime",
  MissionType.urgence: "urgence",
  MissionType.sante: "Santé",
  MissionType.evenement: "Evènement",
  MissionType.logement: "Logement",
  MissionType.nouriture: "Nouriture",
  MissionType.autre: "Autre",
};

/// Mission model
class Mission {
  Mission({
    required this.nom,
    required this.capitaleInitial,
    required this.capitale,
    required this.entrees,
    required this.depenses,
    required this.dateDebut,
    required this.dateFin,
    this.isClosed = false,
    String? id,
  }) : id = id ?? uuid.v4();
  String id;
  String nom;
  double capitaleInitial;
  double capitale;
  List<Entree> entrees;
  List<Depense> depenses;
  DateTime dateDebut;
  DateTime dateFin;
  bool isClosed;

  /// Copy with mission
  Mission copyWith({
    String? id,
    String? nom,
    double? capitaleInitial,
    double? capitale,
    List<Entree>? entrees,
    List<Depense>? depenses,
    DateTime? dateDebut,
    DateTime? dateFin,
    bool? isClosed,
  }) {
    return Mission(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        capitaleInitial: capitaleInitial ?? this.capitaleInitial,
        capitale: capitale ?? this.capitale,
        entrees: entrees ?? this.entrees,
        depenses: depenses ?? this.depenses,
        dateDebut: dateDebut ?? this.dateDebut,
        dateFin: dateFin ?? this.dateFin,
        isClosed: isClosed ?? this.isClosed,
    );
  }
}

/// Entree model
class Entree {
  Entree({
    required this.montant,
    required this.description,
    required this.date,
    String? id,
  }) : id = id ?? uuid.v4();
  String id;
  double montant;
  String description;
  DateTime date;
}

/// Depense model
class Depense {
  Depense({
    required this.montant,
    required this.categorie,
    required this.description,
    required this.date,
    this.justificatif,
    String? id,
  }) : id = id ?? uuid.v4();
  String id;
  double montant;
  String categorie;
  String description;
  DateTime date;
  String? justificatif;
}
