import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/providers/transaction_provider.dart';
import 'package:track_depenses/providers/user_provider.dart';
import 'package:track_depenses/web_view/pages/mission_detail_web.dart';
import 'package:track_depenses/web_view/web_providers/home_web_provider.dart';

import '../web_widgets/web_navigation_bar.dart';

class HomeWeb extends StatefulWidget {
  const HomeWeb({super.key});

  @override
  State<HomeWeb> createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {
  ///

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<HomeWebProvider>().initDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    ///
    final theme = Theme.of(context);
    final userProv = Provider.of<UserProvider>(context, listen: false);

    ///
    return Scaffold(
      body: Consumer2<HomeWebProvider, TransactionProvider>(
        builder: (_, prov, trxProv, _) {
          return Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Navigation bar
              WebNavigationBar(theme: theme, prov: prov, userProv: userProv),

              /// Contents here • Pages
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double targetWidth = constraints.maxWidth < 1190
                        ? 1190
                        : constraints.maxWidth;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: targetWidth,
                        child: prov.selectedMission != null
                            ? MissionDetailWeb(mission: prov.selectedMission!)
                            : IndexedStack(
                                index: prov.selectedIndex,
                                children: prov.pages,
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
