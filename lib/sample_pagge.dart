import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


FirebaseAuth _auth =FirebaseAuth.instance;
class homy extends StatelessWidget {
  Future<bool> _goToLogin(BuildContext context) async{
    await _auth.signOut();
    print("Signed out");
    return Navigator.of(context)
        .pushReplacementNamed('/')
    // we dont want to pop the screen, just replace it completely
        .then((_) => false);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: RaisedButton(
        child: Text("Click me to go back"),
        onPressed: () => _goToLogin(context),
      ),
    );
  }
}