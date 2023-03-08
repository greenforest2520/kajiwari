import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:profiele_web/main.dart';
import 'package:profiele_web/rest_password.dart';

import 'package:provider/provider.dart';

import 'model/login.dart';

import 'model/registor.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    return ChangeNotifierProvider<LoginModel>(
      create: (_) => LoginModel(),
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.purple),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text("ログイン"),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: EdgeInsets.only(
                top: 100, /*bottom: bottomSpace*/
              ),
              child: Center(
                child: Consumer<LoginModel>(builder: (context, model, child) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "kajiwari",
                                  style: TextStyle(fontSize: 35),
                                ),
                              ),
                              // TextField(
                              //   controller: model.mailController,
                              //   decoration:
                              //       const InputDecoration(hintText: "Email..."),
                              //   onChanged: (text) {
                              //     model.setEmail(text);
                              //   },
                              // ),
                              // const SizedBox(
                              //   height: 10,
                              // ),
                              // TextField(
                              //   obscureText: true,
                              //   controller: model.passwordController,
                              //   decoration: const InputDecoration(
                              //       hintText: "Password..."),
                              //   onChanged: (text) {
                              //     model.setPassword(text);
                              //   },
                              // ),
                              // const SizedBox(
                              //   height: 20,
                              // ),
                              // Row(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              //     children: [
                              //       const Text("新規登録は"),
                              //       TextButton(
                              //         onPressed: () {
                              //           Navigator.push(
                              //               context,
                              //               MaterialPageRoute(
                              //                   builder: (context) =>
                              //                       RegistrationPage()));
                              //         },
                              //         child: const Text("こちら"),
                              //       )
                              //     ]),
                              // TextButton(
                              //     onPressed: () {
                              //       Navigator.push(
                              //           context,
                              //           MaterialPageRoute(
                              //               builder: (context) =>
                              //                   const ResetPasswordForm()));
                              //     },
                              //     child: const Text("パスワードを忘れた方")),
                              const SizedBox(
                                height: 30,
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    model.startLoading();
                                    try {
                                      await model.login();
                                    } on FirebaseAuthException catch (e) {
                                      if (e.code == 'user-not-found') {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text("エラー"),
                                                content: const Text(
                                                    "メールアドレスが見つかりません"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text("OK"))
                                                ],
                                              );
                                            });
                                      } else if (e.code == 'wrong-password') {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text("エラー"),
                                                content:
                                                    const Text("パスワードが違います"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text("OK"))
                                                ],
                                              );
                                            });
                                      }
                                    } finally {
                                      model.endLoading();
                                    }
                                  },
                                  child: Container(
                                      width: 200,
                                      height: 50,
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'ログイン',
                                        textAlign: TextAlign.center,
                                      ))),
                              const SizedBox(
                                height: 15,
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await model.anonymousSignup();
                                      await model.insertGroup();
                                      // Future.delayed(Duration(seconds: 1), () {
                                      //   print("1秒後に実行");

                                      // });

                                      print("ゲストログイン");
                                      if (model.anonymousSignup() != null) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MyWidget()));
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      switch (e.code) {
                                        case "operation-not-allowed":
                                          print(
                                              "Anonymous auth hasn't been enabled for this project.");
                                          break;
                                        default:
                                          print("Unknown error.");
                                      }
                                    }
                                  },
                                  child: Container(
                                      width: 200,
                                      height: 50,
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'ゲストログイン',
                                        textAlign: TextAlign.center,
                                      )))
                            ],
                          ),
                        ),
                      ),
                      if (model.isLoading)
                        const Center(child: CircularProgressIndicator()),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegistrationPage extends StatelessWidget {
  RegistrationPage({Key? key, this.password, this.checkPassword, this.mail})
      : super(key: key);

  String? password;
  String? checkPassword;
  String? mail;

  @override
  Widget build(BuildContext context) {
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    return ChangeNotifierProvider<RegisterModel>(
      create: (_) => RegisterModel(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("新規登録"),
        ),
        body: SingleChildScrollView(
          reverse: true,
          child: Padding(
            padding: EdgeInsets.only(top: 100, bottom: bottomSpace),
            child: Center(
              child: Consumer<RegisterModel>(builder: (context, model, child) {
                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextField(
                              controller: model.mailController,
                              decoration: const InputDecoration(
                                  labelText: "メールアドレス", hintText: "Email..."),
                              onChanged: (text) {
                                model.setEmail(text);
                                mail = text;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextField(
                              obscureText: true,
                              controller: model.passwordController,
                              decoration: const InputDecoration(
                                  labelText: "パスワード", hintText: "Password..."),
                              onChanged: (text) {
                                model.setPassword(text);
                                //print(text);
                                password = text;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextField(
                              obscureText: true,
                              controller: model.checkPasswordController,
                              decoration: const InputDecoration(
                                  labelText: "確認用パスワード",
                                  hintText: "Password..."),
                              onChanged: (text) {
                                model.setPasswordCheck(text);
                                //print(text);
                                checkPassword = text;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextField(
                              obscureText: true,
                              controller: model.nameController,
                              decoration: const InputDecoration(
                                  labelText: "アカウント名", hintText: "Name..."),
                              onChanged: (text) {
                                model.setName(text);
                                //print(text);
                                checkPassword = text;
                              },
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                  model.startLoading();
                                  if (password != checkPassword) {
                                    // print("パスワード");
                                    // print(password);
                                    // print("パスワードチェック");
                                    // print(checkPassword);
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("エラー"),
                                            content:
                                                const Text("パスワードを正しく入力して下さい"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("OK"))
                                            ],
                                          );
                                        });
                                  } else {
                                    if (model.mail != null &&
                                        model.password != null &&
                                        model.checkpassword != null &&
                                        model.name != null) {
                                      try {
                                        await model.signUp();
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text("登録しました"),
                                                content: const Text("登録完了しました"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const MyWidget()),
                                                            (_) => false);
                                                      },
                                                      child: const Text("OK"))
                                                ],
                                              );
                                            });
                                      } on FirebaseAuthException catch (e) {
                                        if (e.code == 'weak-password') {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text("エラー"),
                                                  content: const Text(
                                                      "より強力なパスワードを設定してください"),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text("OK"))
                                                  ],
                                                );
                                              });
                                        } else if (e.code ==
                                            'email-already-in-use') {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text("エラー"),
                                                  content: const Text(
                                                      "このメールアドレスは\nすでに使われています"),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text("OK"))
                                                  ],
                                                );
                                              });
                                        }
                                      } catch (e) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text("エラー"),
                                                content: Text(e.toString()),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text("OK"))
                                                ],
                                              );
                                            });
                                      } finally {
                                        model.endLoading();
                                      }
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text("エラー"),
                                              content: const Text("未入力項目があります"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text("OK"))
                                              ],
                                            );
                                          });
                                    }
                                  }
                                },
                                child: Container(
                                    width: 200,
                                    height: 50,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '新規登録',
                                      textAlign: TextAlign.center,
                                    )))
                          ],
                        ),
                      ),
                      if (model.isLoading)
                        Container(
                          color: Colors.black54,
                          child:
                              const Center(child: CircularProgressIndicator()),
                        )
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
