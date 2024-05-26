import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvalidCredentials extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        actions: [
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Clear Data"),
                    content: Text(
                      "This will remove all data and you will need to create a new account.\nAre you sure?\nRestart the App",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          SharedPreferences preferences =
                              await SharedPreferences.getInstance();
                          await preferences.clear();
                          Navigator.of(context).pop();
                        },
                        child: Text("Remove"),
                      ),
                    ],
                  );
                },
              );

              print('Successfully cleared data');
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Text('Contact Admin '),
      ),
    );
  }
}
