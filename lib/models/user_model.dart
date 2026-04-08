import 'package:pocketbase/pocketbase.dart';

class UserModel {
  UserModel({
    required this.email,
    this.password,
    this.organizationId,
    this.name,
    this.userRole,
    this.userRecord,
  });

  final String email;
  final String? password;
  final String? name;
  final String? userRole;
  final String? organizationId;

  RecordModel? userRecord;

  Map<String, dynamic> toMap() => {
    "email": email,
    "name": name,
    "password": password,
    "userRole": userRole,
    "organizationId": organizationId,
  };

  factory UserModel.fromRecord(RecordModel record) {
    final email = record.getStringValue("email");
    final name = record.getStringValue("name");
    final userRole = record.getStringValue("role");
    final organizationId = record.getStringValue("organizationId");

    return UserModel(
      userRecord: record,
      email: email,
      userRole: userRole,
      name: name,
      organizationId: organizationId,
    );
  }

  ///
}
