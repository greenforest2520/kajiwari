import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  final kajiController = TextEditingController();

  List<HouseWork>? housework;
  String? kajiName;
  String? groupId;
  String? kaji;
  List<kajigroup>? kajiGroupId;
  void setKaji(String kaji) {
    this.kaji = kaji;
    notifyListeners();
  }

  void fetchHousework() async {
    await fetchMyGroupId();
    print(kajiGroupId);
    final kajiSnapshot =
        await _houseworkCollection.where("groupId", whereIn: [groupId]).get();
    final List<HouseWork> housework =
        kajiSnapshot.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      final String kajiName = data["kajiName"];
      final String groupId = document.reference.id;

      print(kajiName + groupId);
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
        await _userGroupCollection.where("member", isEqualTo: ["$uid"]).get();
    final List<kajigroup> kajigroupId =
        userGroupsnapshot.docs.map((DocumentSnapshot document) {
      Object? data = document.data()! as Map<String, dynamic>;

      final String groupId = document.reference.id;
      print(groupId);
      print(uid);
      notifyListeners();
      return kajigroup(groupId);
    }).toList();
    kajiGroupId = kajigroupId;
    notifyListeners();
  }

  Future<void> registerKaji() async {
    final userGroupsnapshot = await _userGroupCollection
        .doc()
        .set({
          "kajiName": kaji,
          "groupId": groupId,
        })
        .then((value) => print("家事追加成功"))
        .catchError((error) => print("家事追加失敗: $error"));
  }
}
