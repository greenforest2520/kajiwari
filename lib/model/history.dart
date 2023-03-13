import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class History {
  DateTime date;
  bool isComplite;
  String groupId;
  String kajiName;
  String userName;
  History(
      {required this.date,
      required this.isComplite,
      required this.groupId,
      required this.kajiName,
      required this.userName});
}

class HistoryModel extends ChangeNotifier {
  final _historyCollection = FirebaseFirestore.instance.collection("history");

  List<History>? history;

  void fetchHistory() async {
    final QuerySnapshot history_snapshot = await _historyCollection.get();
    final List<History> history =
        history_snapshot.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      final DateTime date = data["date"];
      final bool isComplite = data["isComplite"];
      final String groupId = data["groupId"];
      final String kajiName = data["kajiName"];
      final String userName = data["userName"];
      return History(
          date: date,
          isComplite: isComplite,
          groupId: groupId,
          kajiName: kajiName,
          userName: userName);
    }).toList();

    this.history = history;
    notifyListeners();
  }
}
