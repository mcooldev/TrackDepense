class TDConfig {
  TDConfig._();

  static final TDConfig _instance = TDConfig._();

  factory TDConfig() {
    return _instance;
  }

  ///

  //
  final schemeString =
      "com.googleusercontent.apps.699525924030-v6gsmugnbp3dr97u6l535oopl89e83r7:/";
  //

  final String baseUrl = const String.fromEnvironment(
    "BASE_URL",
    defaultValue: 'https://divisi-angella-slumberous.ngrok-free.dev',
  );

  final bool isProduction = const bool.fromEnvironment(
    "IS_PROD",
    defaultValue: false,
  );
}
