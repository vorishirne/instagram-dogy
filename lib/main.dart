import 'dart:io';
import 'package:splashscreen/splashscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodogy_challange/pages/create_account.dart';
//import 'package:dodogy_challange/pages/home.dart';
import 'package:dodogy_challange/homyz.dart' hide currentUser;
import 'package:dodogy_challange/sample_pagge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dodogy_challange/Wrapper.dart';
import 'loginWall/LoginWidget.dart';
import 'package:flutter_login/src/models/login_data.dart';
import 'package:flutter_login/src/widgets/animated_text_form_field.dart';

import 'models/user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor:
          SystemUiOverlayStyle.dark.systemNavigationBarColor,
    ),
  );
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_) {
    print("Timestamps enabled in snapshots\n");
  }, onError: (_) {
    print("Error enabling timestamps in snapshots\n");
  });
  //WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(home: StatefulApp()));
}

class StatefulApp extends StatefulWidget {
  @override
  MyApp createState() => MyApp();
}
User currentUser;
FirebaseAuth _auth = FirebaseAuth.instance;
final usersRef = Firestore.instance.collection('users');
FirebaseUser cUser ;
class MyApp extends State<StatefulApp> {

  String stale="";
  String _verificationId;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  String signed = "";

  @override
  void initState() {
    super.initState();
    _auth.onAuthStateChanged.listen((FirebaseUser user) async{
      print(user);

      if (user == null) {
        stale="out";
        cUser=user;
        currentUser=null;
        setState(() {
          signed = "false";
          _verificationId = "";
        });
      } else {
        stale=="in";
        cUser=user;

        await createUserInFirestore();
        currentUser = User.fromDocument(await usersRef.document(user.uid).get());
        setState(() {
          signed = "true";
        });
      }
    });

//    _googleSignIn.onCurrentUserChanged
//        .listen((GoogleSignInAccount currentAccount) {
//      setState(() {
//        _currentUser = currentAccount;
//        print(_currentUser);
//      });
//      if (_currentUser == null) {
//        print(
//            "##############################logged out%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
//      }
//    });
    //    _googleSignIn.signInSilently();
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final FirebaseUser user = await _auth.currentUser();
    DocumentSnapshot doc;
    print("%^%0987%^&%6%^&*&&*(*&*(***(*");
    int i = 0;
    while (i < 3) {
      try {
        print("trying babe");
        doc = await usersRef.document(user.uid).get();
        i=0;
        break;
      } catch (e) {
        print(e);
        i += 1;
      }
    }

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in users collection
      final DateTime timestamp = DateTime.now();
      final followersRef = Firestore.instance.collection('followers');
      final followingRef = Firestore.instance.collection('following');
      usersRef.document(user.uid).setData({
        "id": user.uid,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": "",
        "displayName": "",
        "bio": "",
        "timestamp": timestamp
      });
      followersRef
          .document(user.uid)
          .collection('userFollowers')
          .document(user.uid)
          .setData({});
      followingRef
          .document(user.uid)
          .collection('userFollowing')
          .document(company)
          .setData({});
    }
  }

  Future<String> verifyPhoneNumber(phonen) async {
    phonen = "+91" + phonen;
    setState(() {

    });

    final PhoneVerificationCompleted verificationCompleted = null;
    var a = (FirebaseUser phoneAuthCredential) {
      setState(() {

        print("The message from ready made function");
        print(phoneAuthCredential);
      });
      Navigator.of(context).popUntil((route) => route.isFirst);
      return Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => homy(cUser,currentUser)));
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {

        print(authException);
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      print("The code's verification id");
      print(verificationId);
      print("sent toky tuki");
      print(forceResendingToken);
      print("Sent the code");
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      print("This time it happened");
      print(verificationId);
      _verificationId = verificationId;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: phonen,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);

    return null;
  }

  Future<String> signInWithPhoneNumber(LoginData lgd) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId,
        smsCode: lgd.password,
      );
      print("precious creds");
      print(lgd.password);
      print(credential);
      final FirebaseUser user = (await _auth.signInWithCredential(credential));
      print("precious user <3");
      print(user);
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      print("toka more");
      var om = (await user.getIdToken());
      print(om);
//    Navigator.of(context).popUntil((route) => route.isFirst);
//    return Navigator.of(context)
//        .pushReplacement(MaterialPageRoute(builder: (BuildContext context) => homy()));
//    setState(() {
//      if (user != null) {
//        signed = true;
//      } else {
//        signed = false;
//      }
//    });
      print("got that page manually");
      return null;
    } catch (e) {
      print("error during validating otp");
      print(e);
      String mesg = "";
      switch (e.code) {
        case "ERROR_INVALID_VERIFICATION_CODE":
          mesg = "Seems you mistyped the OTP";
          break;
        default:
          mesg = "Oops! There was a problem :/\nYour OTP may be correct BTW";
      }
      return mesg;
    }
  }

  Future<void> gLogin() async {
    try {
      try {
        //await _googleSignIn.disconnect();
        await _googleSignIn.signOut();
      } catch (e) {
        print(e);
      }
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final FirebaseUser user = (await _auth.signInWithCredential(credential));
      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

    } catch (e) {
      //ERROR_NETWORK_REQUEST_FAILED
      //network_error
      print("The problem with google sign was");
      print(e);
      print(e.code);
    }
  }

//  Future<void> loginGoog() async {
//    try {
//      await _googleSignIn.signIn();
//    } catch (error) {
//      print(error);
//    }
//  }
//
//  Future<void> logoutGoog() {
//    return _googleSignIn.disconnect();
//  }
  Widget loginPage() {
    return LoginWidget(
      getOTP: signInWithPhoneNumber,
      getNumber: verifyPhoneNumber,
      lf: gLogin,
      lg: gLogin,
      lt: gLogin,
      //vexkey: vexkey,
    );

//    return Scaffold(
////    body:Builder(
////        builder: (context) => PhoneSignInSection(Scaffold.of(context))));
//        body: Container(
//            decoration: BoxDecoration(
//              color: Color(0xc9fffbea),
//            ),
//            alignment: Alignment.topCenter,
//            child: Column(
//              mainAxisAlignment: MainAxisAlignment.center,
//              crossAxisAlignment: CrossAxisAlignment.center,
//              children: <Widget>[
//                SexyText([
//                  Color.fromRGBO(24, 115, 172, 1),
//                  Color.fromRGBO(222, 253, 255, 1)
//                ]),
//                SignBut(loginGoog),
//                SignBut(logoutGoog)
//              ],
//            )));
  }


  Widget oops(story){
    return new SplashScreen(
      seconds: 5,
      backgroundColor: Color.fromRGBO(222, 253, 255, 1),
      image: Image.asset('assets/images/search.png'),
      title: Text("dodoggy_challange"),
      photoSize: 50.0,
      loaderColor: Color.fromRGBO(24, 115, 172, .4),
      navigateAfterSeconds: story(),
    );
  }
Widget choose(){
    if(signed=="true"){
      return homy(cUser,currentUser);
    }
    if (signed=="false"){
      return loginPage();
    }
    return sample_pagge();
}
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dodogy',
      theme: ThemeData(
        primarySwatch: createMaterialColor(Colors.white),
      ),
      home: choose(),
    );
  }
}

GlobalKey<AnimatedTextFormFieldState> vexkey =
    GlobalKey<AnimatedTextFormFieldState>();

class SexyText extends StatefulWidget {
  final List<Color> clrs;

  SexyText(List<Color> clrs) : this.clrs = clrs;

  @override
  _SexyTextDrive createState() => _SexyTextDrive();
}

GlobalKey sexyTextKey = GlobalKey();

Shader getTextGradient(RenderBox renderBox, List<Color> clrs) {
  if (renderBox == null) return null;
  return LinearGradient(
    colors: clrs,
  ).createShader(Rect.fromLTWH(
      renderBox.localToGlobal(Offset.zero).dx,
      renderBox.localToGlobal(Offset.zero).dy,
      renderBox.size.width,
      renderBox.size.height));
}

class _SexyTextDrive extends State<SexyText> {
  RenderBox textRenderObject;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resetRenderBox());
  }

  _resetRenderBox() {
    setState(() {
      textRenderObject = sexyTextKey.currentContext.findRenderObject();
    });
  }

  @override
  Widget build(BuildContext context) {
    print(getTextGradient(textRenderObject, widget.clrs));
    return Text(
      'Dodoggy',
      key: sexyTextKey,
      style: new TextStyle(
          fontSize: 60.0,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..shader = getTextGradient(textRenderObject, widget.clrs)),
    );
  }
}

class SignBut extends StatelessWidget {
  final dynamic callb;

  SignBut(dynamic callb) : this.callb = callb;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
        onTap: callb,
        child: Padding(
            padding: EdgeInsets.all(30),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Color(0xffc4d3d4),
              ),
              height: 60,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 12.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0)),
                      color: Colors.green,
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Sign in With google',
                        textScaleFactor: 2,
                        style:
                            TextStyle(color: Color.fromRGBO(24, 115, 172, 1)),
                      ))
                ],
              ),
            )));
  }
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r,
      g,
      b,
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}




