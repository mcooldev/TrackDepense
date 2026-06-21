import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../web_view/web_providers/home_web_provider.dart';
import '../../web_view/web_providers/login_web_provider.dart';
import '../auth_provider.dart';
import '../onboarding_provider.dart';
import '../reset_pwd_provider.dart';
import '../share_files_providers.dart';
import '../theme_provider.dart';
import '../transaction_provider.dart';
import '../user_provider.dart';

class MainProvider {
  MainProvider._();

  static final MainProvider instance = MainProvider._();

  factory MainProvider() => instance;

  // ======================================================
  // MULTI PROVIDERS
  // ======================================================

  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider<OnBoardingProvider>(create: (context) => OnBoardingProvider()),
    //
    ChangeNotifierProvider<LoginProvider>(create: (context) => LoginProvider()),
    ChangeNotifierProvider<ResetPasswordProvider>(create: (context) => ResetPasswordProvider()),
    //
    ChangeNotifierProvider<UserProvider>(create: (context) => UserProvider()),
    //
    ChangeNotifierProvider<TransactionProvider>(create: (context) => TransactionProvider()),
    //
    ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider()),
    //
    ChangeNotifierProvider<ShareFilesProvider>(create: (context) => ShareFilesProvider()),

    /// Web providers
    ChangeNotifierProvider<LoginWebProvider>(create: (context) => LoginWebProvider()),
    ChangeNotifierProvider<HomeWebProvider>(create: (context) => HomeWebProvider()),
  ];
}
