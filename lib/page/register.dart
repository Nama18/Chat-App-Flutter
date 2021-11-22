import 'package:chatapp_flutter/event/event_person.dart';
import 'package:chatapp_flutter/model/person.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  var _formKey = GlobalKey<FormState>();
  var _controllereEmail = TextEditingController();
  var _controllerePassword = TextEditingController();
  var _controllerName = TextEditingController();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  void registerAccount() async {
    if (await EventPerson.checkEmail(_controllereEmail.text) == '') {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _controllereEmail.text,
          password: _controllerePassword.text,
        );
        if (userCredential.user.uid != null) {
          showNotifSnackBar('Register Success');
          Person person = Person(
            email: _controllereEmail.text,
            name: _controllerName.text,
            photo: '',
            token: '',
            uid: userCredential.user.uid,
          );
          EventPerson.addPerson(person);
          await userCredential.user.sendEmailVerification();
          _controllerName.clear();
          _controllereEmail.clear();
          _controllerePassword.clear();
        } else {
          showNotifSnackBar('Register Failed');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          showNotifSnackBar('The password provided is too weak');
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          showNotifSnackBar('The account already exists for that email');
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void showNotifSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned(
              bottom: 16,
              right: 0,
              left: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have account?'),
                  SizedBox(width: 8),
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 30),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/logo_flikchat.png',
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          validator: (value) =>
                              value == '' ? "Dont Empty" : null,
                          controller: _controllerName,
                          decoration: InputDecoration(
                              hintText: 'Name', prefixIcon: Icon(Icons.person)),
                          textAlignVertical: TextAlignVertical.center,
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          validator: (value) =>
                              value == '' ? "Dont Empty" : null,
                          controller: _controllereEmail,
                          decoration: InputDecoration(
                              hintText: 'Email', prefixIcon: Icon(Icons.email)),
                          textAlignVertical: TextAlignVertical.center,
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          validator: (value) =>
                              value == '' ? "Dont Empty" : null,
                          controller: _controllerePassword,
                          decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: Icon(Icons.lock)),
                          textAlignVertical: TextAlignVertical.center,
                          obscureText: true,
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: RaisedButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                //RegisterAuth
                                registerAccount();
                              }
                            },
                            child: Text('Register'),
                            color: Colors.blue,
                            textColor: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
