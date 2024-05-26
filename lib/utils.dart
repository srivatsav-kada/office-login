import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRoleUtils {
  static Future<bool> checkUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    print(username);
    print('8888');
    if (username != null) {
      QuerySnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .where('name', isEqualTo: username)
          .where('role', isEqualTo: 'admin')
          .get();

      if (userDoc.docs.isNotEmpty) {
        return true;
      }
    }

    return false;
  }
}
