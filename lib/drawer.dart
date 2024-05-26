import 'package:flutter/material.dart';
import 'package:office_login/location.dart';
import 'package:office_login/reports.dart';
import 'package:office_login/splash.dart';
import 'package:office_login/teams.dart';
import 'package:office_login/user_home.dart';
import 'package:office_login/userentry.dart';
import 'package:office_login/users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'waitingusers.dart';

class ShowDrawer extends StatefulWidget {
  _showdrawerstate createState() => _showdrawerstate();
}

class _showdrawerstate extends State<ShowDrawer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 100),
      child: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text("Reports"),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ReportPage()));
              },
            ),
            ListTile(
              title: Text("Waiting Users"),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowWaitingUsers()));
              },
            ),
            ListTile(
              title: Text("Users"),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ShowUsers()));
              },
            ),
            ListTile(
              title: Text("Teams"),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ShowTeams()));
              },
            ),
            ListTile(
              title: Text("Location"),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ShowLocation()));
              },
            ),
            ListTile(
              title: Text("Log Entry"),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => UserEntry()));
              },
            ),
            ListTile(
              title: Text("User Home"),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
            ),
            ListTile(
              title: Text("LogOUt"),
              onTap: () async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                await preferences.clear();

                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SplashScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
