import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodogy_challange/pages/activity_feed.dart';
import 'package:dodogy_challange/pages/profile.dart';
import 'package:dodogy_challange/pages/messages.dart';
import 'package:dodogy_challange/pages/search.dart';
import 'package:dodogy_challange/pages/timeline.dart';
import 'package:dodogy_challange/pages/upload.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'models/user.dart';

const String company = "2kJgasDVBkVJZkzmruIW9UfQRUw1";
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseAuth vauth = _auth;
//FirebaseUser curUser;
CollectionReference usersRef;
CollectionReference postsRef;
CollectionReference commentsRef;
CollectionReference activityFeedRef;
CollectionReference followersRef;
CollectionReference followingRef;
CollectionReference timelineRef;
StorageReference storageRef;
CollectionReference messagesRef;
CollectionReference chatsRef;

FirebaseUser user;
User curruser;
User currentUser;
int pageIndex = 0;
PageController pageController;

class homy extends StatefulWidget {
  final FirebaseUser userx;
  final User curruserx;

  homy(FirebaseUser this.userx, User this.curruserx);

  @override
  homystate createState() => homystate();
}

class homystate extends State<homy> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    pageIndex = 0;
    user = widget.userx;
    curruser = widget.curruserx;
    currentUser = widget.curruserx;
    pageController = PageController();
    //curUser = widget.user;
    usersRef = Firestore.instance.collection('users');
    postsRef = Firestore.instance.collection('posts');
    commentsRef = Firestore.instance.collection('comments');
    activityFeedRef = Firestore.instance.collection('feed');
    followersRef = Firestore.instance.collection('followers');
    followingRef = Firestore.instance.collection('following');
    timelineRef = Firestore.instance.collection('timeline');
    chatsRef = Firestore.instance.collection('chats');
    messagesRef = Firestore.instance.collection('messages');
    storageRef = FirebaseStorage.instance.ref();
    registerNotification();
    configLocalNotification();
  }

  @override
  dispose() {
    pageController.dispose();
    super.dispose();
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('onMessage: $message');
        Platform.isAndroid
            ? showNotification(message['notification'])
            : showNotification(message['aps']['alert']);
        return;
      },
      onResume: (Map<String, dynamic> message) {
        print('onResume: $message');
        return;
      },
      onLaunch: (Map<String, dynamic> message) {
        print('onLaunch: $message');
        return;
      },
    );

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      print("uid is ${user.uid}");
      Firestore.instance
          .collection('users')
          .document(user.uid)
          .updateData({'pushToken': token});
    }).catchError((err) {
      print(err);
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'com.dodogy.www' : 'ios.dodogy.www',
      'Dodogy ka pyar',
      'apko mubarak mere yar',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);
    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  Future<bool> _goToLogin(BuildContext context) async {
    await _auth.signOut();
    print("Signed out");
    return Navigator.of(context)
        .pushReplacementNamed('/')
        // we dont want to pop the screen, just replace it completely
        .then((_) => false);
  }

  onPageChanged(int pageIndex_) {
    setState(() {
      pageIndex = pageIndex_;
    });
  }

  onTap(int pageIndex) {
    pageController.jumpToPage(
      pageIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(
            currentUser: curruser,
          ),
//          RaisedButton(
//            child: Text('Logout'),
//            onPressed: () async {
//            await  _goToLogin(context);
//            },
//          ),
          Search(usersRef),
          Upload(user, curruser, usersRef, postsRef),
          Messages(),
          Profile(
            profileId: curruser.id,
          ),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          border: Border(
              top: BorderSide(
                  color: Color.fromRGBO(24, 115, 172, 1), width: .5)),
          //backgroundColor: ,
          currentIndex: pageIndex,
          onTap: onTap,
          backgroundColor: Colors.white,
          activeColor: Color.fromRGBO(24, 115, 172, 1),
          inactiveColor: Color.fromRGBO(34, 135, 190, .2),
          items: [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.game_controller_solid)),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.group_solid)),
            BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.video_camera_solid,
                size: 35.0,
              ),
            ),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.book_solid)),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.profile_circled)),
          ]),
    );
  }
}
