import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

class Signupme extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signupme> {
  final TextEditingController _usernameController = TextEditingController();
  String devId = '';

  Future<void> _signup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = _usernameController.text;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = await _getDeviceId(deviceInfo, context);

    if (username.isNotEmpty && deviceId.isNotEmpty) {
      await prefs.setString('username', username);
      await prefs.setString('device_id', deviceId);
      /*Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );*/
    }
  }

  Future<String> _getDeviceId(
      DeviceInfoPlugin deviceInfo, BuildContext context) async {
    if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      print('running on ${webBrowserInfo.userAgent}');
      setState(
        () {
          devId = webBrowserInfo.userAgent!;
        },
      );
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}');
      setState(() {
        devId = androidInfo.model;
      });
      return androidInfo.id ?? ''; // Use the correct identifier for Android
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}');
      setState(() {
        devId = iosInfo.utsname.machine;
      });
      return iosInfo.identifierForVendor ??
          ''; // Use the correct identifier for iOS
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signup,
              child: Text('Signup'),
            ),
          ],
        ),
      ),
    );
  }
}
