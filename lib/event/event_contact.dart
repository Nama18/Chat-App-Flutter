import 'package:chatapp_flutter/model/person.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventContact {
  static void addContact({String myUid, Person person}) {
    try {
      FirebaseFirestore.instance
          .collection('person')
          .doc(myUid)
          .collection('contact')
          .doc(person.uid)
          .set(person.toJson())
          .then((value) => null)
          .catchError((onError) => print(onError));
    } catch (e) {
      print(e);
    }
  }
}
