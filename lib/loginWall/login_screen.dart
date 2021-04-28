import 'package:dodogy_challange/sample_pagge.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

import 'constants.dart';
import 'custom_route.dart';
import 'dashboard_screen.dart';
import 'users.dart';

class LoginScreen extends StatefulWidget{
  LoginScreen(
      {@required this.getNumber,@required this.getOTP, this.lf,this.lg,this.lt,this.vexkey}
      );
  final Future<String> Function(LoginData) getOTP;
  final Future<String> Function(String) getNumber;
  final Future<void> Function() lg;
  final Future<void> Function() lf;
  final Future<void> Function() lt;
  final GlobalKey vexkey;

  @override
  LoginScree createState()=> LoginScree();

}

class LoginScree extends State<LoginScreen> {

  static const routeName = '/auth';

  Duration get loginTime => Duration(milliseconds: 250);

  Future<String> _loginUser(LoginData data) {
    return Future.delayed(Duration(seconds: 3)).then((_) {
      if (!mockUsers.containsKey(data.name)) {
        return 'Username not exists';
      }
      if (mockUsers[data.name] != data.password) {
        return 'OTP does not match';
      }
      return null;
    });
  }

  Future<String> _recoverPassword(String name) {
    return Future.delayed(Duration(seconds: 0)).then((_) {
      if (!mockUsers.containsKey(name)) {
        return 'Username not exists';
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = BorderRadius.vertical(
      bottom: Radius.circular(10.0),
      top: Radius.circular(20.0),
    );

    return FlutterLogin(
      title: Constants.appName,
      logo: 'assets/images/ecorp.png',
      logoTag: "logo tag",
      titleTag: "Constants.titleTag",
      messages: LoginMessages(
        loginButton: 'Get In',
        recoverPasswordButton: 'Check',
        recoverPasswordIntro: 'Put your OTP here',
        recoverPasswordDescription: 'You must get the OTP very soon...',
        recoverPasswordSuccess: 'OTP verified',
      ),
      theme: LoginTheme(
        cardTheme: CardTheme(
          elevation: 5,
          margin: EdgeInsets.only(top: 15),
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(130.0)),
        ),

        //   usernameHint: 'Username',
        //   passwordHint: 'Pass',
        //   confirmPasswordHint: 'Confirm',

        //   signupButton: 'REGISTER',
        //   forgotPasswordButton: 'Forgot huh?',
        //   recoverPasswordButton: 'Check',
        //
        //   confirmPasswordError: 'Not match!',
        //   recoverPasswordIntro: 'Put your OTP here',
        //   recoverPasswordDescription: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
        //   recoverPasswordSuccess: 'Password rescued successfully',
        // ),
        // theme: LoginTheme(
        //   primaryColor: Colors.teal,
        //   accentColor: Colors.yellow,
        //   errorColor: Colors.deepOrange,
        //   pageColorLight: Colors.indigo.shade300,
        //   pageColorDark: Colors.indigo.shade500,
        //   titleStyle: TextStyle(
        //     color: Colors.greenAccent,
        //     fontFamily: 'Quicksand',
        //     letterSpacing: 4,
        //   ),
        //   // beforeHeroFontSize: 50,
        //   // afterHeroFontSize: 20,
        //   bodyStyle: TextStyle(
        //     fontStyle: FontStyle.italic,
        //     decoration: TextDecoration.underline,
        //   ),
        //   textFieldStyle: TextStyle(
        //     color: Colors.orange,
        //     shadows: [Shadow(color: Colors.yellow, blurRadius: 2)],
        //   ),
        buttonStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(127, 127, 127, 1),
        ),
        //   cardTheme: CardTheme(
        //     color: Colors.yellow.shade100,
        //     elevation: 5,
        //     margin: EdgeInsets.only(top: 15),
        //     shape: ContinuousRectangleBorder(
        //         borderRadius: BorderRadius.circular(100.0)),
        //   ),
        //inputTheme: InputDecorationTheme(
        //filled: true,
        //fillColor: Colors.purple.withOpacity(.1),
        //contentPadding: EdgeInsets.zero,
//           errorStyle: TextStyle(
//             backgroundColor: Colors.orange,
//             color: Colors.white,
//           ),

        inputTheme: InputDecorationTheme(
          labelStyle: TextStyle(fontSize: 12, color: Colors.blueGrey),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromRGBO(127, 127, 127, 1), width: .8),
            borderRadius: inputBorder,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromRGBO(127, 127, 127, 1), width: .8),
            borderRadius: inputBorder,
          ),
          errorBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromRGBO(127, 127, 127, 1), width: .8),
            borderRadius: inputBorder,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromRGBO(127, 127, 127, 1), width: .8),
            borderRadius: inputBorder,
          ),
          disabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromRGBO(127, 127, 127, 1), width: .8),
            borderRadius: inputBorder,
          ),
        ),
        buttonTheme: LoginButtonTheme(
          splashColor: Color.fromRGBO(24, 115, 172, 1),
          backgroundColor: Color(0xc9fffbea),
          highlightColor: Color.fromRGBO(222, 253, 255, 1),
          elevation: 9.0,
          highlightElevation: 6.0,
        ),
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        //     // shape: CircleBorder(side: BorderSide(color: Colors.green)),
        //     // shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(55.0)),
        //   ),
        // ),
      ),
      emailValidator: (value) {
        if (!(value.length == 16)) {
          return "Phone is 10 barks long";
        }
        return null;
      },
      passwordValidator: (value) {
        if (!(value.length == 11)) {
          return "OTP should be 6 barks long";
        }
        return null;
      },
      onLogin: (loginData) {
        print('Login info');
        LoginData login = LoginData(
            name: loginData.name.substring(4).replaceAll("-", ""),
            password: loginData.password.replaceAll("-", ""));
        print('Name: ${login.name}');
        print('Password: ${login.password}');
        return widget.getOTP(login);
      },
      onSignup: (loginData) {
        print('Signup info');

        return _loginUser(loginData);
      },
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(FadePageRoute(
          builder: (context) => homy(),
        ));
      },
      onRecoverPassword: (name) {
        name = name.substring(4).replaceAll("-", "");
        print('Recover password info');
        print('Name: $name');
        return widget.getNumber(name);
        // Show new password dialog
      },
      showDebugButtons: false,
      fLogin: widget.lf,
      gLogin: widget.lg,
      tLogin: widget.lt,
      vexKey: widget.vexkey,
    );
  }
}
