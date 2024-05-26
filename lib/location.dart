/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShowLocation extends StatefulWidget {
  _ShowLocationState createState() => _ShowLocationState();
}

class _ShowLocationState extends State<ShowLocation> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _locationSnapshotList = [];

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    print("Fetching teams...");
    try {
      final QuerySnapshot<Map<String, dynamic>> locationSnapshot =
          await FirebaseFirestore.instance.collection('location').get();
      setState(() {
        _locationSnapshotList = locationSnapshot.docs.toList();
      });
      print("Teams fetched: ${_locationSnapshotList.length}");
    } catch (e) {
      print("Error fetching teams: $e");
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teams'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _locationSnapshotList.length,
              itemBuilder: (context, index) {
                final fetchTeamName = _locationSnapshotList[index];
                return ListTile(
                    title: Row(
                  children: [
                    Text(fetchTeamName['locationName']),
                    SizedBox(
                      width: 50,
                    ),
                    Text(fetchTeamName['latitude']),
                    SizedBox(
                      width: 50,
                    ),
                    Text(fetchTeamName['longitude']),
                  ],
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}

*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:office_login/drawer.dart';

class ShowLocation extends StatefulWidget {
  @override
  _ShowLocationState createState() => _ShowLocationState();
}

class _ShowLocationState extends State<ShowLocation> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _locationSnapshotList = [];

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    print("Fetching locations...");
    try {
      final QuerySnapshot<Map<String, dynamic>> locationSnapshot =
          await FirebaseFirestore.instance.collection('location').get();
      setState(() {
        _locationSnapshotList = locationSnapshot.docs.toList();
      });
      print("Locations fetched: ${_locationSnapshotList.length}");
    } catch (e) {
      print("Error fetching locations: $e");
      // Handle error
    }
  }

  Future<void> _editLocation(
      [QueryDocumentSnapshot<Map<String, dynamic>>? doc]) async {
    final TextEditingController locationNameController =
        TextEditingController(text: doc != null ? doc['locationName'] : '');
    final TextEditingController latitudeController = TextEditingController(
        text: doc != null ? doc['latitude'].toString() : '');
    final TextEditingController longitudeController = TextEditingController(
        text: doc != null ? doc['longitude'].toString() : '');

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(doc != null ? 'Edit Location' : 'Add Location'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: locationNameController,
                  decoration: InputDecoration(labelText: 'Location Name'),
                ),
                TextField(
                  controller: latitudeController,
                  decoration: InputDecoration(labelText: 'Latitude'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: longitudeController,
                  decoration: InputDecoration(labelText: 'Longitude'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                try {
                  final String locationName = locationNameController.text;
                  final double latitude = double.parse(latitudeController.text);
                  final double longitude =
                      double.parse(longitudeController.text);

                  if (doc != null) {
                    await FirebaseFirestore.instance
                        .collection('location')
                        .doc(doc.id)
                        .update({
                      'locationName': locationName,
                      'latitude': latitude,
                      'longitude': longitude,
                    });
                  } else {
                    await FirebaseFirestore.instance
                        .collection('location')
                        .add({
                      'locationName': locationName,
                      'latitude': latitude,
                      'longitude': longitude,
                    });
                  }

                  _fetchLocation(); // Refresh the list
                  Navigator.of(context).pop();
                } catch (e) {
                  print("Error updating location: $e");
                  // Handle error
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteLocation(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('location')
          .doc(docId)
          .delete();
      _fetchLocation(); // Refresh the list
    } catch (e) {
      print("Error deleting location: $e");
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locations'),
      ),
      drawer: ShowDrawer(),
      body: Column(
        children: [
          SizedBox(
            height: 35,
          ),
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text("Name"),
              SizedBox(
                width: 30,
              ),
              Text("Latitude"),
              SizedBox(
                width: 45,
              ),
              Text("Longitude"),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _locationSnapshotList.length,
              itemBuilder: (context, index) {
                final fetchLocation = _locationSnapshotList[index];
                return ListTile(
                  title: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(fetchLocation['locationName']),
                        SizedBox(width: 10),
                        Text(fetchLocation['latitude'].toString()),
                        SizedBox(width: 10),
                        Text(fetchLocation['longitude'].toString()),
                        SizedBox(width: 30),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editLocation(fetchLocation),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteLocation(fetchLocation.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _editLocation();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
