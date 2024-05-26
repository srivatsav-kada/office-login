import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:office_login/drawer.dart';

class ShowUsers extends StatefulWidget {
  @override
  _ShowUsersState createState() => _ShowUsersState();
}

class _ShowUsersState extends State<ShowUsers> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _teamSnapshotList = [];
  QueryDocumentSnapshot<Map<String, dynamic>>? _selectedTeam;
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _usersByTeamList;
  bool _isLoadingTeams = false;
  bool _isLoadingUsers = false;
  final itemsList = ['user', 'admin'];

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  Future<void> _fetchTeams() async {
    setState(() {
      _isLoadingTeams = true;
    });
    try {
      final QuerySnapshot<Map<String, dynamic>> teamSnapshot =
          await FirebaseFirestore.instance.collection('teams').get();
      setState(() {
        _teamSnapshotList = teamSnapshot.docs.toList();
      });
    } catch (e) {
      _showErrorDialog('Error fetching teams');
    } finally {
      setState(() {
        _isLoadingTeams = false;
      });
    }
  }

  Future<void> _fetchUsersByTeam() async {
    if (_selectedTeam == null) return;
    setState(() {
      _isLoadingUsers = true;
    });
    try {
      final QuerySnapshot<Map<String, dynamic>> usersByTeamSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('teamName', isEqualTo: _selectedTeam?.data()?['teamName'])
              .get();
      setState(() {
        _usersByTeamList = usersByTeamSnapshot.docs.toList();
      });
    } catch (e) {
      _showErrorDialog('Error fetching users by team');
    } finally {
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      _fetchUsersByTeam(); // Refresh the user list after deletion
    } catch (e) {
      _showErrorDialog('Error deleting user');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Show Users'),
      ),
      drawer: ShowDrawer(),
      body: _isLoadingTeams
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<
                        QueryDocumentSnapshot<Map<String, dynamic>>>(
                      value: _selectedTeam,
                      onChanged: (QueryDocumentSnapshot<Map<String, dynamic>>?
                          newValue) {
                        setState(() {
                          _selectedTeam = newValue;
                          _usersByTeamList = null; // Reset users list
                        });
                        _fetchUsersByTeam();
                      },
                      items: _teamSnapshotList.map((teamSnapshot) {
                        return DropdownMenuItem<
                            QueryDocumentSnapshot<Map<String, dynamic>>>(
                          value: teamSnapshot,
                          child: Text(teamSnapshot.data()?['teamName'] ?? ''),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Select Team',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _isLoadingUsers
                      ? Center(child: CircularProgressIndicator())
                      : _usersByTeamList != null
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: _usersByTeamList!.length,
                              itemBuilder: (context, index) {
                                final userTeamDet = _usersByTeamList![index];
                                String name = userTeamDet['name'] ?? '';
                                String empId = userTeamDet['empId'] ?? '';
                                String role = userTeamDet['role'] ?? '';
                                String teamName = userTeamDet['teamName'] ?? '';
                                return Column(children: [
                                  if (index == 0) // Only add the header once
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text('Name'),
                                        SizedBox(
                                          width: 50,
                                        ),
                                        Text('EmpId'),
                                        SizedBox(
                                          width: 50,
                                        ),
                                        Text('Role'),
                                      ],
                                    ),
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Expanded(child: Text('$name')),
                                        Expanded(child: Text('$empId')),
                                        Expanded(child: Text('$role')),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            _showEditUserDialog(
                                                context, userTeamDet, index);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            _deleteUser(userTeamDet.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                ]);
                              },
                            )
                          : Center(child: Text('')),
                ],
              ),
            ),
    );
  }

  void _showEditUserDialog(BuildContext context,
      QueryDocumentSnapshot<Map<String, dynamic>> userTeamDet, int index) {
    String name = userTeamDet['name'] ?? '';
    String empId = userTeamDet['empId'] ?? '';
    String role = userTeamDet['role'] ?? '';
    String teamName = userTeamDet['teamName'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  onChanged: (value) {
                    name = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextFormField(
                  initialValue: empId,
                  onChanged: (value) {
                    empId = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Employee ID',
                  ),
                ),
                TextFormField(
                  initialValue: role,
                  onChanged: (value) {
                    role = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Role',
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: teamName,
                  onChanged: (String? newValue) {
                    teamName = newValue!;
                  },
                  items: _teamSnapshotList.map((teamSnapshot) {
                    return DropdownMenuItem<String>(
                      value: teamSnapshot.data()?['teamName'],
                      child: Text(teamSnapshot.data()?['teamName'] ?? ''),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Team Name',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_usersByTeamList![index].id)
                      .update({
                    'name': name,
                    'empId': empId,
                    'role': role,
                    'teamName': teamName,
                  });

                  await _fetchUsersByTeam();
                  Navigator.pop(context);
                } catch (error) {
                  _showErrorDialog('Error updating user details');
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
