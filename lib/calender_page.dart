import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profiele_web/model/history.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class Calender extends StatefulWidget {
  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  Map<DateTime, List> _eventsList = {};

  DateTime _focused = DateTime.now();
  DateTime? _selected;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    super.initState();

    _selected = _focused;
    // _eventsList = {
    //   DateTime.now().subtract(Duration(days: 2)): ['Test ei', 'Test Bi'],
    //   DateTime.now(): ['Test Ci', 'Test Di', 'Test E', 'Test ehu'],
    // };
  }

  @override
  Widget build(BuildContext context) {
    // final _events = LinkedHashMap<DateTime, List>(
    //   equals: isSameDay,
    //   hashCode: getHashCode,
    // )..addAll(_eventsList);

    // List getEvent(DateTime day) {
    //   return _events[day] ?? [];
    // }

    return ChangeNotifierProvider<HistoryModel>(
        create: (_) => HistoryModel()..fetchFromFirebaseEvent(),
        child: Consumer<HistoryModel>(builder: (context, model, child) {
          print('firebaseList${model.eventMap}');

          // final _eventsList = Map.fromIterables(model.eventList,key:(item)=>item.value:);
          if (model.eventMap != null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final _events = LinkedHashMap<DateTime, List>(
            equals: isSameDay,
            hashCode: getHashCode,
          )..addAll(model.eventMap);

          List getEvent(DateTime day) {
            return _events[day] ?? [];
          }

          return Expanded(
            child: Column(children: [
              TableCalendar(
                firstDay: DateTime.utc(2015, 4, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                ),
                selectedDayPredicate: (day) {
                  return isSameDay(_selected, day);
                },
                onDaySelected: (selected, focused) {
                  if (!isSameDay(_selected, selected)) {
                    setState(() {
                      _selected = selected;
                      _focused = focused;
                    });
                  }
                },
                eventLoader: (date) {
                  return getEvent(date);
                },
                focusedDay: _focused,
                calendarBuilders: CalendarBuilders(
                  dowBuilder: (context, day) {
                    if (day.weekday == DateTime.sunday) {
                      final text = DateFormat.E().format(day);
                      return Center(
                          child: Text(
                        text,
                        style: const TextStyle(color: Colors.red),
                      ));
                    }
                  },
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return _buildEventsMarker(date, events);
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              ListView(
                shrinkWrap: true,
                children: getEvent(_selected!)
                    .map((event) => Card(
                          child: ListTile(
                            title: Text(event.toString()),
                            subtitle: Text(event.toString()),
                            trailing: const Icon(Icons.check_box),
                          ),
                        ))
                    .toList(),
              )
            ]),
          );
        }));
  }

  //historyに登録されているグループ全体の情報をとってきて表示。

  Widget _buildEventsMarker(DateTime date, List events) {
    return Positioned(
      right: 13,
      bottom: 5,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red[300],
        ),
        width: 12,
        height: 12,
        child: Center(
          child: Text(
            '${events.length}',
            style: TextStyle().copyWith(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ),
      ),
    );
  }
}
