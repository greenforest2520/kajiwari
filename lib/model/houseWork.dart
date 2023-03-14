import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roulette/roulette.dart';

import '../roulette_page.dart';

class HouseWork {
  String kajiName;
  String groupId;
  HouseWork({required this.kajiName, required this.groupId});
}

class kajigroup {
  String groupId;
  kajigroup({required this.groupId});
}

class HouseWorkModel extends ChangeNotifier {
  final _houseworkCollection = FirebaseFirestore.instance.collection("kaji");
  final _userGroupCollection =
      FirebaseFirestore.instance.collection("UserGroup");
  final _userInfoCollection = FirebaseFirestore.instance.collection("UserInfo");
  final kajiController = TextEditingController();

  List<HouseWork>? housework;
  String? kajiName;
  String? groupId;
  String? newkaji;
  String? selectkaji;
  List<kajigroup>? kajiGroupId;
  int index = 0;
  List<RouletteUnit> rouletteList = [];
  List<RouletteGroup>? group;

  void setKaji(String? kaji) {
    newkaji = kaji;
    notifyListeners();
  }

  void selectKaji(value) {
    selectkaji = value;
    print("kajiindex$selectkaji");
    notifyListeners();
  }

  void fetchHousework() async {
    // await fetchMyGroupId();
    // print("フェッチ後フェッチ${kajiGroupId![0].groupId}");
    final kajiSnapshot = await _houseworkCollection
        .where("groupId", isEqualTo: "guestGroup")
        .get();
    final List<HouseWork> housework =
        kajiSnapshot.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      final String kajiName = data["kajiName"];
      final String groupId = data["groupId"];

      // print("map後$kajiName + $groupId");
      return HouseWork(kajiName: kajiName, groupId: groupId);
    }).toList();
    this.housework = housework;
    notifyListeners();
    debugPrint("fetch結果${housework.toString()}");
  }

  Future<void> fetchMyGroupId() async {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    String? uid = userCredential.user?.uid;
    //print(uid);
    final userGroupsnapshot =
        await _userGroupCollection.where("member", arrayContains: uid).get();
    final List<kajigroup> kajigroupId =
        userGroupsnapshot.docs.map((DocumentSnapshot document) {
      Object? data = document.data()! as Map<String, dynamic>;

      final String groupId = document.reference.id;
      //print("グループID:$groupId");
      notifyListeners();
      return kajigroup(groupId: groupId);
    }).toList();
    kajiGroupId = kajigroupId;

    notifyListeners();
  }

  Future<void> fetchRouletteUser(selectkaji) async {
    final myGroupsnapshot = await _userInfoCollection
        .where("groupName", isEqualTo: "guestGroup")
        .get();
    print("ルーレットスナップショット$myGroupsnapshot");

    final List<RouletteUnit> roultteuint =
        myGroupsnapshot.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      final String name = data["name"];
      final String nigate = data["nigate"];
      final String mycolor = data["myColor"];

      print("ルーレット$name$nigate$mycolor");
      return RouletteUnit.text(name,
          color: Color(int.parse(mycolor, radix: 16)),
          weight: nigate != selectkaji ? 0.5 : 0.4);
    }).toList();
    rouletteList = roultteuint;
    roultteuint.asMap().entries.map((entry) {
      int index = entry.key;
    });
    print("ルーレットリスト$roultteuint");
    RouletteGroup group = RouletteGroup(rouletteList);
    notifyListeners();
  }

  Future<void> registerKaji(String? kaji, String? groupId) async {
    await _houseworkCollection
        .doc()
        .set({
          "kajiName": kaji,
          "groupId": "guestGroup",
        })
        .then((value) => print("家事追加成功"))
        .catchError((error) => print("家事追加失敗: $error"));

    notifyListeners();
  }

  Future<void> fetchRouletteUserindex(selectkaji) async {
    final myGroupsnapshot = await _userInfoCollection
        .where("groupName", isEqualTo: "guestGroup")
        .get();
    print("ルーレットスナップショット$myGroupsnapshot");

    final List<RouletteUnit> roultteuint =
        myGroupsnapshot.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      final String name = data["name"];
      final String nigate = data["nigate"];
      final String mycolor = data["myColor"];

      print("ルーレット$name$nigate$mycolor");
      return RouletteUnit.text(name,
          color: Color(int.parse(mycolor, radix: 16)),
          weight: nigate != selectkaji ? 0.5 : 0.4);
    }).toList();
    rouletteList = roultteuint;
    print("リストのインデックス表示${rouletteList.elementAt(1)}");

    print("ルーレットリスト$roultteuint");
    RouletteGroup group = RouletteGroup(rouletteList);
    notifyListeners();
  }

  Future registerPIC(int result, String? selectkaji) async {
    print("$selectkaji");
    final picUnit = rouletteList.elementAt(result);
    final picName = picUnit.text;
    final doc = FirebaseFirestore.instance.collection("history").doc();
    doc.set({
      "date": Timestamp.now().toDate(),
      "groupId": "guestGroup",
      "isComplite": false,
      "kajiName": selectkaji,
      "userName": picName,
      "PICId": doc.id,
    });
  }
}
