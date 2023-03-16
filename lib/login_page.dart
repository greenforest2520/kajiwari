import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:profiele_web/main.dart';

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
              child: Consumer<LoginModel>(builder: (context, model, child) {
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "kajiwari",
                                  style: TextStyle(
                                    fontSize: 35,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              const SizedBox(
                                height: 35,
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await model.anonymousSignup();
                                      await model.insertGroup();

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
    );
  }
}
