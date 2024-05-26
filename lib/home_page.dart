import 'package:flutter/material.dart';
import 'package:office_login/drawer.dart';
import 'utils.dart';

class HomePageme extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePageme> {
  bool isAdmin = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initUserRole();
  }

  Future<void> initUserRole() async {
    bool role = await UserRoleUtils.checkUserRole();
    setState(() {
      isAdmin = role;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Home Page'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: isAdmin ? ShowDrawer() : null,
      body: Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}
