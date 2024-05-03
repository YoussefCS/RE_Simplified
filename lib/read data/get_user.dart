import 'package:cloud_firestore/cloud_firestore.dart';

class GetUser {
  static Future<Map<String, dynamic>> getUserDetails(String documentId) async {
    //get the collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    final snapshot = await users.doc(documentId).get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return {
        'email': data['email'],
        'name': data['name'],
        'phone': data['phone'],
        'title': data['title'],
      };
    } else {
      throw Exception("User document not found");
    }
  }
}
