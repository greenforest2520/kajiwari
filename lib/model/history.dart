import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class History {
  DateTime date;
  bool isComplite;
  String groupId;
  String kajiName;
  String userName;
  String pICId;
  History(
      {required this.date,
      required this.isComplite,
      required this.groupId,
      required this.kajiName,
      required this.userName,
      required this.pICId});
}

class HistoryModel extends ChangeNotifier {
  final _historyCollection = FirebaseFirestore.instance
      .collection("history")
      .where("groupId", isEqualTo: "guestGroup");

  List<History>? event;

  List<History>? eventList;

  Map<DateTime, List> eventMap = {};

  void fetchFromFirebaseEvent() async {
    try {
      final QuerySnapshot historySnapshot = await _historyCollection.get();

      final Map<DateTime, List> eventMap = Map.fromIterable(
          historySnapshot.docs.map((item) =>
              {'date': item['date'], 'kajiName': item['kajiName'].toString()}),
          key: (item) => item['date'],
          value: (item) => [item['kajiName']]);

      // final Map<DateTime, List> eventMap1 = {
      //   for (var item in historySnapshot.docs.map((item) =>
      //       {'dateTime': DateTime.parse(item['datetime']), 'value': item['value']}))
      //     item['dateTime']: [item['value']]
      // };
      this.eventMap = eventMap;

      print('snapshot$eventMap');
      notifyListeners();

      final List<History> event =
          historySnapshot.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        final Timestamp date = data["date"];
        final DateTime day = date.toDate();
        final bool isComplite = data["isComplite"];
        final String groupId = data["groupId"];
        final String kajiName = data["kajiName"];
        final String userName = data["userName"];
        final String pICId = data["PICId"];
        return History(
          date: day,
          isComplite: isComplite,
          groupId: groupId,
          kajiName: kajiName,
          userName: userName,
          pICId: pICId,
        );
      }).toList();
      this.eventList = event;
      print("historyfetchできた$eventList");
      notifyListeners();
    } catch (e) {
      print("historyFetchエラー${e.toString}");
    }
  }
}
