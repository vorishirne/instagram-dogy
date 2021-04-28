import 'dart:io';

import 'package:dodogy_challange/pages/home.dart';
import 'package:dodogy_challange/sample_pagge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dodogy_challange/Wrapper.dart';
import 'loginWall/LoginWidget.dart';
import 'package:flutter_login/src/models/login_data.dart';
import 'package:flutter_login/src/widgets/animated_text_form_field.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor:
          SystemUiOverlayStyle.dark.systemNavigationBarColor,
    ),
  );
  runApp(StatefulApp());
}



class StatefulApp extends StatefulWidget {
  @override
  MyApp createState() => MyApp();
}

FirebaseAuth _auth = FirebaseAuth.instance;

class MyApp extends State<StatefulApp> {
  GoogleSignInAccount _currentUser;
  String _message = '';
  String _verificationId;
  var signed = false;

  @override
  void initState() {
    super.initState();
    _auth.onAuthStateChanged.listen((FirebaseUser user) {
      setState(() {
        print(user);
        if (user == null) {
          signed = false;
          _verificationId = "";
        } else {
          signed = true;
        }
      });
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

  Future<String> verifyPhoneNumber(phonen) async {
    phonen = "+91" + phonen;
    setState(() {
      _message = '';
    });

    final PhoneVerificationCompleted verificationCompleted = null;
    var a = (FirebaseUser phoneAuthCredential) {
      setState(() {
        _message = "The message from ready made function" +
            'Received phone auth credential: $phoneAuthCredential';
        print("The message from ready made function");
        print(phoneAuthCredential);
      });
      Navigator.of(context).popUntil((route) => route.isFirst);
      return Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => homy()));
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        _message =
            'Oh yes Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
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
      String mesg="";
      switch (e.code) {
        case "ERROR_INVALID_VERIFICATION_CODE":
          mesg="Seems you mistyped the OTP";
          break;
        default:
          mesg="Oops! There was a problem :/\nYour OTP may be correct BTW";
      }
      return mesg;
    }
  }
  GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<void> gLogin() async{
try {
  try {
    //await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
  }
  catch (e) {
    print(e);
  }
  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth =
  await googleUser.authentication;
  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  final FirebaseUser user =
  (await _auth.signInWithCredential(credential));
  assert(user.email != null);
  assert(user.displayName != null);
  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);
  setState(() {
    if (user != null) {
      signed = true;
    } else {
      signed = false;
    }
  });
}
catch(e)
    {//ERROR_NETWORK_REQUEST_FAILED
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



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dodogy',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: signed ? homy() : loginPage(),
    );
  }
}

GlobalKey<AnimatedTextFormFieldState> vexkey =
    GlobalKey<AnimatedTextFormFieldState>();

Future<void> fLogin() {
  print("logged in viax fb");
}



Future<void> tLogin() {
  print("logged in viax tw");
}
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
