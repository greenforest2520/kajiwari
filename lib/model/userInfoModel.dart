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
    } else if (uid == null) {
      return null;
    }
    notifyListeners();
  }

  Future<void> fetchMyPIC() async {
    final myPICSnapshot = await FirebaseFirestore.instance
        .collection("history")
        .where("userName", arrayContains: name)
        //.where("date", isEqualTo: Timestamp.now())
        .get();
    final List<History> todayPIC =
        myPICSnapshot.docs.map((DocumentSnapshot document) {
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
    //print("${TimeOfDay.now()},${Timestamp.now().toDate()}");

    this.todayPIC = todayPIC;
    notifyListeners();

    debugPrint("fetch結果${todayPIC.toString()}");
  }

  // Future<void> ComplitePIC() async {

  //   await FirebaseFirestore.instance.collection("history").doc()
  // }
}
