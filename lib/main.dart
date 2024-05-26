import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:office_login/auth_check.dart';
import 'package:office_login/firebase_options.dart';
import 'package:office_login/splash.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
       darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.dark,
      /*theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(206, 148, 190, 194),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.red),
          bodyMedium: TextStyle(color: Colors.red),
          bodySmall: TextStyle(color: Colors.red),
        ),
      ),*/
      home: SplashScreen(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: ShowDrawer(),
      body: AuthCheck(),
    );
  }
}
