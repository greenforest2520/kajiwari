import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:profiele_web/roulette_page.dart';
import 'package:table_calendar/table_calendar.dart';

import 'calender_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyWidget(),
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
                icon: Icon(Icons.mood),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_month),
                label: Text('Calendar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.casino),
                label: Text('roulette'),
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
      default:
        return Profile();
    }
  }
}

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ColoredBox(
        color: Colors.white30,
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Text("userNameさん"),
              SizedBox(
                height: 50,
              ),
              CircleAvatar(
                minRadius: 50,
              ),
              SizedBox(
                height: 50,
              ),
              Text("今日のタスク"),
              ListTile()
            ],
          ),
        ),
      ),
    );
  }
}
