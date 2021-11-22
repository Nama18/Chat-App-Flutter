import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatelessWidget {
  var _controllerEmail = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  void resetPassword() {
    FirebaseAuth.instance.sendPasswordResetEmail(email: _controllerEmail.text);
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text('Link Reset Password has send to email')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                validator: (value) => value == '' ? "Dont Empty" : null,
                controller: _controllerEmail,
                decoration: InputDecoration(
                    hintText: 'Email', prefixIcon: Icon(Icons.mail)),
                textAlignVertical: TextAlignVertical.center,
              ),
              SizedBox(height: 16),
              Center(
                child: RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      ///reset password
                      resetPassword();
                    }
                  },
                  child: Text('Reset Password'),
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
