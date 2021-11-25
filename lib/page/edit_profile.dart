import 'package:chatapp_flutter/event/event_person.dart';
import 'package:chatapp_flutter/model/person.dart';
import 'package:chatapp_flutter/utils/prefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  final Person person;

  const EditProfile({Key key, this.person}) : super(key: key);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  var _controllerOldEmail = TextEditingController();
  var _controllerPassword = TextEditingController();
  var _controllerName = TextEditingController();
  var _controllerNewEmail = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> changeEmail() async {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: _controllerOldEmail.text,
            password: _controllerPassword.text);
    if (userCredential != null) {
      await userCredential.user.updateEmail(_controllerNewEmail.text);
      await userCredential.user.sendEmailVerification();
      return true;
    } else {
      return false;
    }
  }

  void updateToFirestore() {
    Map<String, dynamic> newData = {
      'email': _controllerNewEmail.text,
      'name': _controllerName.text,
    };

    // update in person
    FirebaseFirestore.instance
        .collection('person')
        .doc(widget.person.uid)
        .update(newData)
        .then((value) => null)
        .catchError((onError) => print(onError));
    // update in contact
    FirebaseFirestore.instance.collection('person').get().then((value) {
      for (var docPerson in value.docs) {
        docPerson.reference
            .collection('contact')
            .where('uid', isEqualTo: widget.person.uid)
            .get()
            .then((snapshotContact) {
          for (var docContact in snapshotContact.docs) {
            docContact.reference.update(newData);
          }
        });
      }
    }).catchError((onError) => print(onError));
    // update in room
    FirebaseFirestore.instance.collection('person').get().then((value) {
      for (var docPerson in value.docs) {
        docPerson.reference
            .collection('room')
            .where('uid', isEqualTo: widget.person.uid)
            .get()
            .then((snapshotContact) {
          for (var docRoom in snapshotContact.docs) {
            docRoom.reference.update(newData);
          }
        });
      }
    }).catchError((onError) => print(onError));
  }

  void updateProfile() {
    if (_controllerOldEmail.text != _controllerNewEmail.text) {
      changeEmail().then((success) {
        if (success) {
          updateToFirestore();
          showNotif('Success Change Email & Update Profile');
        } else {
          showNotif('Failed Change Email & Update Profile');
        }
      });
    } else {
      updateToFirestore();
      showNotif('Succes Update Name');
    }
    EventPerson.getPerson(widget.person.uid).then((person) {
      Prefs.setPerson(person);
    });
  }

  void showNotif(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    _controllerOldEmail.text = widget.person.email;
    _controllerName.text = widget.person.name;
    _controllerNewEmail.text = widget.person.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _controllerOldEmail,
                validator: (value) => value == '' ? "Don't Empty" : null,
                decoration: InputDecoration(
                  hintText: 'Old Email',
                  labelText: 'Old Email',
                  prefixIcon: Icon(Icons.email),
                ),
                textAlignVertical: TextAlignVertical.center,
              ),
              TextFormField(
                controller: _controllerPassword,
                validator: (value) => value == '' ? "Don't Empty" : null,
                decoration: InputDecoration(
                  hintText: 'Password',
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                textAlignVertical: TextAlignVertical.center,
              ),
              TextFormField(
                controller: _controllerName,
                validator: (value) => value == '' ? "Don't Empty" : null,
                decoration: InputDecoration(
                  hintText: 'Name',
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                textAlignVertical: TextAlignVertical.center,
              ),
              TextFormField(
                controller: _controllerNewEmail,
                validator: (value) => value == '' ? "Don't Empty" : null,
                decoration: InputDecoration(
                  hintText: 'New Email',
                  labelText: 'New Email',
                  prefixIcon: Icon(Icons.email),
                ),
                textAlignVertical: TextAlignVertical.center,
              ),
              SizedBox(height: 16),
              Center(
                child: RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      updateProfile();
                    }
                  },
                  child: Text('Update Profile'),
                  color: Colors.blue,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
