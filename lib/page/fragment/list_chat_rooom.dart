import 'package:chatapp_flutter/model/person.dart';
import 'package:chatapp_flutter/model/room.dart';
import 'package:chatapp_flutter/utils/prefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListChatRoom extends StatefulWidget {
  @override
  _ListChatRoomState createState() => _ListChatRoomState();
}

class _ListChatRoomState extends State<ListChatRoom> {
  Person _myPerson;
  Stream<QuerySnapshot> _streamRoom;

  void getMyPerson() async {
    Person person = await Prefs.getPerson();
    setState(() {
      _myPerson = person;
    });
    _streamRoom = FirebaseFirestore.instance
        .collection('person')
        .doc(_myPerson.uid)
        .collection('room')
        .snapshots(includeMetadataChanges: true);
  }

  @override
  void initState() {
    getMyPerson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _streamRoom,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data != null && snapshot.data.docs.length > 0) {
          List<QueryDocumentSnapshot> listRoom = snapshot.data.docs;
          return ListView.separated(
            itemCount: listRoom.length,
            separatorBuilder: (context, index) {
              return Divider(thickness: 1, height: 1);
            },
            itemBuilder: (context, index) {
              Room room = Room.fromJson(listRoom[index].data());
              return itemRoom(room);
            },
          );
        } else {
          return Center(child: Text('Empty'));
        }
      },
    );
  }

  Widget itemRoom(Room room) {
    return Container(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: FadeInImage(
              placeholder: AssetImage('assets/logo_flikchat.png'),
              image: NetworkImage(room.photo),
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
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(room.name),
              Text(room.lastChat),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${room.lastDateTime}'),
              Text('Badge'),
            ],
          )
        ],
      ),
    );
  }
}
