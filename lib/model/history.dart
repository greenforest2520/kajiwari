import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class History {
  DateTime date;
  bool isComplite;
  String kajiName;
  String userId;
  History(this.date, this.isComplite, this.kajiName, this.userId);
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
      final String kajiName = data["kajiName"];
      final String userId = data["userId"];
      return History(date, isComplite, kajiName, userId);
    }).toList();

    this.history = history;
    notifyListeners();
  }
}
