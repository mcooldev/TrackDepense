import 'dart:async';
import 'dart:developer';

import 'package:pocketbase/pocketbase.dart';
import 'package:track_depenses/helpers/pocketBaseHelper/pocketbase_db.dart';
import 'package:track_depenses/models/transaction_model.dart';

class TrxDb {
  TrxDb._();

  static final TrxDb instance = TrxDb._();

  final pb = PocketBaseDb.instance.pb;
  final currentUser = PocketBaseDb.instance.pb.authStore.record;

  ///

  Stream<List<dynamic>> fetchEntreesAndDepensesOnPb(
    String missionId,
    String queryString,
  ) {
    //
    final controller = StreamController<List<dynamic>>();
    UnsubscribeFunc? entreeUnsubscribe;
    UnsubscribeFunc? depenseUnsubscribe;

    ///

    Future<void> fetchAllTrx() async {
      try {
        //
        String filter = "missionId = '$missionId'";
        if (queryString.isNotEmpty) {
          filter += " && (description ~ '$queryString')";
        }
        List<dynamic> allTrx = [];
        //
        final entreeList = await pb
            .collection("entrees")
            .getFullList(sort: "-created", filter: filter);
        //
        final depenseList = await pb
            .collection("depenses")
            .getFullList(sort: "-created", filter: filter);
        //
        allTrx = [
          ...entreeList.map((e) => Entree.fromRecord(e)),
          ...depenseList.map((d) => Depense.fromRecord(d)),
        ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        //
        if (!controller.isClosed) controller.add(List.from(allTrx));
      } catch (e) {
        log(e.toString());
        if (!controller.isClosed) controller.add([]);
      }
    }

    Future<void> init() async {
      //
      await fetchAllTrx();
      //
      try {
        //
        entreeUnsubscribe = await pb.collection('entrees').subscribe("*", (
          e,
        ) async {
          if (e.record == null) return;
          if (e.record?.getStringValue("missionId") == missionId) {
            await fetchAllTrx();
          }
        }, filter: "missionId = '$missionId'");

        //

        depenseUnsubscribe = await pb.collection('depenses').subscribe("*", (
          d,
        ) async {
          if (d.record == null) return;
          if (d.record?.getStringValue("missionId") == missionId) {
            await fetchAllTrx();
          }
        }, filter: "missionId = '$missionId'");

        //
      } catch (e) {
        log(e.toString());
      }
    }

    ///

    controller.onCancel = () {
      entreeUnsubscribe?.call();
      depenseUnsubscribe?.call();
      controller.close();
    };
    //
    init();
    //
    return controller.stream;
  }

  Future<void> deleteMissionOnPb(String missionId) async {
    await pb.collection("missions").delete(missionId);
  }

  Future<void> deleteTrxOnPb(String trxId, isEntree) async {
    await pb.collection(isEntree ? "entrees" : "depenses").delete(trxId);
  }
}
