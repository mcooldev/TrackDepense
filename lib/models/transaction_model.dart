import 'package:pocketbase/pocketbase.dart';

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
    this.id,
    this.pbRecord,
    required this.nom,
    required this.user,
    required this.capitaleInitial,
    required this.capitale,
    this.entrees = const [],
    this.depenses = const [],
    required this.dateDebut,
    required this.dateFin,
    this.createdAt,
    this.isClosed = false,
    this.isAmountGoal = false,
    this.amountGoal,
  });

  RecordModel? pbRecord;

  String? id;
  String nom, user;
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

  /// Mission fromRecord
  factory Mission.fromRecord(RecordModel record) {
    //
    final entreesData = record.getListValue<RecordModel>(
      "expand.entrees(missionId)",
      [],
    );
    final depensesData = record.getListValue<RecordModel>(
      "expand.depenses(missionId)",
      [],
    );

    final entreeList = entreesData.map((r) => Entree.fromRecord(r)).toList();
    final depenseList = depensesData.map((r) => Depense.fromRecord(r)).toList();
    //
    return Mission(
      id: record.id,
      pbRecord: record,
      user: record.getStringValue("user"),
      nom: record.getStringValue("nom"),
      capitaleInitial: record.getDoubleValue("capitaleInitial"),
      capitale: record.getDoubleValue("capitale"),
      dateDebut: DateTime.parse(record.getStringValue("dateDebut")),
      dateFin: DateTime.parse(record.getStringValue("dateFin")),
      entrees: entreeList,
      depenses: depenseList,
      isClosed: record.getBoolValue("isClosed"),
      isAmountGoal: record.getBoolValue("isAmountGoal"),
      amountGoal: record.getDoubleValue("amountGoal"),
      createdAt: DateTime.parse(record.getStringValue("created")),
    );
  }

  /// Mission toMap
  Map<String, dynamic> toMap() => {
    "nom": nom,
    "user": user,
    "capitaleInitial": capitaleInitial,
    "capitale": capitale,
    "dateDebut": dateDebut.toString(),
    "dateFin": dateFin.toString(),
    "isClosed": isClosed,
    "isAmountGoal": isAmountGoal,
    "amountGoal": amountGoal,
  };

  Mission copyWith({
    String? id,
    String? nom,
    String? user,
    double? capitaleInitial,
    double? capitale,
    List<Entree>? entrees,
    List<Depense>? depenses,
    DateTime? dateDebut,
    DateTime? dateFin,
    bool? isClosed,
    bool? isAmountGoal,
    double? amountGoal,
    DateTime? createdAt,
  }) {
    return Mission(
      id: id ?? this.id,
      amountGoal: amountGoal ?? this.amountGoal,
      nom: nom ?? this.nom,
      user: user ?? this.user,
      capitaleInitial: capitaleInitial ?? this.capitaleInitial,
      capitale: capitale ?? this.capitale,
      entrees: entrees ?? this.entrees,
      depenses: depenses ?? this.depenses,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      isClosed: isClosed ?? this.isClosed,
      isAmountGoal: isAmountGoal ?? this.isAmountGoal,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Entree model
class Entree {
  final RecordModel? record;

  Entree({
    this.record,
    this.id,
    required this.montant,
    required this.description,
    this.createdAt,
    this.justificatif,
    required this.categorie,
    required this.missionId,
  });

  String? id;
  String? justificatif;
  double montant;
  String description, categorie;
  DateTime? createdAt;
  String missionId;

  /// Entree toMap
  Map<String, dynamic> toMap() => {
    "categorie": categorie,
    "montant": montant,
    "description": description,
    "missionId": missionId,
  };

  /// Entree fromRecord
  factory Entree.fromRecord(RecordModel record) => Entree(
    record: record,
    id: record.id,
    categorie: record.getStringValue("categorie"),
    montant: record.getDoubleValue("montant"),
    description: record.getStringValue("description"),
    createdAt: DateTime.parse(record.getStringValue("created")),
    missionId: record.getStringValue("missionId"),
    justificatif: record.getStringValue("justificatif"),
  );
}

/// Depense model
class Depense {
  final RecordModel? record;

  Depense({
    this.record,
    required this.montant,
    required this.categorie,
    required this.description,
    this.createdAt,
    required this.missionId,
    this.justificatif,
    this.id,
  });

  String? id;
  double montant;
  String categorie;
  String description;
  String? justificatif;
  DateTime? createdAt;
  String missionId;

  /// Depense toMap
  Map<String, dynamic> toMap() => {
    "montant": montant,
    "categorie": categorie,
    "description": description,
    "missionId": missionId,
  };

  /// Depense fromMap
  factory Depense.fromRecord(RecordModel record) => Depense(
    record: record,
    id: record.id,
    montant: record.getDoubleValue("montant"),
    categorie: record.getStringValue("categorie"),
    description: record.getStringValue("description"),
    createdAt: DateTime.parse(record.getStringValue("created")),
    missionId: record.getStringValue("missionId"),
    justificatif: record.getStringValue("justificatif"),
  );
}
