import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:profiele_web/model/history.dart';

class UserInfoModel extends ChangeNotifier {
  String name = "";
  String nigate = "";
  int ticket = 0;
  String userId = "";
  String groupName = "";
  bool? isComplite;
  String PICId = "";
  final currentUser = FirebaseAuth.instance.currentUser;
  List<History> todayPIC = [];

  late String? uid = currentUser?.uid;

  void updateIsComplite() {
    isComplite = true;
  }

  Future<void> fetchUser() async {
    if (currentUser != null) {
      print(currentUser!.uid);
      final snapshot = await FirebaseFirestore.instance
          .collection("UserInfo")
          .doc(uid)
          .get();
      final data = snapshot.data();

      name = data!["name"];
      nigate = data["nigate"];
      ticket = data["ticket"];
      userId = data["userId"];
      groupName = data["groupName"];

      print(name + nigate + ticket.toString() + userId + groupName);
      name = name;
      nigate = nigate;
      ticket = ticket;
      userId = userId;
    }
    notifyListeners();
  }

  Future<void> fetchMyPIC(String name) async {
    try {
      final myPICSnapshot = await FirebaseFirestore.instance
          .collection("history")
          .where("userName", isEqualTo: name)
          //.where("date", isEqualTo: Timestamp.now())
          .get();
      print("fetch名前$name");

      final List<History> todayPIC =
          myPICSnapshot.docs.map((DocumentSnapshot document) {
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
            pICId: PICId);
      }).toList();
      //print("${TimeOfDay.now()},${Timestamp.now().toDate()}");

      this.todayPIC = todayPIC;
      notifyListeners();
    } catch (e) {
      print("fetchエラー:$e");
    }

    debugPrint("fetch結果${this.todayPIC.toString()},${todayPIC.toString()}");
  }

  Future<void> ComplitePIC(String PICId) async {
    await FirebaseFirestore.instance.collection("history").doc(PICId).update({
      "isComplite": true,
    });
  }
}
