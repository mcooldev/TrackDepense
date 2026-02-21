class TDConfig {
  TDConfig._();

  static final TDConfig _instance = TDConfig._();

  factory TDConfig() {
    return _instance;
  }

  ///

  final String baseUrl = const String.fromEnvironment(
    "BASE_URL",
    defaultValue: 'https://trackdepenses.pockethost.io/',
  );

  final bool isProduction = const bool.fromEnvironment(
    "IS_PROD",
    defaultValue: false,
  );
}
