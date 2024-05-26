import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:office_login/drawer.dart';
import 'users.dart'; // Assuming you have a ShowUsers page

class ShowTeams extends StatefulWidget {
  @override
  _ShowTeamsState createState() => _ShowTeamsState();
}

class _ShowTeamsState extends State<ShowTeams> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _fetchteamSnapshotList = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _locationList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTeams();
    _fetchLocations();
  }

  Future<void> _fetchTeams() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final QuerySnapshot<Map<String, dynamic>> teamSnapshot =
          await FirebaseFirestore.instance.collection('teams').get();
      setState(() {
        _fetchteamSnapshotList = teamSnapshot.docs.toList();
      });
      print("Teams fetched: ${_fetchteamSnapshotList.length}");
    } catch (e) {
      print("Error fetching teams: $e");
      _showErrorDialog('Error fetching teams');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchLocations() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> locationSnapshot =
          await FirebaseFirestore.instance.collection('location').get();
      setState(() {
        _locationList = locationSnapshot.docs.toList();
      });
    } catch (e) {
      print("Error fetching locations: $e");
      _showErrorDialog('Error fetching locations');
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

  void _showEditTeamDialog(BuildContext context,
      [QueryDocumentSnapshot<Map<String, dynamic>>? teamSnapshot]) {
    String teamName = teamSnapshot?.data()?['teamName'] ?? '';
    String location = teamSnapshot?.data()?['location'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(teamSnapshot == null ? 'Add Team' : 'Edit Team'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: teamName,
                  onChanged: (value) {
                    teamName = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Team Name',
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: location.isEmpty ? null : location,
                  onChanged: (String? newValue) {
                    setState(() {
                      location = newValue ?? '';
                    });
                  },
                  items: _locationList.map((locationSnapshot) {
                    return DropdownMenuItem<String>(
                      value: locationSnapshot.data()?['locationName'],
                      child:
                          Text(locationSnapshot.data()?['locationName'] ?? ''),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Location',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  if (teamSnapshot == null) {
                    // Add new team
                    await FirebaseFirestore.instance.collection('teams').add({
                      'teamName': teamName,
                      'location': location,
                    });
                  } else {
                    // Edit existing team
                    await FirebaseFirestore.instance
                        .collection('teams')
                        .doc(teamSnapshot.id)
                        .update({
                      'teamName': teamName,
                      'location': location,
                    });
                  }
                  await _fetchTeams();
                  Navigator.pop(context);
                } catch (error) {
                  _showErrorDialog('Error saving team');
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTeam(String teamId) async {
    try {
      await FirebaseFirestore.instance.collection('teams').doc(teamId).delete();
      await _fetchTeams();
    } catch (error) {
      _showErrorDialog('Error deleting team');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teams'),
      ),
      drawer: ShowDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(children: [
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  SizedBox(width: 10),
                  Text("Team Name"),
                  SizedBox(
                    width: 65,
                  ),
                  Text("Location"),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _fetchteamSnapshotList.length,
                  itemBuilder: (context, index) {
                    final fetchTeamName = _fetchteamSnapshotList[index];
                    return ListTile(
                      title: Row(
                        children: [
                          Expanded(child: Text(fetchTeamName['teamName'])),
                          SizedBox(width: 50),
                          Expanded(child: Text(fetchTeamName['location'])),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _showEditTeamDialog(context, fetchTeamName);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteTeam(fetchTeamName.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ]),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showEditTeamDialog(context);
        },
      ),
    );
  }
}
