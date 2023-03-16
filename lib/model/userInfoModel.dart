import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:profiele_web/model/history.dart';

class UserInfoModel extends ChangeNotifier {
  String? name;
  String? nigate;
  int ticket = 0;
  String? userId;
  String? groupName;
  bool? isComplite;
  String PICId = "";
  final currentUser = FirebaseAuth.instance.currentUser;
  List<History> todayPIC = [];

  late String? uid = currentUser?.uid;

  void updateIsComplite() {
    isComplite = true;
  }

  Future updateName(name) {
    this.name = name;
    notifyListeners();
    return name;
  }

  Future<void> fetchUser() async {
    if (currentUser != null) {
      print(currentUser!.uid);
      final snapshot = await FirebaseFirestore.instance
          .collection("UserInfo")
          .doc(uid)
          .get();
      final data = snapshot.data();

      final String name = data!["name"];
      final String nigate = data["nigate"];
      final int ticket = data["ticket"];
      final String userId = data["userId"];
      final String groupName = data["groupName"];

      print(name + nigate + ticket.toString() + userId + groupName);
      this.name = name;
      this.nigate = nigate;
      this.ticket = ticket;
      this.userId = userId;
      notifyListeners();

      await fetchMyPIC(name);
    }
  }

  Future<void> fetchMyPIC(name) async {
    await FirebaseFirestore.instance
        .collection("history")
        .where("userName", isEqualTo: name)
        //.where("date", isEqualTo: Timestamp.now())
        .get()
        .then((snapshot) {
      print("fetch名前$name");

      final List<History> todayPIC =
          snapshot.docs.map((DocumentSnapshot document) {
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
            pICId: pICId);
      }).toList();
      //print("${TimeOfDay.now()},${Timestamp.now().toDate()}");

      this.todayPIC = todayPIC;
      debugPrint("fetch結果,${todayPIC.toString()}");
      notifyListeners();
    }).catchError((e) {
      print("fetchエラー:$e");
      debugPrint("fetch結果,${todayPIC.toString()}");
    });
  }

  Future<void> complitePIC(String PICId) async {
    await FirebaseFirestore.instance.collection("history").doc(PICId).update({
      "isComplite": true,
    });
  }
}
