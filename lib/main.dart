import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_depenses/helpers/pocketBaseHelper/pocketbase_db.dart';
import 'package:track_depenses/helpers/routes/route_config.dart';

import 'package:track_depenses/providers/mainProvider/main_provider.dart';
import 'package:track_depenses/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? authData = prefs.getString('pb_authData');
  final store = AsyncAuthStore(
    initial: authData,
    save: (data) async {
      await prefs.setString('pb_authData', data);
    },
    clear: () async {
      await prefs.remove('pb_authData');
    },
  );
  PocketBaseDb.instance.initPb(store);
  //
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  //
  runApp(const TrackDepenses());
}

class TrackDepenses extends StatelessWidget {
  const TrackDepenses({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: MainProvider.providers,
      child: Consumer<ThemeProvider>(
        builder: (_, prov, _) {
          return MaterialApp(
            title: 'Track Depenses',
            debugShowCheckedModeBanner: false,
            theme: prov.theme,
            scrollBehavior: kIsWeb
                ? const MaterialScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  )
                : null,
            initialRoute: '/',
            routes: RouteConfig.routes,
          );
        },
      ),
    );
  }
}
