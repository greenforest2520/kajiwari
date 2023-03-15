import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:profiele_web/login_page.dart';

import 'package:profiele_web/roulette_page.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'calender_page.dart';
import 'help_page.dart';
import 'model/shared_prefs.dart';

import 'model/userInfoModel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await SharedPrefs.setPrefsInstance();
  // final sharedUid = SharedPrefs.fetchUid().toString();
// Ideal time to initialize
  await _initializeFirebaseAuth();
  //await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp(const MyApp());

//...
  // if (sharedUid == "" || sharedUid == null.toString()) {
  //   //print("nullです");
  //   runApp(const LoginPage());
  // } else {
  //   //print("nullじゃない");
  //   runApp(const MyApp());
  // }
}

Future<void> _initializeFirebaseAuth() async {
  await Firebase.initializeApp();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? user = _firebaseAuth.currentUser;
  if (user == null) {
    await _firebaseAuth.signInAnonymously();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: LoginPage()
        //MyWidget(),
        );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            minExtendedWidth: 150,
            backgroundColor: Colors.grey,
            elevation: 5,
            useIndicator: true,
            indicatorColor: Colors.grey[300],
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.task_alt),
                label: Text('Assignment'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_month),
                label: Text('Calendar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.casino),
                label: Text('Roulette'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.help),
                label: Text('Help'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          MainContents(index: _selectedIndex)
        ],
      ),
    );
  }
}

class MainContents extends StatelessWidget {
  const MainContents({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 1:
        return Calender();
      case 2:
        return RoulettPage1();
      case 3:
        return HelpPage();
      default:
        return Profile();
    }
  }
}

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserInfoModel>(
        create: (_) => UserInfoModel()..fetchUser(),
        child: Consumer<UserInfoModel>(builder: (context, model, child) {
          final currentUser = model.currentUser;
          final UserName = model.name;
          final name = model.fetchMyPIC(UserName);

          print("UserName:$UserName");

          if (currentUser == null) {
            return const Padding(
              padding: EdgeInsets.all(50),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Expanded(
            child: ColoredBox(
              color: Colors.white30,
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Text("${model.name}さん"),
                    const SizedBox(
                      height: 50,
                    ),
                    const CircleAvatar(
                      minRadius: 50,
                      child: Icon(
                        Icons.mood,
                        size: 70,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    const Text("今日の割り振り家事"),
                    Consumer<UserInfoModel>(builder: (context, model, child) {
                      try {
                        model.fetchMyPIC(model.name);

                        final todayPIC = model.todayPIC;

                        if (todayPIC.isEmpty) {
                          throw const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: Text("今日の担当はありません"),
                            ),
                          );
                        }

                        return Center(
                          child: SizedBox(
                            height: 350,
                            width: double.infinity,
                            child: ListView.builder(
                                itemCount: todayPIC.length,
                                itemBuilder: (BuildContext context, int index) {
                                  bool isComplite = todayPIC[index].isComplite;
                                  int snapIndex =
                                      todayPIC.indexOf(todayPIC[index]);

                                  return ListTile(
                                      title: Text(todayPIC[index].kajiName),
                                      leading: isComplite == false
                                          ? const Icon(
                                              Icons.check_box_outline_blank)
                                          : const Icon(Icons.check_box),
                                      onTap: () {
                                        isComplite != true
                                            ? showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (_) {
                                                  print(isComplite);

                                                  return AlertDialog(
                                                    title: const Text("完了チェック"),
                                                    content: const Text(
                                                        "家事は完了しましたか？"),
                                                    actions: [
                                                      TextButton(
                                                          child:
                                                              const Text("Yes"),
                                                          onPressed: () {
                                                            final docId = model
                                                                .todayPIC
                                                                .elementAt(
                                                                    index)
                                                                .pICId;
                                                            print(
                                                                "どっくID$docId");
                                                            model.ComplitePIC(
                                                                docId);

                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          }),
                                                      TextButton(
                                                          child:
                                                              const Text("No"),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          }),
                                                    ],
                                                  );
                                                })
                                            : showDialog(
                                                context: context,
                                                builder: (_) {
                                                  print(isComplite);

                                                  return const AlertDialog(
                                                    title: Text("完了済みです"),
                                                  );
                                                },
                                              );
                                      });
                                }),
                          ),
                        );
                      } catch (e) {
                        debugPrint("エラーが発生しました${e.toString}");
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    "登録された家事はありません",
                                    style: TextStyle(color: Colors.deepPurple),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                        //return Text("予期せぬエラーが発生しました${e.toString}");
                      }
                    }),
                    const SizedBox(
                      height: 25,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("ログアウト"),
                                  content: const Text("ログアウトしますか"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoginPage()));
                                        },
                                        child: const Text("Yes")),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("No"))
                                  ],
                                );
                              });
                        },
                        child: const Text("ログアウト")),
                  ],
                ),
              ),
            ),
          );
        }));
  }
}
