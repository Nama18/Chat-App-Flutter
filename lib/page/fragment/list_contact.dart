
import 'package:chatapp_flutter/event/event_contact.dart';
import 'package:chatapp_flutter/event/event_person.dart';
import 'package:chatapp_flutter/model/person.dart';
import 'package:chatapp_flutter/model/room.dart';
import 'package:chatapp_flutter/page/chat_room.dart';
import 'package:chatapp_flutter/utils/prefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListContact extends StatefulWidget {
  @override
  _ListContactState createState() => _ListContactState();
}

class _ListContactState extends State<ListContact> {
  var _controllerEmail = TextEditingController();
  Person _myPerson;
  Stream<QuerySnapshot> _streamContact;
  void getMyPerson() async {
    Person person = await Prefs.getPerson();
    setState(() {
      _myPerson = person;
    });
    _streamContact = FirebaseFirestore.instance
        .collection('person')
        .doc(_myPerson.uid)
        .collection('contact')
        .snapshots(includeMetadataChanges: true);
  }

  void addNewContact() async {
    var value = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SimpleDialog(
          titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          contentPadding: EdgeInsets.all(16),
          title: Text('Add Contact'),
          children: [
            TextField(
              controller: _controllerEmail,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'email@gmail.com',
              ),
              textAlignVertical: TextAlignVertical.bottom,
            ),
            SizedBox(height: 16),
            RaisedButton(
              child: Text('Add'),
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () => Navigator.pop(context, 'add'),
            ),
            OutlineButton(
              child: Text('Close'),
              textColor: Colors.blue,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
    if (value == 'add') {
      String personUid = await EventPerson.checkEmail(_controllerEmail.text);
      if (personUid != '') {
        EventPerson.getPerson(personUid).then((person) {
          EventContact.addContact(myUid: _myPerson.uid, person: person);
        });
      }else {
        
      }
    }
    _controllerEmail.clear();
  }

  @override
  void initState() {
    getMyPerson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: _streamContact,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.data != null && snapshot.data.docs.length > 0) {
              List<QueryDocumentSnapshot> listContact = snapshot.data.docs;
              return ListView.separated(
                itemCount: listContact.length,
                separatorBuilder: (context, index) {
                  return Divider(thickness: 1, height: 1);
                },
                itemBuilder: (context, index) {
                  Person person = Person.fromJson(listContact[index].data());
                  return itemContact(person);
                },
              );
            } else {
              return Center(child: Text('Empty'));
            }
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              addNewContact();
            },
          ),
        ),
      ],
    );
  }

  Widget itemContact(Person person) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ProfilePerson(
          //       person: person,
          //       myUid: _myPerson.uid,
          //     ),
          //   ),
          // );
        },
        child: SizedBox(
          width: 40,
          height: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: FadeInImage(
              placeholder: AssetImage('assets/logo_flikchat.png'),
              image: NetworkImage(person.photo),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/logo_flikchat.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
      ),
      title: Text(person.name),
      subtitle: Text(person.email),
      trailing: IconButton(
        icon: Icon(Icons.message),
        onPressed: () {
          Room room = Room(
            email: person.email,
            inRoom: false,
            lastChat: '',
            lastDateTime: 0,
            lastUid: '',
            name: person.name,
            photo: person.photo,
            type: '',
            uid: person.uid,
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatRoom(room: room)),
            
          );
        },
      ),
    );
  }
}
