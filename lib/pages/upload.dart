import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Upload extends StatefulWidget {
  final CollectionReference usersRef;
  final CollectionReference postsRef;
  final FirebaseUser user;

  Upload(FirebaseUser this.user,CollectionReference this.usersRef,CollectionReference this.postsRef);
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  @override
  Widget build(BuildContext context) {
    return Text("Upload");
  }
}
