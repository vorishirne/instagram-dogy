import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodogy_challange/pages/activity_feed.dart';
import 'package:dodogy_challange/pages/profile.dart';
import 'package:dodogy_challange/pages/search.dart';
import 'package:dodogy_challange/pages/upload.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models/user.dart';

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
StorageReference storageRef ;
FirebaseUser user;
User curruser;
User currentUser;

class homy extends StatefulWidget{
  final FirebaseUser userx;
  final User curruserx;
  homy
      (FirebaseUser this.userx, User this.curruserx) ;

  @override
  homystate createState() => homystate();
}

class homystate extends State<homy> {

  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    user = widget.userx;
    curruser = widget.curruserx;
    currentUser = widget.curruserx;
    pageController = PageController();
    //curUser = widget.user;
    usersRef =  Firestore.instance.collection('users');
    postsRef =  Firestore.instance.collection('posts');
    commentsRef = Firestore.instance.collection('comments');
    activityFeedRef = Firestore.instance.collection('feed');
    followersRef = Firestore.instance.collection('followers');
    followingRef = Firestore.instance.collection('following');
    timelineRef = Firestore.instance.collection('timeline');
    storageRef = FirebaseStorage.instance.ref();


  }

  @override
  dispose(){
    pageController.dispose();
    super.dispose();
  }



  Future<bool> _goToLogin(BuildContext context) async {
    await _auth.signOut();
    print("Signed out");
    return Navigator.of(context)
        .pushReplacementNamed('/')
        // we dont want to pop the screen, just replace it completely
        .then((_) => false);
  }



  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
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
          // Timeline(),
          RaisedButton(
            child: Text('Logout'),
            onPressed: () async {
            await  _goToLogin(context);
            },
          ),
          ActivityFeed(),
          Upload(user,curruser,usersRef,postsRef),
          Search(usersRef),
          Profile(profileId: curruser.id,),
        ],
        controller: pageController, 
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        border: Border(top:BorderSide(color: Color.fromRGBO(24, 115, 172, 1),width: .5)),
        //backgroundColor: ,
          currentIndex: pageIndex,
          onTap: onTap,
          backgroundColor: Colors.white,
          activeColor: Color.fromRGBO(24, 115, 172, 1),
          inactiveColor: Color.fromRGBO(34, 135, 190, .2),
          items: [
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.game_controller_solid)),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.heart_solid)),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.photo_camera,
                size: 35.0,
              ),
            ),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.group_solid)),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.book_solid)),
          ]),
    );
  }
}
