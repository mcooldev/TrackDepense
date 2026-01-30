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
    this.createdAt,
    this.isClosed = false,
    this.isAmountGoal = false,
    this.amountGoal,
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
  bool isAmountGoal;
  double? amountGoal;
  DateTime? createdAt;

  /// Mission toMap
  Map<String, dynamic> toMap() => {
    "nom": nom,
    "capitaleInitial": capitaleInitial,
    "capitale": capitale,
    "entrees": entrees.map((e) => e.toMap()).toList(),
    "depenses": depenses.map((e) => e.toMap()).toList(),
    "dateDebut": dateDebut,
    "dateFin": dateFin,
    "isClosed": isClosed,
    "isAmountGoal": isAmountGoal,
    "amountGoal": amountGoal,
  };

  /// toMap without entrees and depenses
  Map<String, dynamic> toMapWithoutList() => {
    "nom": nom,
    "capitaleInitial": capitaleInitial,
    "capitale": capitale,
    "dateDebut": dateDebut,
    "dateFin": dateFin,
    "isClosed": isClosed,
    "isAmountGoal": isAmountGoal,
    "amountGoal": amountGoal,
    "createdAt": createdAt,
  };

  /// Copy with mission
  Mission copyWith({
    String? id,
    String? nom,
    double? capitaleInitial,
    double? capitale,
    List<Entree>? entrees,
    List<Depense>? depenses,
    DateTime? dateDebut,
    DateTime? createdAt,
    DateTime? dateFin,
    bool? isClosed,
    bool? isAmountGoal,
    double? amountGoal,
  }) {
    return Mission(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      capitaleInitial: capitaleInitial ?? this.capitaleInitial,
      capitale: capitale ?? this.capitale,
      entrees: entrees ?? this.entrees,
      depenses: depenses ?? this.depenses,
      dateDebut: dateDebut ?? this.dateDebut,
      createdAt: createdAt ?? this.createdAt,
      dateFin: dateFin ?? this.dateFin,
      isClosed: isClosed ?? this.isClosed,
      isAmountGoal: isAmountGoal ?? this.isAmountGoal,
      amountGoal: amountGoal ?? this.amountGoal,
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

  /// Entree toMap
  Map<String, dynamic> toMap() => {
    "montant": montant,
    "description": description,
    "date": date,
  };

  /// Entree fromMap
  factory Entree.fromMap(Map<String, dynamic> map) => Entree(
    montant: (map['montant'] ?? 0.0) as double,
    description: map['description'] as String,
    date: map['date'] != null ? map['date'] as DateTime : DateTime.now(),
  );


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

  /// Depense toMap
  Map<String, dynamic> toMap() => {
    "montant": montant,
    "categorie": categorie,
    "description": description,
    "date": date,
    "justificatif": justificatif,
  };

  /// Depense fromMap
  factory Depense.fromMap(Map<String, dynamic> map) => Depense(
    montant: (map['montant'] ?? 0.0) as double,
    categorie: map['categorie'] as String,
    description: map['description'] as String,
    date: map['date'] != null ? map['date'] as DateTime : DateTime.now(),
  );
}
