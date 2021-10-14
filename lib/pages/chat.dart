import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:dodogy_challange/models/user.dart';
import 'package:dodogy_challange/widgets/progress.dart';
import 'package:dodogy_challange/homyz.dart';
import 'package:dodogy_challange/widgets/header.dart';

class Chat extends StatefulWidget {
  final String currentUserId;
  final String friendId;

  Chat({this.currentUserId, this.friendId});

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  User friend;


  @override
  void initState() {
    super.initState();
    getFriend();
  }

  getFriend() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.friendId).get();
    friend = User.fromDocument(doc);
    // displayNameController.text = friend.displayName;
    // bioController.text = friend.bio;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: SizedBox(
          height: 30,
          width: 30,
          child: CachedNetworkImage(
              imageUrl:
                  friend.photoUrl ?? "https://www.asjfkfhdgihdknjskdjfeid.com",
              imageBuilder: (context, imageProvider) => CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: imageProvider,
                    radius: 50,
                  ),
              errorWidget: (context, url, error) => new Icon(
                    CupertinoIcons.person_solid,
                    color: Color.fromRGBO(24, 115, 172, 1),
                  )),
        ),
        elevation: 10,
        leadingWidth: 30,
        toolbarHeight: 30,
        title: Text((friend.displayName == null || friend.displayName == "")
            ? friend.username
            : friend.displayName),
      ),
      // header(context,titleText: (friend.displayName==null || friend.displayName=="")?friend.username : friend.displayName ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    top: 16.0,
                    bottom: 8.0,
                  ),
                  child: CachedNetworkImage(
                      imageUrl: user.photoUrl ??
                          "https://www.asjfkfhdgihdknjskdjfeid.com",
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: imageProvider,
                            radius: 50,
                          ),
                      errorWidget: (context, url, error) => new Icon(
                            CupertinoIcons.person_solid,
                            color: Color.fromRGBO(24, 115, 172, 1),
                          )),
                )
              ],
            ),
    );
  }
}
