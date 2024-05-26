/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:office_login/drawer.dart';
import 'dart:math';
import 'package:office_login/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double lat = 0.0;
  double long = 0.0;
  String formattedInTime = '';
  String formattedOutTime = '';
  DateTime? inTime;
  int count = 0;
  bool isLoading = true;
  bool isAdmin = false;
  double ofcLatitude = 0.0;
  double ofcLongitude = 0.0;
  double dist = 0.0;
  String? username;
  bool atLocation = false;
  bool hasCheckedIn = false; // To store check-in state

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Radius of the earth in meters
    double dLat = (lat2 - lat1) * (pi / 180);
    double dLon = (lon2 - lon1) * (pi / 180);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    dist = distance;
    return dist;
  }

  bool isWithinRange(double userLat, double userLon, double centerLat,
      double centerLon, double radius) {
    double distance = calculateDistance(userLat, userLon, centerLat, centerLon);
    debugPrint(distance.toString());
    return distance <= radius;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    initUserRole();
    _checkAndResetCount();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      formattedInTime = prefs.getString('formattedInTime') ?? '';
      formattedOutTime = prefs.getString('formattedOutTime') ?? '';
      hasCheckedIn =
          prefs.getBool('hasCheckedIn') ?? false; // Load check-in state
    });
  }

  Future<void> initUserRole() async {
    print('Checking user role...');
    bool role = await UserRoleUtils.checkUserRole();
    print("User role admin: $role");
    setState(() {
      isAdmin = role;
      isLoading = false;
    });
  }

  Future<void> _checkAndResetCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? prevDate = prefs.getString('prevDate');
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (prevDate != currentDate) {
      // Reset count if the current date is different from the previous date
      setState(() {
        count = 0;
      });
      // Update previous date in shared preferences
      await prefs.setString('prevDate', currentDate);
    }
  }

  void inPress() {
    if (!hasCheckedIn) {
      count++;
      fetchLocation();
    } else {
      _showAlertDialog('Error', 'You have already checked in.');
    }
  }

  Future<void> fetchLatitudeLongitude(String teamName) async {
    try {
      QuerySnapshot locationSnapshot = await FirebaseFirestore.instance
          .collection('location')
          .where('locationName', isEqualTo: teamName)
          .get();
      print(
          'Location Snapshot: ${locationSnapshot.docs.map((doc) => doc.data()).toList()}');

      if (locationSnapshot.docs.isNotEmpty) {
        setState(() {
          ofcLatitude = locationSnapshot.docs.first['latitude'];
          ofcLongitude = locationSnapshot.docs.first['longitude'];
        });
      } else {
        print('No location found for the provided teamName.');
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  Future<void> fetchLocationOut() async {
    if (hasCheckedIn) {
      await fetchLocationCore(false);
    } else {
      _showAlertDialog('Error', 'Please press IN first.');
    }
  }

  Future<void> fetchLocation() async {
    if (!hasCheckedIn) {
      await fetchLocationCore(true);
    } else {
      _showAlertDialog('Error', 'You have already checked in.');
    }
  }

  Future<void> fetchLocationCore(bool isInPress) async {
    try {
      var location = loc.Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) return;
      }

      loc.LocationData currentLoc = await location.getLocation();
      setState(() {
        lat = currentLoc.latitude!;
        long = currentLoc.longitude!;
        lat = 17.4235433; // Mocked for testing
        long = 78.3363692; // Mocked for testing
      });

      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: username)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        var teamName = usersSnapshot.docs.first['teamName'];
        await fetchLatitudeLongitude(teamName!);
      } else {
        print('No user found with the provided username.');
      }

      setState(() {
        atLocation = isWithinRange(lat, long, ofcLatitude, ofcLongitude, 50);
      });

      if (isInPress) {
        validateLocationWhenIn();
      } else {
        if (atLocation) {
          _updateOutTime();
        } else {
          _showAlertDialog('Error', 'You are not at office!!');
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch location: $e');
    }
  }

  void validateLocationWhenIn() {
    if (count <= 1 && atLocation) {
      inTime = DateTime.now();
      setState(() {
        formattedInTime = DateFormat("h:mm a").format(inTime!);
        hasCheckedIn = true; // Set check-in state
      });
      _updateInTime();
    } else if (count > 1) {
      _showAlertDialog('Error', 'Already pressed');
    } else {
      _showAlertDialog('Error', 'You are not at office!!');
    }
  }

  Future<void> _updateInTime() async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    CollectionReference logEntryCollection =
        FirebaseFirestore.instance.collection('LogEntry');
    DocumentReference logEntryDoc = logEntryCollection.doc(currentDate);
    DocumentSnapshot docSnapshot = await logEntryDoc.get();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username!);

    if (docSnapshot.exists) {
      List<dynamic> users = docSnapshot['users'];
      inTime = DateTime.now();
      for (var user in users) {
        if (user['name'] == username) {
          user['in'] = DateFormat("h:mm a").format(inTime!);
          break;
        }
      }
      await logEntryDoc.update({'users': users}).then((_) async {
        await prefs.setString('formattedInTime', formattedInTime);
        await prefs.setBool('hasCheckedIn', true); // Save check-in state
        print('Check-in time logged');
      }).catchError((error) {
        print('Error logging check-in time: $error');
      });
    } else {
      print('Log entry does not exist for $currentDate');
    }
  }

  Future<void> _updateOutTime() async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    CollectionReference logEntryCollection =
        FirebaseFirestore.instance.collection('LogEntry');
    DocumentReference logEntryDoc = logEntryCollection.doc(currentDate);
    DocumentSnapshot docSnapshot = await logEntryDoc.get();

    if (docSnapshot.exists) {
      List<dynamic> users = docSnapshot['users'];
      DateTime outTime = DateTime.now(); // Define outTime
      for (var user in users) {
        if (user['name'] == username) {
          user['out'] = DateFormat("h:mm a").format(outTime);
          break;
        }
      }
      await logEntryDoc.update({'users': users}).then((_) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          formattedOutTime =
              DateFormat("h:mm a").format(outTime); // Update state
        });
        await prefs.setString('formattedOutTime', formattedOutTime);
        print('Check-out time logged');
      }).catchError((error) {
        print('Error logging check-out time: $error');
      });
    } else {
      print('Log entry does not exist for $currentDate');
    }
  }

  Future<void> _resetOutTime() async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    CollectionReference logEntryCollection =
        FirebaseFirestore.instance.collection('LogEntry');
    DocumentReference logEntryDoc = logEntryCollection.doc(currentDate);
    DocumentSnapshot docSnapshot = await logEntryDoc.get();

    if (docSnapshot.exists) {
      List<dynamic> users = docSnapshot['users'];
      for (var user in users) {
        if (user['name'] == username) {
          user['out'] = '';
          break;
        }
      }
      await logEntryDoc.update({'users': users}).then((_) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          formattedOutTime = ''; // Reset out time in state
        });
        await prefs.setString('formattedOutTime', '');
        print('Check-out time reset');
      }).catchError((error) {
        print('Error resetting check-out time: $error');
      });
    } else {
      print('Log entry does not exist for $currentDate');
    }
  }

  Future<void> _showAlertDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Office Login'),
      ),
      drawer: ShowDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Welcome, $username!',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 20),
                Row(children: [
                  OutlinedButton(
                    onPressed: hasCheckedIn
                        ? null
                        : inPress, // Disable button if already checked in
                    child: const Text(
                      'IN',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: const CircleBorder(),
                      fixedSize: const Size.fromRadius(50.0),
                      backgroundColor: Color.fromARGB(255, 36, 180, 50),
                      side: BorderSide(
                          color: Colors
                              .green), // to match the background color with the border
                    ),
                  ),
                  const SizedBox(width: 30),
                  Text(formattedInTime,
                      style: TextStyle(color: Colors.white, fontSize: 22)),
                ]),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: fetchLocationOut,
                      child: Text(
                        'OUT',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        fixedSize: const Size.fromRadius(50.0),
                        backgroundColor: Color.fromARGB(255, 225, 28, 28),
                        side: BorderSide(
                            color: Color.fromARGB(255, 225, 28,
                                28)), // to match the background color with the border
                      ),
                    ),
                    const SizedBox(width: 30),
                    Text(formattedOutTime,
                        style: TextStyle(color: Colors.white, fontSize: 22)),
                  ],
                ),

                SizedBox(height: 20),
                //Text('In Time: $formattedInTime'),
                //Text('Out Time: $formattedOutTime'),
              ],
            ),
      floatingActionButton: ElevatedButton(
        onPressed: _resetOutTime,
        child: Text('Reset OUT'),
      ),
    );
  }
}
*/



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:office_login/drawer.dart';
import 'dart:math';
import 'package:office_login/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double lat = 0.0;
  double long = 0.0;
  String formattedInTime = '';
  String formattedOutTime = '';
  DateTime? inTime;
  DateTime? outTime;
  int count = 0;
  bool isLoading = true;
  bool isAdmin = false;
  double ofcLatitude = 0.0;
  double ofcLongitude = 0.0;

  double dist = 0.0;
  String? username; // Declare the username variable

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Radius of the earth in meters
    double dLat = (lat2 - lat1) * (pi / 180);
    double dLon = (lon2 - lon1) * (pi / 180);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    dist = distance;

    return dist;
  }

  bool isWithinRange(double userLat, double userLon, double centerLat,
      double centerLon, double radius) {
    double distance = calculateDistance(userLat, userLon, centerLat, centerLon);
    debugPrint(distance.toString());
    return distance <= radius;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load the user data when initializing
    initUserRole();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username'); // Assign the username
      formattedInTime = prefs.getString('formattedInTime') ?? '';
      formattedOutTime = prefs.getString('formattedOutTime') ?? '';
    });
  }

  Future<void> initUserRole() async {
    print('Checking user role...');
    bool role = await UserRoleUtils.checkUserRole();
    print("User role admin: $role");
    setState(() {
      isAdmin = role;
      isLoading = false;
    });
  }

  bool atLocation = false;
  void inPress() {
    count++;
    fetchLocation();
  }

  Future<void> fetchLatitudeLongitude(String teamName) async {
    try {
      QuerySnapshot locationSnapshot = await FirebaseFirestore.instance
          .collection('location')
          .where('locationName', isEqualTo: teamName)
          .get();
      print(
          'Location Snapshot: ${locationSnapshot.docs.map((doc) => doc.data()).toList()}');

      if (locationSnapshot.docs.isNotEmpty) {
        setState(() {
          ofcLatitude = locationSnapshot.docs.first['latitude'];
          ofcLongitude = locationSnapshot.docs.first['longitude'];
        });
      } else {
        print('No location found for the provided teamName.');
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  Future<void> fetchLocationOut() async {
    try {
      var location = loc.Location();
      bool serviceEnabled;
      loc.PermissionStatus permissionGranted;
      loc.LocationData currentLoc = await location.getLocation();
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          // Location services are still not enabled, handle accordingly
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          // Permission not granted, handle accordingly
          return;
        }
      }
      try {
        QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('name', isEqualTo: username)
            .get();
        print(
            'Users Snapshot: ${usersSnapshot.docs.map((doc) => doc.data()).toList()}');

        if (usersSnapshot.docs.isNotEmpty) {
          var teamName = usersSnapshot.docs.first['teamName'];
          await fetchLatitudeLongitude(teamName!);
        } else {
          print('No user found with the provided username.');
        }
      } catch (e) {
        print('Error fetching teamName: $e');
      }

      setState(() {
        //lat = currentLoc.latitude!;
        //long = currentLoc.longitude!;
        lat = 17.4235433;
        long = 78.3363692;
        print(ofcLatitude);
        print(ofcLongitude);
        //atLocation = isWithinRange(lat, long, 17.4438725, 78.4819231, 50);
        atLocation = isWithinRange(lat, long, ofcLatitude, ofcLongitude, 50);
      });

      debugPrint(atLocation.toString());
      debugPrint(lat.toString());

      //validateLocationWhenIn();
      if (atLocation) {
        _updateOutTime();
      } else {
        _showAlertDialog('Error', 'You are not at office!!');
      }
    } catch (e) {
      debugPrint('Failed to fetch location: $e');
    }
  }

  Future<void> fetchLocation() async {
    try {
      var location = loc.Location();
      bool serviceEnabled;
      loc.PermissionStatus permissionGranted;
      loc.LocationData currentLoc = await location.getLocation();
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          // Location services are still not enabled, handle accordingly
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          // Permission not granted, handle accordingly
          return;
        }
      }
      try {
        QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('name', isEqualTo: username)
            .get();
        print(
            'Users Snapshot: ${usersSnapshot.docs.map((doc) => doc.data()).toList()}');

        if (usersSnapshot.docs.isNotEmpty) {
          var teamName = usersSnapshot.docs.first['teamName'];
          await fetchLatitudeLongitude(teamName!);
        } else {
          print('No user found with the provided username.');
        }
      } catch (e) {
        print('Error fetching teamName: $e');
      }

      setState(() {
        //lat = currentLoc.latitude!;
        //long = currentLoc.longitude!;
        lat = 17.4235433;
        long = 78.3363692;
        print(ofcLatitude);
        print(ofcLongitude);
        //atLocation = isWithinRange(lat, long, 17.4438725, 78.4819231, 50);
        atLocation = isWithinRange(lat, long, ofcLatitude, ofcLongitude, 50);
      });

      debugPrint(atLocation.toString());
      debugPrint(lat.toString());

      validateLocationWhenIn();
    } catch (e) {
      debugPrint('Failed to fetch location: $e');
    }
  }

  void validateLocationWhenIn() {
    if (count <= 1 && atLocation) {
      inTime = DateTime.now();
      setState(() {
        formattedInTime = DateFormat("h:mm a").format(inTime!);
      });
      _updateInTime();
    } else if (count > 1) {
      _showAlertDialog('Error', 'Already pressed');
    } else {
      _showAlertDialog('Error', 'You are not at office!!');
    }
  }

  Future<void> _updateInTime() async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    CollectionReference logEntryCollection =
        FirebaseFirestore.instance.collection('LogEntry');

    DocumentReference logEntryDoc = logEntryCollection.doc(currentDate);

    // Retrieve the current log entry document
    DocumentSnapshot docSnapshot = await logEntryDoc.get();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.setString('username', username!);
    await prefs.getString('username');


    if (docSnapshot.exists) {
      // Get the users array from the document
      List<dynamic> users = docSnapshot['users'];

      // Find the user who is checking out and update the 'out' field
      /*
      inTime = DateTime.now();
      for (var user in users) {
        if (user['name'] == username) {
          // replace with actual employee ID

          user['in'] = DateFormat("h:mm a").format(inTime!);
          break;
        }
      }*/
      DocumentReference documentReference =
        FirebaseFirestore.instance.collection('LogEntry').doc(currentDate);
    // Get the current document snapshot
    DocumentSnapshot documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists) {
      print('yes');
      List<dynamic> users = documentSnapshot['users'];

      // Find the index of the user map in the array
      int userIndex = users.indexWhere((user) => user['name'] == username);
      print('888');

      if (userIndex != -1) {
        // Update the user's in and out fields
        print('999');

        users[userIndex]['in'] = formattedInTime;

        // Update the document with the modified users array
        await documentReference.update({'users': users}).then((value) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('formattedInTime', formattedInTime);
          print('Check-IN time logged');
        }).catchError((error) {
          print("Failed to update user log entry: $error");
        });
      } else {
        print("User not found in the array");
      }
    } else {
      print("Document does not exist");
    }


      // Update the document with the modified users array
      /*
      await logEntryDoc.update({
        'users': users,
      }).then((_) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('formattedInTime', formattedInTime);
        print('Check-in time logged');
      }).catchError((error) {
        print('Error logging check-in time: $error');
      });
      */
    } else {
      print('Log entry does not exist for $currentDate');
    }
  }

  Future<void> _updateOutTime() async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    CollectionReference logEntryCollection =
        FirebaseFirestore.instance.collection('LogEntry');

    DocumentReference logEntryDoc = logEntryCollection.doc(currentDate);

    // Retrieve the current log entry document
    DocumentSnapshot docSnapshot = await logEntryDoc.get();

    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('LogEntry').doc(currentDate);
    // Get the current document snapshot
    DocumentSnapshot documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists) {
      print('yes');
      List<dynamic> users = documentSnapshot['users'];

      // Find the index of the user map in the array
      int userIndex = users.indexWhere((user) => user['name'] == username);
      print('888');

      if (userIndex != -1) {
        // Update the user's in and out fields
        print('999');

        users[userIndex]['out'] = formattedOutTime;

        // Update the document with the modified users array
        await documentReference.update({'users': users}).then((value) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('formattedOutTime', formattedOutTime);
          print('Check-out time logged');
        }).catchError((error) {
          print("Failed to update user log entry: $error");
        });
      } else {
        print("User not found in the array");
      }
    } else {
      print("Document does not exist");
    }

/*
    if (docSnapshot.exists) 
    {
      // Get the users array from the document
      List<dynamic> users = docSnapshot['users'];

      // Find the user who is checking out and update the 'out' field
      outTime = DateTime.now();
      for (var user in users) {
        if (user['name'] == username) {
          // replace with actual employee ID
          user['out'] = DateFormat("h:mm a").format(outTime!);
        

          
          break;
        }
      }

      // Update the document with the modified users array
      /*
      await logEntryDoc.update({
        'users': users,
      }).then((_) async 
      {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('formattedOutTime', formattedOutTime);
        print('Check-out time logged');
      }).catchError((error) {
        print('Error logging check-out time: $error');
      });*/
    } else {
      print('Log entry does not exist for $currentDate');
    }
      */
  }

  Future<void> _resetOutTime() async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    CollectionReference logEntryCollection =
        FirebaseFirestore.instance.collection('LogEntry');

    DocumentReference logEntryDoc = logEntryCollection.doc(currentDate);

    // Retrieve the current log entry document
    DocumentSnapshot docSnapshot = await logEntryDoc.get();

    if (docSnapshot.exists) {
      // Get the users array from the document
      List<dynamic> users = docSnapshot['users'];

      // Find the user who is checking out and update the 'out' field
      for (var user in users) {
        if (user['empId'] == '9874561') {
          // replace with actual employee ID
          user['out'] = '';
          break;
        }
      }

      // Update the document with the modified users array
      await logEntryDoc.update({
        'users': users,
      }).then((_) {
        print('Check-out time logged');
      }).catchError((error) {
        print('Error logging check-out time: $error');
      });
    } else {
      print('Log entry does not exist for $currentDate');
    }
    // Clear out time in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('formattedOutTime', '');

    debugPrint('Check-out time reset');
  }

  bool flag = true;
  void outPressed() {
    if (formattedInTime.isEmpty) {
      _showAlertDialog('Error', "Didnt click the IN Button");
    } else {
      DateTime outTime = DateTime.now();
      setState(() {
        formattedOutTime = DateFormat("h:mm a").format(outTime);
        flag = false;
      });
      fetchLocationOut();
    }
  }

  void resetOutButton() {
    setState(() {
      flag = true;
      formattedOutTime = '';
    });
    _resetOutTime();
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: isAdmin ? ShowDrawer() : null,
      body: Center(
        child: Column(
          children: [
            const Text('Home Page'),
            const SizedBox(height: 20),
            Column(
              children: [
                Text(lat.toString()),
                const SizedBox(height: 30),
                Text(long.toString()),
                const SizedBox(height: 30),
                Text(dist.toString()),
                const SizedBox(height: 30),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                OutlinedButton(
                    onPressed: () {
                      inPress();
                    },
                    child: const Text(
                      'IN',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      fixedSize: Size.fromRadius(50.0),
                      backgroundColor: Color.fromARGB(255, 36, 180, 50),
                    )),
                const SizedBox(width: 30),
                Text(formattedInTime,
                    style: TextStyle(color: Colors.white, fontSize: 22)),
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                OutlinedButton(
                    onPressed: () {
                      {
                        outPressed();
                      }
                    },
                    child: const Text(
                      'OUT',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      fixedSize: Size.fromRadius(50.0),
                      backgroundColor: Color.fromARGB(255, 225, 28, 28),
                    )),
                const SizedBox(width: 30),
                Text(formattedOutTime,
                    style: TextStyle(color: Colors.white, fontSize: 22)),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: OutlinedButton(
        onPressed: () {
          resetOutButton();
        },
        child: const Text(
          'Reset\n Out',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}
