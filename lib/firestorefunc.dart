import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference waitingUsers =
      FirebaseFirestore.instance.collection('waitingUsers');

  Future<void> addUser(
       String name, String teamName, String empId,String devId) {
    return waitingUsers.add({
      'name': name,
      'teamName': teamName,
      'empId': empId,
      'devId':devId,
      'role': 'user'
    });
  }
}
