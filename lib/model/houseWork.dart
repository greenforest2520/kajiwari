import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HouseWork {
  String kajiName;
  String groupId;

  HouseWork(this.kajiName, this.groupId);
}

class HouseWorkModel extends ChangeNotifier {
  final _houseworkCollection = FirebaseFirestore.instance.collection("kaji");

  final kajiController = TextEditingController();
  String? kaji;
  String? uid;

  void setKaji(String kaji) {
    this.kaji = kaji;
    notifyListeners();
  }

  List<HouseWork>? houseWork;

  void fetchHousework() async {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    String? uid = userCredential.user?.uid;
    if (uid != null) {
      final QuerySnapshot houseWorkSnapshot = await _houseworkCollection.get();
      // .where("groupId", isEqualTo: ["guestGroup"]).get();

      final List<HouseWork> housework =
          houseWorkSnapshot.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        final String kajiName = data["kajiName"];

        final String groupId = data["groupId"];

        kaji = data["kajiName"];
        print("家事名:$kajiName$groupId");
        return HouseWork(kajiName, groupId);
      }).toList();

      houseWork = housework;
      notifyListeners();
    }
  }
}
