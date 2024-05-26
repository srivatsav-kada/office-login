import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:office_login/drawer.dart';

class ShowWaitingUsers extends StatefulWidget {
  @override
  _ShowWaitingUsersState createState() => _ShowWaitingUsersState();
}

class _ShowWaitingUsersState extends State<ShowWaitingUsers> {
  final List<String> itemsList = ['user', 'admin'];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> waitingUsersSnapshotList = [];

  @override
  void initState() {
    super.initState();
    _getWaitingUsers();
  }

  Future<void> _getWaitingUsers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> waitingUsersSnapshot =
          await FirebaseFirestore.instance.collection('waitingUsers').get();

      setState(() {
        waitingUsersSnapshotList = waitingUsersSnapshot.docs.toList();
      });
    } catch (error) {
      print('Error fetching data: $error');
      // Handle error as needed (e.g., show error message to the user)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waiting Users'),
      ),
      drawer: ShowDrawer(),
      body: waitingUsersSnapshotList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: waitingUsersSnapshotList.length,
              itemBuilder: (context, index) {
                final userData = waitingUsersSnapshotList[index].data();
                String dropdownValue = userData?['role'] ?? itemsList.first;
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(userData?['name'] ?? 'Name not available'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return AlertDialog(
                              title: Text('Edit User'),
                              content: Container(
                                height: 200,
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Name: ',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        Text(
                                          userData?['name'] ?? 'Name not available',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'EmpId: ',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        Text(
                                          userData?['empId'] ?? 'EmpId not available',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'TeamName: ',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        Text(
                                          userData?['teamName'] ?? 'TeamName not available',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    DropdownButton<String>(
                                      value: itemsList.contains(dropdownValue)
                                          ? dropdownValue
                                          : itemsList.first,
                                      items: itemsList.map((String item) {
                                        return DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(item),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropdownValue = newValue!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Reject'),
                                  onPressed: () async {
                                    try {
                                      // Deleting from the waiting users
                                      QuerySnapshot deletingWaitingUsers =
                                          await FirebaseFirestore.instance
                                              .collection('waitingUsers')
                                              .where('empId', isEqualTo: userData['empId'])
                                              .get();

                                      for (var element in deletingWaitingUsers.docs) {
                                        await element.reference.delete();
                                      }
                                      _getWaitingUsers();
                                    } catch (e) {
                                      print(e);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Accept User'),
                                  onPressed: () async {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .add({
                                        'empId': userData?['empId'],
                                        'name': userData?['name'],
                                        'role': dropdownValue,
                                        'teamName': userData?['teamName'],
                                        'devId':userData?['devId'],
                                      });

                                      // Deleting from the waiting users
                                      QuerySnapshot deletingWaitingUsers =
                                          await FirebaseFirestore.instance
                                              .collection('waitingUsers')
                                              .where('empId', isEqualTo: userData['empId'])
                                              .get();

                                      for (var element in deletingWaitingUsers.docs) {
                                        await element.reference.delete();
                                      }
                                      _getWaitingUsers();
                                    } catch (error) {
                                      print(error);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
