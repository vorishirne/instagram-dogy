import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodogy_challange/pages/chat.dart';
import 'package:dodogy_challange/widgets/custom_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dodogy_challange/homyz.dart';
import 'package:dodogy_challange/pages/post_screen.dart';
import 'package:dodogy_challange/pages/profile.dart';
import 'package:dodogy_challange/widgets/header.dart';
import 'package:dodogy_challange/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Messages extends StatefulWidget {
  @override
  MessagesState createState() => MessagesState();
}

class MessagesState extends State<Messages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: header(context, titleText: "Messages"),
        body: getMessagesList());
  }

  Widget getMessagesList() {
    print("yha yo ");
    return StreamBuilder<QuerySnapshot>(
      stream: messagesRef
          .document(currentUser.id)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          print("Kuch an hia");
          return circularProgress();
        }
        if (snapshot.data.documents.length < 1) {
          print("khali nikla");
          return buildNoContent("Waiting for some activity to happen!");
        }
        print("are yr hai to sahi");
        return ListView.separated(
          separatorBuilder: (context, _) => Divider(
            height: 0,
            indent: 20,
            endIndent: 20,
            thickness: 1,
            color: Color.fromRGBO(222, 253, 255, 1),
          ),
          shrinkWrap: true,
          padding: EdgeInsets.all(5.0),
          itemBuilder: (context, index) =>
              MessageItem.fromDocument(snapshot.data.documents[index]),
          itemCount: snapshot.data.documents.length,
        );
      },
    );
  }

  Container buildNoContent(String strongtext) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Image.asset('assets/images/search.png',
                height: max(size.height / 7, size.width / 5)),
            Text(
              strongtext,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(127, 127, 127, 1),
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w200,
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageItem extends StatelessWidget {
  final String with_;
  final String tosphoto;
  final String name; // 'like', 'follow', 'comment'
  final String message;
  final String timestamp;
  final bool mymessage;

  MessageItem(
      {this.with_,
      this.tosphoto,
      this.name,
      this.message,
      this.mymessage,
      this.timestamp});

  factory MessageItem.fromDocument(DocumentSnapshot doc) {
    print("message");
    print(doc['message']);
    print(doc['mymessage']);

    print(doc['timestamp']);
    return MessageItem(
        with_: doc['with'],
        tosphoto: doc['tosphoto'],
        name: doc['name'],
        message: doc['message'],
        mymessage: doc['mymessage'],
        timestamp: doc['timestamp']);
  }

  showChat(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(
          friendId: with_,
          currentUserId: currentUser.id, //userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("printed message");

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white10,
        child: GestureDetector(
          onTap: ()=>showChat(context),
          child: ListTile(
            title: Text(
              name,
              style: TextStyle(fontWeight: FontWeight.w400,letterSpacing: 1.5),
            ),
            subtitle: Text.rich(
              TextSpan(children: [
                !mymessage ? TextSpan(text: "") : TextSpan(text: "You: "),
                TextSpan(
                    text: message, style: TextStyle(color: Colors.black54))
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: GestureDetector(
                onTap: () => showProfile(context, profileId: with_),
                child: SizedBox(
                  height: 45,
                  width: 45,
                  child: CachedNetworkImage(
                      imageUrl:
                          tosphoto ?? "https://www.asjfkfhdgihdknjskdjfeid.com",
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: imageProvider,
                          ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        backgroundColor: Color.fromRGBO(222, 253, 255, 1),
                        child: CircleAvatar(
                          radius: 21.25,
                          child: Icon(
                                CupertinoIcons.person_solid,
                                color: Color.fromRGBO(24, 115, 172, 1),
                              ),
                        ),

                      )),
                )),
            trailing: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  timeago.format(DateTime.fromMillisecondsSinceEpoch(
                      int.parse(timestamp))),
                  style: TextStyle(fontSize: 12, letterSpacing: 0),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId}) {
  print("callinga  new profile");
  print(profileId);
  Navigator.of(context).popUntil((route) => route.isFirst);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}
