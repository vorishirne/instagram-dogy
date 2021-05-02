import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodogy_challange/pages/activity_feed.dart';
import 'package:dodogy_challange/pages/profile.dart';
import 'package:dodogy_challange/pages/search.dart';
import 'package:dodogy_challange/pages/upload.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
class homy extends StatefulWidget{
  final FirebaseUser user;
  homy
      (FirebaseUser this.user);
  @override
  homystate createState() => homystate();
}

class homystate extends State<homy> {
  FirebaseUser curUser;
  CollectionReference usersRef;
  CollectionReference postsRef;
  CollectionReference connsRef;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    curUser = widget.user;
    usersRef =  Firestore.instance.collection('users');
    postsRef =  Firestore.instance.collection('posts');
    connsRef =  Firestore.instance.collection('connections');


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
          Upload(curUser,usersRef,postsRef),
          Search(usersRef),
          Profile(),
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
