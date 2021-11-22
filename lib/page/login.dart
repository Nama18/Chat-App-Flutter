import 'package:chatapp_flutter/event/event_person.dart';
import 'package:chatapp_flutter/page/dashboard.dart';
import 'package:chatapp_flutter/page/forgot_password.dart';
import 'package:chatapp_flutter/page/register.dart';
import 'package:chatapp_flutter/utils/notif_controller.dart';
import 'package:chatapp_flutter/utils/prefs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var _formKey = GlobalKey<FormState>();
  var _controllereEmail = TextEditingController();
  var _controllerePassword = TextEditingController();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  void loginWithEmailAndPassword() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _controllereEmail.text,
        password: _controllerePassword.text,
      );

      if (userCredential.user.uid != null) {
        if (userCredential.user.emailVerified) {
          print('succes');
          showNotifSnackBar('Login...');
          String token = await NotifController.getTokenFromDevice();
          EventPerson.updatePersonToken(userCredential.user.uid, token);
          EventPerson.getPerson(userCredential.user.uid).then((person) {
            Prefs.setPerson(person);
          });
          Future.delayed(Duration(milliseconds: 1700), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          });
          _controllereEmail.clear();
          _controllerePassword.clear();
        } else {
          print('not verified');
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text('Email not verified'),
              action: SnackBarAction(
                label: 'Send Verif',
                onPressed: () async {
                  await userCredential.user.sendEmailVerification();
                },
              ),
            ),
          );
        }
      } else {
        showNotifSnackBar('Failed');
        print('failed');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showNotifSnackBar('No user found for that email');
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showNotifSnackBar('Wrong password provided for that user');
        print('Wrong password provided for that user.');
      }
    }
  }

  void showNotifSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
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
                  Text('Not have account?'),
                  SizedBox(width: 8),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Register()));
                      },
                      child: Text(
                        'Register',
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
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ForgotPassword()));
                            },
                            child: Text('Forgot Password?')),
                        SizedBox(height: 16),
                        Center(
                          child: RaisedButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                //loginAuth
                                loginWithEmailAndPassword();
                              }
                            },
                            child: Text('Login'),
                            color: Colors.blue,
                            textColor: Colors.white,
                          ),
                        ),
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
