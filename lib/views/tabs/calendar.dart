import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart';
import 'package:aidly/utils/requests.dart';
import 'dart:async';

class CalendarScreen extends StatefulWidget {
  static const String id = 'calendar_screen';

//TODO: We need to decide how to save the input of the events
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarController _calendarController;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  TextEditingController _eventController;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _eventController = TextEditingController();
    _events = {};
    _selectedEvents = [];
    Future.sync(() => initPrefs()).then((value) => retrieveEvents()).then((value) {
      setState((){_selectedEvents = _events[_calendarController.selectedDay];});
    });
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _events = Map<DateTime, List<dynamic>>.from(
          decodeMap(json.decode(prefs.get('events') ?? '{}')));
    });
  }

  // Encode Date Time Helper Method
  Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  // decode Date Time Helper Method
  Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }

  // retrieve events
  retrieveEvents() async {
    //await initPrefs();
    Response res =
        await HttpRequests.getJson("http://165.227.87.42:1234/user/events");
    List eventsJson = json.decode(res.body)['events'];
    eventsJson.forEach((element) {
      DateTime date = DateTime.parse(element['date']);
      setState(() {
        if (_events[date] != null) {
          _events[date].add(element['title']);
        } else {
          _events[date] = [element['title']];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        backgroundColor: Colors.teal[900],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TableCalendar(
              events: _events,
              initialCalendarFormat: CalendarFormat.month,
              calendarStyle: CalendarStyle(
                markersColor: Colors.purple,
                todayColor: Colors.teal,
                selectedColor: Colors.blue,
                todayStyle:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              headerStyle: HeaderStyle(
                formatButtonDecoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                formatButtonTextStyle: TextStyle(color: Colors.white),
                formatButtonShowsNext: false,
              ),
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarController: _calendarController,
              onDaySelected: (date, events) {
                setState(() {
                  _selectedEvents = events;
                });
              },
            ),
            ..._selectedEvents.map(
              (event) => Padding(
                padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            event,
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[900],
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          _showAddDialog();
        },
      ),
    );
  }

  _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Calendar Event:'),
        content: TextFormField(
          controller: _eventController,
          keyboardType: TextInputType.multiline,
          maxLines: 4,
        ),
        actions: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                color: Colors.deepOrange,
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    if (_eventController.text.isEmpty) return;
                    if (_events[_calendarController.selectedDay] != null) {
                      _events[_calendarController.selectedDay]
                          .add(_eventController.text);
                    } else {
                      _events[_calendarController.selectedDay] = [
                        _eventController.text
                      ];
                    }
                    prefs.setString('events', json.encode(encodeMap(_events)));
                    Navigator.of(context).pop();
                    _selectedEvents = _events[_calendarController.selectedDay];
                    _eventController.clear();
                  });
                },
              ),
              SizedBox(
                width: 10.0,
              ),
              FlatButton(
                color: Colors.grey,
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
