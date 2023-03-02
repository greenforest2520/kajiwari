import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/widgets.dart';

class RegisterModel extends ChangeNotifier {
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final checkPasswordController = TextEditingController();
  final nameController = TextEditingController();

  String? mail;
  String? password;
  String? checkpassword;

  String? imagePath;
  String? name;

  String? uid;

  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  void setEmail(String mail) {
    this.mail = mail;
    notifyListeners();
  }

  void setPassword(String password) {
    this.password = password;
    notifyListeners();
  }

  void setPasswordCheck(String checkpassword) {
    this.checkpassword = checkpassword;
    notifyListeners();
  }

  void setName(String name) {
    this.name = name;
    notifyListeners();
  }

  Future signUp() async {
    mail = mailController.text;
    password = passwordController.text;
    name = nameController.text;
    // this.name = nameController.text;
    // this.status = statusController.text;

    if (mail != null && password != null) {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: mail!, password: password!);
      final user = userCredential.user;

      if (user != null) {
        final uid = user.uid;

        final doc = FirebaseFirestore.instance.collection("users").doc(uid);

        await doc.set({
          "uid": uid,
          "name": name,
          "imagePath":
              "https://firebasestorage.googleapis.com/v0/b/discrimination-317cd.appspot.com/o/10871615i.jpg?alt=media&token=2f71a98e-46c0-4609-815e-8dcea111fe7c",
        });
      }
    }
  }
}
