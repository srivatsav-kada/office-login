/*
import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:office_login/drawer.dart';
import 'package:office_login/dummypage.dart';
import 'package:office_login/firestorefunc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:office_login/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  
  @override
  void initState() {
    super.initState();
    
  }

  String devId = '';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController empIdController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<String> _signupnew() async {
    print('here0');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = nameController.text;
    //if you want to use the empid as the primary u can change the above
    print('here1');
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = await _getDeviceId(deviceInfo, context);
    print(deviceId);
    print('above......');
    print(devId);
    setState(() {
      devId = deviceId;
    });
    print(devId);
    print('bewlo......');

    if (username.isNotEmpty && deviceId.isNotEmpty) {
      await prefs.setString('username', username);
      await prefs.setString('device_id', deviceId);
      /*
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DummpyPage()),
      );
      */
    }
    return deviceId;
  }

  Future<String> _getDeviceId(
      DeviceInfoPlugin deviceInfo, BuildContext context) async {
    print('here2');
    if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      print('running on ${webBrowserInfo.userAgent}');
      print('here3');
      print(webBrowserInfo.data);
      print(webBrowserInfo.deviceMemory);
      print(webBrowserInfo.userAgent);
      print(webBrowserInfo.product);
      setState(
        () {
          devId = webBrowserInfo.userAgent!;
        },
      );
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}');
      print('here4');
      setState(() {
        devId = androidInfo.model;
      });
      return androidInfo.id ?? ''; // Use the correct identifier for Android
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}');
      print('here5');
      setState(() {
        devId = iosInfo.utsname.machine;
      });
      return iosInfo.identifierForVendor ??
          ''; // Use the correct identifier for iOS
    }
    print('here6');
    return '';
  }

  @override
  Widget build(BuildContext context) {
    String selectedTeam = 'iMobile Canada';
    List<String> teams = [
      'iMobile Canada',
      'iMobile Germany',
      'Flutter',
      'SPP Canada',
      'Hello Canada',
      'Fairpay'
    ];

    return Scaffold(
        
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 50, top: 50, bottom: 20, right: 20),
              child: Container(
                color: Colors.transparent,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Register Here',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'This is required';
                          }
                          return null;
                        },
                        controller: nameController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.black),
                            errorStyle: TextStyle(color: Colors.red),
                            labelText: 'Enter Name',
                            hintStyle: TextStyle(color: Colors.black),
                            hintText: 'Eg:-rahul'),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        validator: (String? value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 7) {
                            return 'Enter your 7-digit emp id ';
                          }
                          return null;
                        },
                        controller: empIdController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.black),
                            errorStyle: TextStyle(color: Colors.red),
                            labelText: 'Enter Emp Id ',
                            hintStyle: TextStyle(color: Colors.black),
                            hintText: 'Eg:-4562311'),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      DropdownButtonFormField(
                        value: selectedTeam,
                        items: teams.map((String team) {
                          return DropdownMenuItem(
                            value: team,
                            child: Text(team),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          selectedTeam = value!;
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'This is required ';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Select Team',
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            //Future<String> devId = _signupnew();
                            String finalDevId = await _signupnew();
                            firestoreService.addUser(
                                // emailController.text,
                                nameController.text,
                                selectedTeam,
                                empIdController.text,
                                finalDevId);

                            print('Sign up valid');
                          }
                        },
                        child: const Text(
                          'Submit',
                          style: TextStyle(color: Colors.black, fontSize: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

*/

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:office_login/invalid_credentials.dart';
import 'package:office_login/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'drawer.dart';
import 'dummypage.dart';
import 'firestorefunc.dart';
import 'utils.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String devId = '';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController empIdController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<String> teams = [];
  String? selectedTeam;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    try {
      final QuerySnapshot result =
          await FirebaseFirestore.instance.collection('teams').get();
      final List<String> loadedTeams =
          result.docs.map((doc) => doc['teamName'] as String).toList();

      setState(() {
        teams = loadedTeams;
        if (teams.isNotEmpty) {
          selectedTeam = teams.first;
        }
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching teams: $error';
        isLoading = false;
      });
    }
  }

  Future<String> _signupNew() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = nameController.text;
    String deviceId = await _getDeviceId();

    if (username.isNotEmpty && deviceId.isNotEmpty) {
      await prefs.setString('username', username);
      await prefs.setString('device_id', deviceId);
    }

    return deviceId;
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    const Text(
                      'Register Here',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 25),
                    _buildTextField(
                      controller: nameController,
                      label: 'Enter Name',
                      hintText: 'Eg:-rahul',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(
                      controller: empIdController,
                      label: 'Enter Emp Id',
                      hintText: 'Eg:-4562311',
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 7) {
                          return 'Enter your 7-digit emp id';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    isLoading
                        ? CircularProgressIndicator()
                        : errorMessage.isNotEmpty
                            ? Text(errorMessage,
                                style: TextStyle(color: Colors.red))
                            : DropdownButtonFormField<String>(
                                value: selectedTeam,
                                items: teams.map((team) {
                                  return DropdownMenuItem(
                                    value: team,
                                    child: Text(team),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedTeam = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'This is required';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Select Team',
                                ),
                              ),
                    const SizedBox(height: 30),
                    OutlinedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          String finalDevId = await _signupNew();
                          firestoreService.addUser(
                            nameController.text,
                            selectedTeam ?? '',
                            empIdController.text,
                            finalDevId,
                          );
                          print('Sign up valid');
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InvalidCredentials()));
                        }
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelStyle: const TextStyle(color: Colors.white),
        errorStyle: const TextStyle(color: Colors.red),
        labelText: label,
        hintStyle: const TextStyle(color: Colors.white),
        hintText: hintText,
      ),
      validator: validator,
    );
  }
}
