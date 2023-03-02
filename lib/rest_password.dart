import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'success';
    } catch (error) {
      //print("$error.toString()");
      return error.toString();
    }
  }
}

class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({Key? key}) : super(key: key);

  @override
  ResetPasswordFormState createState() => ResetPasswordFormState();
}

class ResetPasswordFormState extends State<ResetPasswordForm> {
  final AuthService _auth = AuthService();
  final formGlobalKey = GlobalKey();
  final _mailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.orange,
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.forward_to_inbox_rounded,
                color: Colors.white,
              ),
              const SizedBox(
                height: 18,
              ),
              const Text(
                "パスワード再設定用メールを送信",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 36),
              TextField(
                controller: _mailController,
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: '登録したメールアドレス',
                  labelText: 'メールアドレス',
                ),
                autofocus: true,
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.yellow),
                child: const Text("送信"),
                onPressed: () async {
                  String result =
                      await _auth.sendPasswordResetEmail(_mailController.text);

                  // 成功時は戻る
                  if (result == 'success') {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("無効なメールアドレスです"),
                            backgroundColor: Colors.white,
                            buttonPadding: const EdgeInsets.all(8),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(context);
                                  },
                                  child: const Text("close"))
                            ],
                          );
                        });
                  } else if (result == 'ERROR_INVALID_EMAIL') {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("無効なメールアドレスです"),
                            backgroundColor: Colors.white,
                            buttonPadding: const EdgeInsets.all(8),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("close"))
                            ],
                          );
                        });
                  } else if (result == 'ERROR_USER_NOT_FOUND') {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("このメールアドレスは登録されていません"),
                            backgroundColor: Colors.white,
                            buttonPadding: const EdgeInsets.all(8),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("close"))
                            ],
                          );
                        });
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("メールの送信に失敗しました"),
                          backgroundColor: Colors.white,
                          buttonPadding: const EdgeInsets.all(8),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("close"))
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
