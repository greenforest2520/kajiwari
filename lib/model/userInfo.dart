import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserInfo {
  String userId;
  String name;
  int ticket;
  String nigate;
  UserInfo(this.userId, this.name, this.ticket, this.nigate);
}

class UserInfoModel extends ChangeNotifier {
  final _userCollection = FirebaseFirestore.instance.collection("userInfo");

  List<UserInfo>? userInfo;

  void fetchUserInfo() async {
    final QuerySnapshot userInfo_snapshot = await _userCollection.get();
    final List<UserInfo> userInfo =
        userInfo_snapshot.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      final String userId = data["userId"];
      final String name = data["name"];
      final int ticket = data["ticket"];
      final String nigate = data["nigate"];
      return UserInfo(userId, name, ticket, nigate);
    }).toList();

    this.userInfo = userInfo;
    notifyListeners();
  }

  Future updateIsComplite(String historyId) async {
    await FirebaseFirestore.instance
        .collection("history")
        .doc(historyId)
        .update({"isComplite": true});
  }

  Future updateTicket(String userId, int ticket) async {
    await FirebaseFirestore.instance
        .collection("UserInfo")
        .doc(userId)
        .update({"ticket": ticket + 1});
  }

  Future updateGuestId() async {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    final user = userCredential.user;

    if (user != null) {
      final uid = user.uid;
      final doc = FirebaseFirestore.instance.collection("users").doc(uid);

      await doc.set({
        "userId": uid,
        "name": "ゲストユーザー",
        "nigate": "皿洗い",
        "ticket": 3,
      });
    }
  }
}





//今日の家事リストをとってくる処理