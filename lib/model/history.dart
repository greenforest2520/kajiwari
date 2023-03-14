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

  List<History>? history;

  Map<DateTime, List> eventList = {};

  void fetchCalendarEvent() async {
    try {
      final QuerySnapshot historySnapshot = await _historyCollection.get();
      final List<History> history =
          historySnapshot.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        final Timestamp date = data["date"];
        final DateTime day = date.toDate();
        final bool isComplite = data["isComplite"];
        final String groupId = data["groupId"];
        final String kajiName = data["kajiName"];
        final String userName = data["userName"];
        final String pICId = data["PICId"];
        return eventList(date: day, {
          isComplite: isComplite,
          groupId: groupId,
          kajiName: kajiName,
          userName: userName,
          pICId: pICId,
        });
      }).toList();
      this.history = history;
      print("historyfetchできた$history");
      notifyListeners();
    } catch (e) {
      print("historyFetchエラー${e.toString}");
    }
  }
}
