import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/web_view/web_providers/home_web_provider.dart';

import '../../helpers/pocketBaseHelper/pocketbase_db.dart';

class ProfileWeb extends StatefulWidget {
  const ProfileWeb({super.key});

  @override
  State<ProfileWeb> createState() => _ProfileWebState();
}

class _ProfileWebState extends State<ProfileWeb> {
  ///
  final pb = PocketBaseDb.instance.pb;
  Future? orgFuture;
  final formattedDate = DateFormat("dd/MM/yyyy");

  @override
  void initState() {
    super.initState();
    final currentUser = pb.authStore.record;
    final orgId = currentUser?.getStringValue("organizationId");
    if (orgId != null) {
      orgFuture = pb.collection("organizations").getOne(orgId);
    }
  }

  ///
  @override
  Widget build(BuildContext context) {
    ///
    final theme = Theme.of(context);

    ///
    return Consumer<HomeWebProvider>(
      builder: (_, prov, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 200,
                        padding: const EdgeInsets.all(30),
                        decoration: ShapeDecoration(
                          image: const DecorationImage(
                            image: AssetImage("assets/antonius.jpg"),
                            fit: BoxFit.cover,
                          ),
                          shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: FutureBuilder(
                          future: orgFuture,
                          builder: (context, snapshot) {
                            //
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator.adaptive(),
                              );
                            }

                            final record = snapshot.data;
                            if (record == null) {
                              return const SizedBox();
                            }
                            //
                            final logoUrl = pb.files.getUrl(
                              record,
                              record.getStringValue("logo"),
                            );
                            final orgName = record.getStringValue("name");
                            //
                            final subsUntil = DateTime.parse(
                              record.getStringValue("subscription_until"),
                            );
                            final beforeTwoWeeks = DateTime.now().add(const Duration(days: 14));

                            final alertDate = beforeTwoWeeks.isBefore(subsUntil);

                            //
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // user symbol
                                Stack(
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          120,
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: logoUrl.toString(),
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                                child:
                                                    CircularProgressIndicator.adaptive(),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              const HugeIcon(
                                                icon: HugeIcons
                                                    .strokeRoundedUnavailable,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: Icon(
                                        CupertinoIcons
                                            .checkmark_alt_circle_fill,
                                        color: Colors.green,
                                        size: 32,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // agent name
                                    Text(
                                      pb.authStore.record
                                              ?.getStringValue('name')
                                              .toUpperCase() ??
                                          "Inconnu",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 24,
                                            color: Colors.white,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    // agent email
                                    Text(
                                      pb.authStore.record?.getStringValue(
                                            'email',
                                          ) ??
                                          "inconnu@inconnu.com",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall!
                                          .copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.white70,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 30),
                                Text(
                                  "•",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 28,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 30),
                                Text(
                                  orgName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 30),
                                Text(
                                  "•",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 28,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 30),
                                Row(
                                  children: [
                                    Text(
                                      "Valide jusqu'au : ",
                                      style: theme.textTheme.bodySmall!
                                          .copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: Colors.white.withValues(
                                              alpha: 0.75,
                                            ),
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      formattedDate.format(subsUntil),
                                      style: theme.textTheme.bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: alertDate ? Colors.red : Colors.green,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
