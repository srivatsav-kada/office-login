/*
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'signup.dart';
import 'home_page.dart';
import 'invalid_credentials.dart';

class AuthCheck extends StatelessWidget {
  Future<String> _checkCredentials(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? storedDeviceId = prefs.getString('device_id');

    if (username == null || storedDeviceId == null) {
      return 'signup';
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = await _getDeviceId(deviceInfo, context);

    if (username.isNotEmpty && storedDeviceId == deviceId) {
      return 'home';
    } else {
      return 'invalid';
    }
  }

  Future<String> _getDeviceId(DeviceInfoPlugin deviceInfo, BuildContext context) async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id ?? ''; // Use the correct identifier for Android
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? ''; // Use the correct identifier for iOS
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _checkCredentials(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          if (snapshot.data == 'signup') {
            return Signup();
          } else if (snapshot.data == 'invalid') {
            return InvalidCredentials();
          } else {
            return HomePage();
          }
        }
      },
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:office_login/userentry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

import 'signup_ks.dart';
import 'user_home.dart';
import 'invalid_credentials.dart';

class AuthCheck extends StatelessWidget {
  Future<String> _checkCredentials(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? storedDeviceId = prefs.getString('device_id');
    print("////////////");
    print(username);
    print("////////////");
    print(storedDeviceId);

    if (username == null || storedDeviceId == null) {
      return 'signup';
    }
    print('99');
    // Initialize Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Check if user exists with provided username and device ID
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('users')
          .where('name', isEqualTo: username)
          .where('devId', isEqualTo: storedDeviceId)
          .get();
      print('666');
      print(snapshot.docs);
      if (snapshot.docs.isNotEmpty) {
        // User exists in Firestore
        return 'home';
      } else {
        // User does not exist in Firestore
        return 'invalid';
      }
    } catch (e) {
      print(e);
      print('dfsfsadf');
      return 'invalid';
    }
  }

  Future<String> _getDeviceId(
      DeviceInfoPlugin deviceInfo, BuildContext context) async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id ?? ''; // Use the correct identifier for Android
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ??
          ''; // Use the correct identifier for iOS
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _checkCredentials(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          print('555');
          print(snapshot.data);
          if (snapshot.data == 'signup') {
            return Signup();
          } else if (snapshot.data == 'invalid') {
            return InvalidCredentials();
          } else {
            //return HomePage();
            return HomePage();
          }
        }
      },
    );
  }
}
