import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodogy_challange/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:dodogy_challange/models/user.dart';
import 'package:dodogy_challange/homyz.dart';
import 'package:dodogy_challange/widgets/post.dart';
import 'package:dodogy_challange/widgets/progress.dart';

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List posts;

  @override
  void initState() {
    super.initState();
    getTimeline();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List posts = List<Widget>.from(snapshot.documents
        .map((doc) => Post.fromDocument(
              doc,
              addDivider: true,
            ))
        .toList());
    posts.insert(
        0,
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
        ));
    setState(() {
      this.posts = posts;
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildNoContent();
    } else {
      return ListView(children: posts);
    }
  }

  Container buildNoContent() {
    final Size size = MediaQuery.of(context).size;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Image.asset('assets/images/search.png',
                height: max(size.height / 7, size.width / 5)),
            Text(
              "ComeOn! Get me some company.. . .",
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

  @override
  Widget build(context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: header(context, isAppTitle: true),
        body: RefreshIndicator(
            backgroundColor: Color.fromRGBO(222, 253, 255, 1),
            color: Color.fromRGBO(24, 115, 172, 1),
            onRefresh: () => getTimeline(),
            child: buildTimeline()));
  }
}
