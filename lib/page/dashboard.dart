import 'dart:io';

import 'package:chatapp_flutter/event/event_person.dart';
import 'package:chatapp_flutter/event/event_storage.dart';
import 'package:chatapp_flutter/model/person.dart';
import 'package:chatapp_flutter/page/forgot_password.dart';
import 'package:chatapp_flutter/page/fragment/list_chat_rooom.dart';
import 'package:chatapp_flutter/page/login.dart';
import 'package:chatapp_flutter/utils/prefs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'fragment/list_contact.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Person _myPerson;

  List<Widget> _listFragment = [
    ListChatRoom(),
    ListContact(),
  ];
  void getMyPerson() async {
    Person person = await Prefs.getPerson();
    setState(() {
      _myPerson = person;
    });
  }

  void pickAndCropPhoto() async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );
    if (pickedFile != null) {
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      if (croppedFile != null) {
        EventStorage.editPhoto(
          filePhoto: File(croppedFile.path),
          oldUrl: _myPerson.photo,
          uid: _myPerson.uid,
        );
        EventPerson.getPerson(_myPerson.uid).then((person) {
          Prefs.setPerson(person);
        });
      }
    }
    getMyPerson();
  }

  void logout() async {
    var value = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('You sure for logout?'),
        actions: [
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () => Navigator.pop(context, 'logout'),
            child: Text('Yes'),
          ),
        ],
      ),
    );
    if (value == 'logout') {
      Prefs.clear();
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  @override
  void initState() {
    getMyPerson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex : 0,
      length : 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Text('ChatApp Flutter'),
          bottom: TabBar(
            tabs: [
              Tab(
                text: 'Chat Room'
              ),
              Tab(
                text: 'Contact'
              ),
            ],
          ),
        ),
        drawer: menuDrawer(),
        body: TabBarView(children:  _listFragment),
      ),
    );
  }

  Widget menuDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: FadeInImage(
                    placeholder: AssetImage('assets/logo_flikchat.png'),
                    image:
                        NetworkImage(_myPerson == null ? '' : _myPerson.photo),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/logo_flikchat.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _myPerson == null ? '' : _myPerson.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _myPerson == null ? '' : _myPerson.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            onTap: () {},
            leading: Icon(Icons.person),
            title: Text('Edit Profile'),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ForgotPassword()));
            },
            leading: Icon(Icons.lock),
            title: Text('Reset Password'),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            onTap: () {
              pickAndCropPhoto();
            },
            leading: Icon(Icons.image),
            title: Text('Edit Photo'),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            onTap: () async {
              logout();
            },
            leading: Icon(Icons.logout),
            title: Text('Log out'),
            trailing: Icon(Icons.navigate_next),
          ),
        ],
      ),
    );
  }
}
