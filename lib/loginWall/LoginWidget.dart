import 'package:dodogy_challange/homyz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'login_screen.dart';
import 'transition_route_observer.dart';

class LoginWidget extends StatefulWidget{
  LoginWidget(
  {@required this.getNumber,@required this.getOTP, this.lf,this.lg,this.lt,this.vexkey}
      );
  final Future<String> Function(LoginData) getOTP;
  final Future<void> Function() lg;
  final Future<void> Function() lf;
  final Future<void> Function() lt;
  final GlobalKey vexkey;
  final Future<String> Function(String) getNumber;
  @override
  LoginWidg createState()=> LoginWidg();

}

class LoginWidg extends State<LoginWidget> {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Dodogy',
      theme: ThemeData(
        // brightness: Brightness.dark,
        primarySwatch: createMaterialColor(Colors.white),
        accentColor: Color.fromRGBO(24, 115, 172, 1),
        cursorColor: Color.fromRGBO(24, 115, 172, 1),
        // fontFamily: 'SourceSansPro',
        textTheme: TextTheme(
          display2: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 45.0,
            // fontWeight: FontWeight.w400,
            color: Color.fromRGBO(24, 115, 172, 1),
          ),
          button: TextStyle(
            // OpenSans is similar to NotoSans but the uppercases look a bit better IMO
            fontFamily: 'OpenSans',
          ),
          caption: TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
            color: Color.fromRGBO(24, 115, 172, 1),
          ),
          display4: TextStyle(fontFamily: 'Quicksand'),
          display3: TextStyle(fontFamily: 'Quicksand'),
          display1: TextStyle(fontFamily: 'Quicksand'),
          headline: TextStyle(fontFamily: 'NotoSans'),
          title: TextStyle(fontFamily: 'NotoSans'),
          subhead: TextStyle(fontFamily: 'NotoSans'),
          body2: TextStyle(fontFamily: 'NotoSans'),
          body1: TextStyle(fontFamily: 'NotoSans'),
          subtitle: TextStyle(fontFamily: 'NotoSans'),
          overline: TextStyle(fontFamily: 'NotoSans'),
        ),
        cardTheme: CardTheme(

          elevation: 5,
          margin: EdgeInsets.only(top: 15),
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(100.0)),
        ),
      ),
      home: LoginScreen(getNumber: widget.getNumber,getOTP: widget.getOTP,lf: widget.lf,
        lg: widget.lg,
        lt: widget.lt,
      vexkey: widget.vexkey,),
      navigatorObservers: [TransitionRouteObserver()],
      routes: {
        "/login": (context) => LoginScreen(getNumber: widget.getNumber,getOTP: widget.getOTP,lf: widget.lf,
          lg: widget.lg,
          lt: widget.lt,
            vexkey: widget.vexkey),
        "/homy": (context) => homy(),
      },
    );
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
    swatch[(strength * 1000).round()] = Color(0xc9fffbea);
  });
  return MaterialColor(color.value, swatch);
}