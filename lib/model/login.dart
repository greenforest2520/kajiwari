import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:profiele_web/model/shared_prefs.dart';

import 'dart:math' as math;

class LoginModel extends ChangeNotifier {
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final statusController = TextEditingController();

  String? email;
  String? password;

  String? imagePath;

  String? role;
  String? status;

  String? name;
  String? nigate;
  int? ticket;
  String? uid;

  bool isLoading = false;

  final colors = <Color>[
    Colors.red.withAlpha(50),
    Colors.green.withAlpha(30),
    Colors.blue.withAlpha(70),
    Colors.yellow.withAlpha(90),
    Colors.amber.withAlpha(50),
    Colors.indigo.withAlpha(70),
  ];

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  void setEmail(String email) {
    this.email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    this.password = password;
    notifyListeners();
  }

  Future login() async {
    email = mailController.text;
    password = passwordController.text;

    if (email != null && password != null) {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email!, password: password!);
      final currentUser = FirebaseAuth.instance.currentUser;
      final uid = currentUser!.uid;
      //this.uid = uid;
      SharedPrefs.setPrefsInstance();
      SharedPrefs.setUid(uid);
      //print(uid);
    }
  }

  Future checkRole() async {
    final sharedUid = SharedPrefs.fetchUid().toString();

    if (sharedUid == "" || sharedUid.isEmpty || sharedUid == null.toString()) {
      return;
    } else if (sharedUid != "" ||
        sharedUid != null.toString() ||
        sharedUid.isNotEmpty) {
      final DocumentSnapshot sharedprefdocumentSnapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(sharedUid)
              .get();

      role = sharedprefdocumentSnapshot["role"];
    }
  }

  // anonymousUid() async {
  //   final userCredential = await FirebaseAuth.instance.signInAnonymously();
  //   uid = userCredential.user?.uid;
  //   notifyListeners();
  //   return uid;
  // }

  Future<void> anonymousSignup() async {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    uid = userCredential.user?.uid;
    String? mycolor =
        colors[math.Random().nextInt(colors.length)].value.toRadixString(16);
    print(mycolor);
    if (uid != null) {
      // print("アノニマス$uid");
      final userdoc =
          FirebaseFirestore.instance.collection('UserInfo').doc(uid);
      String random = ("${Random().nextInt(100)}");
      return userdoc
          .set({
            "name": "guest$random",
            "nigate": "皿洗い",
            "ticket": 1,
            "userId": uid,
            "myColor": mycolor,
            "groupName": "guestGroup" //widgetを作成してその選択したものをfetchしてきてその情報を入れる
          })
          .then((value) => print("情報追加成功:{$name$nigate$ticket$uid"))
          .catchError((error) => print("追加失敗: $error"));
    }
  }

  Future<void> insertGroup() async {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    uid = userCredential.user?.uid;
    if (uid != null) {
      //print(uid);
      final groupdoc =
          FirebaseFirestore.instance.collection('UserGroup').doc("guestGroup");
      final DocumentSnapshot usersnapshot = await FirebaseFirestore.instance
          .collection("UserInfo")
          .doc(uid)
          .get();
      String? userName = usersnapshot["name"];

      return groupdoc
          .update({
            "member": FieldValue.arrayUnion([userName]),
          })
          .then((value) => print("グループ追加成功:$userName"))
          .catchError((error) => print("追加失敗: $error"));
    }
  }
}
