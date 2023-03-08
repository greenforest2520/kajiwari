import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roulette/roulette.dart';

class HouseWork {
  String kajiName;
  String groupId;
  HouseWork(this.kajiName, this.groupId);
}

class kajigroup {
  String groupId;
  kajigroup(this.groupId);
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
  String? kaji;
  List<kajigroup>? kajiGroupId;
  int index = 0;
  List<RouletteUnit> rouletteList = [];

  void setKaji(String kaji) {
    this.kaji = kaji;
    notifyListeners();
  }

  void selectKaji(index) {
    this.index = index;
    String selectKaji = housework![index].kajiName;
    print("kajiindex$selectKaji");
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

      print("map後$kajiName + $groupId");
      notifyListeners();
      return HouseWork(kajiName, groupId);
    }).toList();
    this.housework = housework;

    notifyListeners();
  }

  Future<void> fetchMyGroupId() async {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    String? uid = userCredential.user?.uid;
    print(uid);
    final userGroupsnapshot =
        await _userGroupCollection.where("member", arrayContains: uid).get();
    final List<kajigroup> kajigroupId =
        userGroupsnapshot.docs.map((DocumentSnapshot document) {
      Object? data = document.data()! as Map<String, dynamic>;

      final String groupId = document.reference.id;
      print("グループID:$groupId");
      notifyListeners();
      return kajigroup(groupId);
    }).toList();
    kajiGroupId = kajigroupId;

    notifyListeners();
  }

  Future<void> fetchRouletteUser() async {
    final myGroupsnapshot = await _userInfoCollection
        .where("groupName", isEqualTo: "gusetGroup")
        .get();
    final List<RouletteUnit> roulettelist =
        myGroupsnapshot.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      final String name = data["name"];
      final double nigate = data["nigate"];
      final Color mycolor = data["myColor"];
      print("$name$nigate$mycolor");
      return RouletteUnit(
          text: name, color: mycolor, weight: nigate != kaji ? 0.4 : 0.5);
    }).toList();
    rouletteList = roulettelist;
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
}
