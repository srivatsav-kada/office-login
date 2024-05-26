/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:office_login/drawer.dart';
// import 'package:intl/intl.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime? selectedDate;
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: ShowDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Text(
                selectedDate == null
                    ? 'No date selected'
                    : ' ${DateFormat('dd-MM-yyyy').format(selectedDate!)}',
              ),
              const SizedBox(
                height: 20,
              ),
              OutlinedButton(
                  onPressed: () {
                    selectDate(context);
                  },
                  child: const Text('Select Date'))
            ],
          ),
        ),
      ),
    );
  }
}

*/

/*

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:office_login/drawer.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime? selectedDate;
  List<DocumentSnapshot> logs = [];
  bool isLoading = true;
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024, 5, 17),
      lastDate: DateTime.now(),
      selectableDayPredicate: (DateTime date) {
        if (date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday) {
          return false;
        }
        return true;
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('LogEntry')
          .doc(DateFormat('dd-MM-yyyy').format(selectedDate!))
          .collection('users')
          .get();

      setState(() {
        logs = querySnapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching logs: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: ShowDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Text(
                selectedDate == null
                    ? 'No date selected'
                    : ' ${DateFormat('dd-MM-yyyy').format(selectedDate!)}',
              ),
              const SizedBox(
                height: 20,
              ),
              OutlinedButton(
                  onPressed: () {
                    selectDate(context);
                  },
                  child: const Text('Select Date')),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Name'),
                  Text('Hours'),
                  Text('Login'),
                  Text('Logout'),
                ],
              ),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : logs.isEmpty
                      ? const Center(child: Text('No logs found '))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot userLog = logs[index];
                              Map<String, dynamic>? data =
                                  userLog.data() as Map<String, dynamic>?;

                              if (data == null) {
                                return const ListTile(
                                  title: Text('No data available'),
                                );
                              }
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(data['name']),
                                      Text(data['in']),
                                      Text(data['in']),
                                      Text(data['out']),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

*/

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:intl/intl.dart';
import 'package:office_login/drawer.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime? selectedDate;

  // List<DocumentSnapshot> logs = [];

  // bool isLoading = true;

  List<Map<String, dynamic>> users = [];

  bool isLoading = true;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024, 5, 17),
      lastDate: DateTime.now(),
      selectableDayPredicate: (DateTime date) {
        if (date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday) {
          return false;
        }

        return true;
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }

    // _fetchLogs();

    fetchLogEntries();
  }

  // Future<void> _fetchLogs() async {

  //   try {

  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance

  //         .collection('LogEntry')

  //         .doc(DateFormat('dd-MM-yyyy').format(selectedDate!))

  //         .collection('users')

  //         .get();

  //     setState(() {

  //       logs = querySnapshot.docs;

  //       isLoading = false;

  //     });

  //   } catch (e) {

  //     debugPrint('Error fetching logs: $e');

  //     setState(() {

  //       isLoading = false;

  //     });

  //   }

  // }

  Future<void> fetchLogEntries() async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    CollectionReference logEntryCollection =
        FirebaseFirestore.instance.collection('LogEntry');

    DocumentSnapshot logEntryDoc =
        await logEntryCollection.doc(currentDate).get();

    if (logEntryDoc.exists) {
      setState(() {
        users = List<Map<String, dynamic>>.from(logEntryDoc['users']);

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: ShowDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Text(
                selectedDate == null
                    ? 'No date selected'
                    : ' ${DateFormat('dd-MM-yyyy').format(selectedDate!)}',
              ),
              const SizedBox(
                height: 20,
              ),
              OutlinedButton(
                  onPressed: () {
                    selectDate(context);
                  },
                  child: const Text('Select Date')),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Name'),
                  Text('Hours'),
                  Text('Login'),
                  Text('Logout'),
                ],
              ),
              isLoading
                  ? const Center(child: Column())
                  : users.isEmpty
                      ? const Center(child: Text('No logs found '))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              var user = users[index];

                              Duration? difference;

                              if (user['in'].toString().isNotEmpty &&
                                  user['out'].toString().isNotEmpty) {
                                DateTime time1 = DateFormat("h:mm a")
                                    .parse(user['in'].toString());

                                DateTime time2 = DateFormat("h:mm a")
                                    .parse(user['out'].toString());

                                difference = time2.difference(time1);
                              }

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    user['name'],
                                  ),
                                  difference != null
                                      ? Text(
                                          '${difference.inHours} hr ${difference.inMinutes.remainder(60)} min')
                                      : const Text('--'),
                                  Text(
                                      ' ${user['in'] != '' ? user['in'] : 'Not In'}'),
                                  Text(
                                      ' ${user['out'] != '' ? user['out'] : 'Not Out'}'),
                                ],
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
