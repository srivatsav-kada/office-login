import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:office_login/user_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  Future<String> _getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      var webInfo = await deviceInfo.webBrowserInfo;
      return webInfo.userAgent ?? '';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      var androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id ?? '';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      var iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? '';
    }
    return '';
  }

  Future<void> _checkUsername(BuildContext context) async {
    String deviceId = await _getDeviceId();
    final String username = _usernameController.text.trim();
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: username)
        .where('devId',isEqualTo: deviceId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Username exists, do something
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setString('device_id', deviceId);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      // Username doesn't exist, do something else
      print('Username does not exist');
    }
  }

  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _checkUsername(context);
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
