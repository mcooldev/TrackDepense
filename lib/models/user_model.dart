class UserModel {
  UserModel({
    this.emailVisibility = true,
    required this.email,
    required this.password,
    this.passwordConfirm,
    this.name,
  });

  final String email;
  final String password;
  final bool? emailVisibility;
  final String? name, passwordConfirm;

  Map<String, dynamic> toMap() => {
    "email": email,
    "emailVisibility": emailVisibility,
    "name": name,
    "password": password,
    "passwordConfirm": passwordConfirm,
  };
}
