import 'dart:collection';

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
            minExtendedWidth: 200,
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
        return RoulettPage();
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
          if (model == null) {
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
                    SizedBox(
                      height: 50,
                    ),
                    Text(model.name + "さん"),
                    SizedBox(
                      height: 50,
                    ),
                    CircleAvatar(
                      minRadius: 50,
                      child: Icon(
                        Icons.mood,
                        size: 70,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Text("今日のタスク"),
                    ListTile(),
                    SizedBox(
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
                        child: Text("ログアウト")),
                  ],
                ),
              ),
            ),
          );
        }));
  }
}
