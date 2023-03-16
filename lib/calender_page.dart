import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profiele_web/model/history.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class Calender extends StatefulWidget {
  const Calender({super.key});

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  Map<DateTime, List<Event>> _eventsList = {};

  DateTime _focused = DateTime.now();
  DateTime? _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EventProvider>(
        create: (_) => EventProvider()..fetchEvents(),
        child: Consumer<EventProvider>(builder: (context, model, child) {
          // if (model.events != null) {
          //   return const Center(
          //     child: CircularProgressIndicator(),
          //   );
          // }

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
                  return model.getEvent(date);
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
                children: model
                    .getEvent(_selected!)
                    .map((event) => Card(
                          child: ListTile(
                            title: Text(event.title.toString()),
                            subtitle: Text(event.userName.toString()),
                            trailing: event.isComplite != false
                                ? const Icon(Icons.check_box)
                                : const Icon(Icons.check_box_outline_blank),
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
