import 'dart:collection';
import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class History {
  DateTime date;
  bool isComplite;
  String groupId;
  String kajiName;
  String userName;
  String pICId;
  History(
      {required this.date,
      required this.isComplite,
      required this.groupId,
      required this.kajiName,
      required this.userName,
      required this.pICId});
}

class Event {
  final String id;
  final String title;
  final bool isComplite;
  final String userName;
  final DateTime date;
  Event(
      {required this.id,
      required this.title,
      required this.isComplite,
      required this.userName,
      required this.date});
}

class EventProvider extends ChangeNotifier {
  final _historyCollection = FirebaseFirestore.instance
      .collection("history")
      .where("groupId", isEqualTo: "guestGroup");

  List<Event> _events = [];

  List<Event> get events => _events;

  Map<DateTime, List<Event>> _eventsList = {};

  CalendarFormat _calendarFormat = CalendarFormat.month;

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  List<Event> getEvent(DateTime day) {
    return _eventsList[day] ?? [];
  }

  Map<DateTime, List<Event>> groupEvents(List<Event> events) {
    final groupedEvents = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    );

    for (final event in events) {
      final key = DateTime(event.date.year, event.date.month, event.date.day);
      if (groupedEvents.containsKey(key)) {
        groupedEvents[key]?.add(event);
      } else {
        groupedEvents[key] = [event];
      }
    }
    return groupedEvents;
  }

  Future<List<Event>> fetchEvents() async {
    final _historyCollection = await FirebaseFirestore.instance
        .collection("history")
        .where("groupId", isEqualTo: "guestGroup")
        .get();
    final events = _historyCollection.docs
        .map((doc) => Event(
            id: doc.id,
            title: doc['kajiName'],
            date: (doc['date'] as Timestamp).toDate(),
            isComplite: doc['isComplite'],
            userName: doc['userName']))
        .toList();
    _events = events;
    _eventsList = groupEvents(events);
    notifyListeners();
    return events;
  }
}
