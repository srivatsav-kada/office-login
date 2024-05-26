/*
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:office_login/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    });
    _createLogEntryIfNotExists();
  }

  Future<void> _createLogEntryIfNotExists() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastCreatedDate = prefs.getString('lastCreatedDate') ?? '';

    final DateTime now = DateTime.now();
    final DateTime fiveAM = DateTime(now.year, now.month, now.day, 5);
    final String today = DateFormat('dd-MM-yyyy').format(now);
    print('*****');
    print(lastCreatedDate);
    print('*****');
    print(today);
    // Check if the current time is past 5:00 AM and today's log hasn't been created yet
    // if (now.isAfter(fiveAM) && lastCreatedDate != today)
    if (true) {
      QuerySnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      List<QueryDocumentSnapshot> users = userSnapshot.docs;

      // Create a log entry for each user
      for (var user in users) {
        String userId = user.id;
        Map<String, dynamic> userData = user.data() as Map<String, dynamic>;

        DocumentReference logEntryRef = FirebaseFirestore.instance
            .collection('LogEntry')
            .doc(today)
            .collection('users')
            .doc(userId);

        await logEntryRef.set({
          'name': userData['name'],
          'teamName': userData['teamName'],
          'empId': userData['empId'],
          'in': '',
          'out': '',
        });
      }

      await prefs.setString('lastCreatedDate', today);
      debugPrint('LogEntries for $today created');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: CircleAvatar(
        backgroundImage: AssetImage('assets/images/splashicon.jpg'),
        radius: 50,
      )),
    );
  }
}

*/

/*

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:office_login/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'signup.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? username;
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    });
    // _createLogEntryIfNotExists();
    // _createLogEntryForToday();
    addLogEntry();
  }

//////////////////////////////////////////
// Function to get the log entry for the current date
  Future<Map<String, dynamic>> getLogEntryForCurrentDate() async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DocumentSnapshot logEntrySnapshot = await FirebaseFirestore.instance
        .collection('LogEntry')
        .doc(currentDate)
        .get();

    if (logEntrySnapshot.exists) {
      return logEntrySnapshot.data() as Map<String, dynamic>;
    } else {
      return {};
    }
  }

// Function to get the in time for a specific user
  Future<String?> getInTimeForUser(String userId) async {
    Map<String, dynamic> logEntry = await getLogEntryForCurrentDate();

    if (logEntry.isNotEmpty) {
      List<dynamic> users = logEntry['users'];
      for (var user in users) {
        if (user['empId'] == userId) {
          return user['in'];
        }
      }
    }

    return '';
  }

// Function to create the users data list
  Future<List<Map<String, dynamic>>> createUsersDataList(
      List<DocumentSnapshot> usersSnapshot) async {
    List<Map<String, dynamic>> usersData = [];

    for (var userDoc in usersSnapshot) {
      String userId = userDoc['empId'];
      String usname = userDoc['name'];
      print('printing userID and name');
      print(userDoc['empId']);
      print(userDoc['name']);
      String? inTime = (await getInTimeForUser(userId) != '')
          ? await getInTimeForUser(userId)
          : '';
      print('intime is');
      print(inTime);
      usersData.add({
        'empId': userDoc['empId'],
        'name': userDoc['name'],
        'teamName': userDoc['teamName'],
        'in': inTime ?? '',
        'out': '2:15 PM'
        //'out': (userDoc['name'] == dummyusername) ? dummyOut : '',
      });
    }
    print('here it is returning UsersDatea');
    print(usersData);
    print('----------------');
    return usersData;
  }

// Example usage
  void fetchData() async {
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    print('printing userssnapshot');
    print(usersSnapshot);
    print(usersSnapshot.docs);
    List<Map<String, dynamic>> usersData =
        await createUsersDataList(usersSnapshot.docs);
    print('printing users data');
    print(usersData);
  }

  Future<void> addLogEntry() async {
    // Get the current date
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Reference to Firestore collections
    CollectionReference logEntryCollection =
        FirebaseFirestore.instance.collection('LogEntry');
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    // Check if the document for the current date already exists
    DocumentSnapshot logEntryDoc =
        await logEntryCollection.doc(currentDate).get();

    //-------------------

    if (logEntryDoc.exists) {
      debugPrint('Log entry already exists for $currentDate');
      fetchData();
      /*
      QuerySnapshot usersSnapshot = await usersCollection.get();

      // Map each user to the LogEntry
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var dummyIn = prefs.getString('formattedInTime');
      var dummyOut = prefs.getString('formattedOutTime');
      var dummyusername = prefs.getString('username');
      await FirebaseFirestore.instance
          .collection('LogEntry')
          .doc(currentDate)
          .get();

      List<Map<String, dynamic>> usersData = usersSnapshot.docs.map((userDoc) {
        return {
          'empId': userDoc['empId'],
          'name': userDoc['name'],
          'teamName': userDoc['teamName'],
          'in': (userDoc['name'] == dummyusername) ? dummyIn : '',
          'out': (userDoc['name'] == dummyusername) ? dummyOut : '',
        };
      }).toList();

      // Create a new document in 'LogEntry' collection for the current date
      await logEntryCollection.doc(currentDate).update({
        'date': currentDate,
        'users': usersData,
      });
      */
    } else {
      // Get all users from the 'users' collection
      QuerySnapshot usersSnapshot = await usersCollection.get();

      // Map each user to the LogEntry
      List<Map<String, dynamic>> usersData = usersSnapshot.docs.map((userDoc) {
        return {
          'empId': userDoc['empId'],
          'name': userDoc['name'],
          'teamName': userDoc['teamName'],
          'in': '', // Defaulting 'in' field to null
          'out': '', // Defaulting 'out' field to null
        };
      }).toList();

      // Create a new document in 'LogEntry' collection for the current date
      await logEntryCollection.doc(currentDate).set({
        'date': currentDate,
        'users': usersData,
      });

      debugPrint('Log entry added for $currentDate');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: CircleAvatar(
        backgroundImage: AssetImage('assets/images/splashicon.jpg'),
        radius: 50,
      )),
    );
  }
}

*/

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:office_login/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'signup.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? username;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    });
    addLogEntry();
  }

  Future<Map<String, dynamic>> getLogEntryForCurrentDate() async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DocumentSnapshot logEntrySnapshot = await FirebaseFirestore.instance
        .collection('LogEntry')
        .doc(currentDate)
        .get();

    if (logEntrySnapshot.exists) {
      return logEntrySnapshot.data() as Map<String, dynamic>;
    } else {
      return {};
    }
  }

  Future<String?> getInTimeForUser(String userId) async {
    Map<String, dynamic> logEntry = await getLogEntryForCurrentDate();

    if (logEntry.isNotEmpty) {
      List<dynamic> users = logEntry['users'];
      for (var user in users) {
        if (user['empId'] == userId) {
          return user['in'];
        }
      }
    }

    return '';
  }

  Future<String?> getOutTimeForUser(String userId) async {
    Map<String, dynamic> logEntry = await getLogEntryForCurrentDate();

    if (logEntry.isNotEmpty) {
      List<dynamic> users = logEntry['users'];
      for (var user in users) {
        if (user['empId'] == userId) {
          return user['out'];
        }
      }
    }

    return '';
  }

  Future<List<Map<String, dynamic>>> createUsersDataList(
      List<DocumentSnapshot> usersSnapshot) async {
    List<Map<String, dynamic>> usersData = [];

    for (var userDoc in usersSnapshot) {
      String userId = userDoc['empId'];
      String usname = userDoc['name'];
      String? inTime = await getInTimeForUser(userId);
      String? outTime = await getOutTimeForUser(userId);

      usersData.add({
        'empId': userDoc['empId'],
        'name': userDoc['name'],
        'teamName': userDoc['teamName'],
        'in': inTime ?? '',
        'out': outTime ?? ''
      });
    }

    return usersData;
  }

  void fetchData() async {
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    List<Map<String, dynamic>> usersData =
        await createUsersDataList(usersSnapshot.docs);
    await updateLogEntry(usersData);
  }

  Future<void> updateLogEntry(List<Map<String, dynamic>> usersData) async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DocumentReference logEntryDoc =
        FirebaseFirestore.instance.collection('LogEntry').doc(currentDate);

    await logEntryDoc.update({
      'users': usersData,
    }).then((_) {
      debugPrint('Log entry updated for $currentDate');
    }).catchError((error) {
      debugPrint('Failed to update log entry: $error');
    });
  }

  Future<void> addLogEntry() async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    CollectionReference logEntryCollection =
        FirebaseFirestore.instance.collection('LogEntry');
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    DocumentSnapshot logEntryDoc =
        await logEntryCollection.doc(currentDate).get();

    if (logEntryDoc.exists) {
      debugPrint('Log entry already exists for $currentDate');
      fetchData();
    } else {
      QuerySnapshot usersSnapshot = await usersCollection.get();

      List<Map<String, dynamic>> usersData = usersSnapshot.docs.map((userDoc) {
        return {
          'empId': userDoc['empId'],
          'name': userDoc['name'],
          'teamName': userDoc['teamName'],
          'in': '',
          'out': '',
        };
      }).toList();

      await logEntryCollection.doc(currentDate).set({
        'date': currentDate,
        'users': usersData,
      });

      debugPrint('Log entry added for $currentDate');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircleAvatar(
          backgroundImage: AssetImage('assets/images/splashicon.jpg'),
          radius: 50,
        ),
      ),
    );
  }
}
