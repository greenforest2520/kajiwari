import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HouseWork {
  String kajiName;
  String userGroupId;
  HouseWork(this.kajiName, this.userGroupId);
}

class HouseWorkModel extends ChangeNotifier {
  final _houseworkCollection =
      FirebaseFirestore.instance.collection("housework");

  List<HouseWork>? housework;

  void fetchHousework() async {
    final QuerySnapshot history_snapshot = await _houseworkCollection.get();
    final List<HouseWork> housework =
        history_snapshot.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      final String kajiName = data["kajiName"];
      ;
      final String userGroupId = data["userGroupId"];
      ;
      return HouseWork(kajiName, userGroupId);
    }).toList();

    this.housework = housework;
    notifyListeners();
  }
}
