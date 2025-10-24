import 'package:uuid/uuid.dart';

const uuid = Uuid();

class UserModel {
  UserModel({
    required this.email,
    required this.password,
    this.name,
    String? id,
  }) : id = uuid.v4();
  final String id;
  final String email;
  final String password;
  final String? name;
}
