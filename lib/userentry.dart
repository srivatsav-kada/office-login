/*
import 'package:flutter/material.dart';
import 'package:office_login/drawer.dart';
// import 'package:intl/intl.dart';

class UserEntry extends StatefulWidget {
  const UserEntry({super.key});

  @override
  State<UserEntry> createState() => _UserEntryState();
}

class _UserEntryState extends State<UserEntry> {
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String selectedNameTeam = 'rahul-iMobile Canada';
    final GlobalKey<FormState> formkey1 = GlobalKey<FormState>();
    List<String> nameteams = [
      'rahul-iMobile Canada',
      'rohit-iMobile Germany',
      'rishab-Flutter',
      'ravindra-SPP Canada',
      'rakesh-Hello Canada',
      'ronit-Fairpay'
    ];
    String selectLog = 'In';
    List<String> logs = ['In', 'Out'];
    return Scaffold(
      appBar: AppBar(
        title: Text('User Entry'),
      ),
      drawer: ShowDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: formkey1,
            child: Column(
              children: [
                DropdownButtonFormField(
                    items: nameteams.map((String nameTeam) {
                      return DropdownMenuItem(
                          value: nameTeam, child: Text(nameTeam));
                    }).toList(),
                    value: selectedNameTeam,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'This is required ';
                      }
                      return null;
                    },
                    onChanged: (String? value) {
                      selectedNameTeam = value!;
                    }),
                const SizedBox(
                  height: 25,
                ),
                
                TextFormField(
                  onTap: () {
                    selectTime(context);
                  },
                  controller: TextEditingController(
                    text: selectedTime.format(context),
                  ),
                  validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'This is required ';
                      }
                      return null;
                    },
                  decoration: const InputDecoration(
                    labelText: 'Selected Time',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                DropdownButtonFormField(
                    items: logs.map((String log) {
                      return DropdownMenuItem(value: log, child: Text(log));
                    }).toList(),
                    value: selectLog,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'This is required ';
                      }
                      return null;
                    },
                    onChanged: (String? value) {
                      selectLog = value!;
                    }),
                const SizedBox(
                  height: 25,
                ),
                OutlinedButton(onPressed: () {
                  if (formkey1.currentState!.validate()) {
                    debugPrint('Changes made successfully');
                  }
                }, child: const Text('Submit'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

*/

/*

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:office_login/drawer.dart';

class UserEntry extends StatefulWidget {
  const UserEntry({super.key});

  @override
  State<UserEntry> createState() => _UserEntryState();
}

class _UserEntryState extends State<UserEntry> {
  TimeOfDay selectedTime = TimeOfDay.now();
  List<String> nameteams = [];
  String? selectedNameTeam;
  String selectLog = 'In';
  List<String> logs = ['In', 'Out'];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      print(snapshot);
      final List<String> fetchedNames = snapshot.docs.map((doc) {
        print(doc['name']);
        return doc['name'] as String;
      }).toList();

      setState(() {
        nameteams = fetchedNames;
        if (nameteams.isNotEmpty) {
          selectedNameTeam = nameteams.first;
        }
      });
    } catch (e) {
      // Handle any errors
      debugPrint('Error fetching users: $e');
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formkey1 = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('User Entry'),
      ),
      drawer: ShowDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: formkey1,
            child: Column(
              children: [
                if (nameteams.isEmpty)
                  CircularProgressIndicator()
                else
                  DropdownButtonFormField(
                      items: nameteams.map((String nameTeam) {
                        return DropdownMenuItem(
                            value: nameTeam, child: Text(nameTeam));
                      }).toList(),
                      value: selectedNameTeam,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'This is required ';
                        }
                        return null;
                      },
                      onChanged: (String? value) {
                        setState(() {
                          selectedNameTeam = value!;
                        });
                      }),
                const SizedBox(
                  height: 25,
                ),
                TextFormField(
                  onTap: () {
                    selectTime(context);
                  },
                  controller: TextEditingController(
                    text: selectedTime.format(context),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'This is required ';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Selected Time',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                DropdownButtonFormField(
                    items: logs.map((String log) {
                      return DropdownMenuItem(value: log, child: Text(log));
                    }).toList(),
                    value: selectLog,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'This is required ';
                      }
                      return null;
                    },
                    onChanged: (String? value) {
                      setState(() {
                        selectLog = value!;
                      });
                    }),
                const SizedBox(
                  height: 25,
                ),
                OutlinedButton(
                    onPressed: () {
                      if (formkey1.currentState!.validate()) {
                        debugPrint('Changes made successfully');
                      }
                    },
                    child: const Text('Submit'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:office_login/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserEntry extends StatefulWidget {
  const UserEntry({Key? key}) : super(key: key);

  @override
  State<UserEntry> createState() => _UserEntryState();
}

class _UserEntryState extends State<UserEntry> {
  TimeOfDay? inOutTime;
  TimeOfDay selectedTime = TimeOfDay.now();
  List<String> nameteams = [];
  String? selectedNameTeam;
  String selectLog = 'In';
  List<String> logs = ['In', 'Out'];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final List<String> fetchedNames =
          snapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        nameteams = fetchedNames;
        if (nameteams.isNotEmpty) {
          selectedNameTeam = nameteams.first;
        }
      });
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  List<String> _getFilteredNames(String query) {
    return nameteams
        .where((name) => name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  //original
/*
  Future<void> UpdateLogEntry(selectedNameTeam, selectedTime, selectLog) async
   {
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
      inOutTime = selectedTime;
      print('-***********');
      print(selectedNameTeam);
      print(selectedTime);
      print(selectLog);
      print(inOutTime);
      for (var user in users) {
        if (user['name'] == selectedNameTeam) {
          // replace with actual employee ID
          if (selectLog == 'In') {
            //user['in'] = DateFormat("h:mm a").format(inOutTime!);
            //user['in'] = selectedTime.toString().substring(10, 16);
            user['in'] = DateFormat("h:mm a").format(inOutTime!);

            break;
          } else {
            //user['out'] = DateFormat("h:mm a").format(inOutTime!);
            user['out'] == DateFormat("h:mm a").format(DateTime.now());
            break;
          }
        }
      }

      // Update the document with the modified users array
      await logEntryDoc.update({
        'users': users,
      }).then((_) async {
        print('Check-out time logged');
      }).catchError((error) {
        print('Error logging check-out time: $error');
      });
    } else {
      print('Log entry does not exist for $currentDate');
    }
  }

*/
  Future<void> UpdateLogEntry(
      selectedNameTeam, TimeOfDay selectedTime, String selectLog) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    CollectionReference logEntryCollection =
        FirebaseFirestore.instance.collection('LogEntry');

    DocumentReference logEntryDoc = logEntryCollection.doc(currentDate);

    // Retrieve the current log entry document
    DocumentSnapshot docSnapshot = await logEntryDoc.get();

    if (docSnapshot.exists) {
      // Get the users array from the document
      List<dynamic> users = docSnapshot['users'];

      print('-///*/***/*-');
      print(selectedNameTeam);
      print(selectedTime);
      print(selectLog);

      // Convert TimeOfDay to DateTime for current date
      DateTime now = DateTime.now();
      DateTime inOutTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      for (var user in users) {
        if (user['name'] == selectedNameTeam) {
          if (selectLog == 'In') {
            user['in'] = DateFormat("h:mm a").format(inOutTime);
            await prefs.setString(
                'formattedInTime', DateFormat("h:mm a").format(inOutTime));
            //user['in'] = 'sdafsad';
          } else {
            // user['out'] = DateFormat("h:mm a").format(DateTime.now());
            user['out'] = DateFormat("h:mm a").format(inOutTime);
            await prefs.setString(
                'formattedOutTime', DateFormat("h:mm a").format(inOutTime));
          }
          break;
        }
      }

      // Update the document with the modified users array
      await logEntryDoc.update({
        'users': users,
      }).then((_) async {
        print('Check-out time logged');
      }).catchError((error) {
        print('Error logging check-out time: $error');
      });
    } else {
      print('Log entry does not exist for $currentDate');
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('User Entry'),
      ),
      drawer: ShowDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: DropdownButtonFormField<String>(
                        value: selectedNameTeam,
                        decoration: InputDecoration(
                          labelText: 'Select Name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedNameTeam = value;
                          });
                        },
                        items: nameteams.map((name) {
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () async {
                        final String? result = await showSearch<String>(
                          context: context,
                          delegate: _DropdownSearchDelegate(nameteams),
                        );
                        if (result != null) {
                          setState(() {
                            selectedNameTeam = result;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                TextFormField(
                  onTap: () {
                    selectTime(context);
                  },
                  controller: TextEditingController(
                    text: selectedTime.format(context),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'This is required';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Selected Time',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                DropdownButtonFormField(
                  items: logs.map((String log) {
                    return DropdownMenuItem(value: log, child: Text(log));
                  }).toList(),
                  value: selectLog,
                  onChanged: (String? value) {
                    setState(() {
                      selectLog = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'This is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 25,
                ),
                OutlinedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      print('-------');
                      print('Selected Name Team: $selectedNameTeam');
                      print('///');
                      print(selectedTime);
                      print(selectedTime.toString());
                      debugPrint('Selected Name Team: $selectedNameTeam');
                      debugPrint('Changes made successfully');
                      UpdateLogEntry(selectedNameTeam, selectedTime, selectLog);
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownSearchDelegate extends SearchDelegate<String> {
  final List<String> names;

  _DropdownSearchDelegate(this.names);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        //close(context, '');
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<String> filteredNames = query.isEmpty
        ? names
        : names
            .where((name) => name.toLowerCase().contains(query.toLowerCase()))
            .toList();
    return ListView.builder(
      itemCount: filteredNames.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredNames[index]),
          onTap: () {
            close(context, filteredNames[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<String> suggestions =
        query.isEmpty ? names : _getFilteredNames(query);
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context);
          },
        );
      },
    );
  }

  List<String> _getFilteredNames(String query) {
    return names
        .where((name) => name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
