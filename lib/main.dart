import 'package:dodogy_challange/pages/home.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  var signed = false;

  Widget loginPage() {
    return Scaffold(

        body: Container(
          decoration:BoxDecoration(
            color:Color(0xdafffbea),

          ),

        alignment: Alignment.topCenter
        ,child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SexyText(
            colorLeft: Color.fromRGBO(24, 115, 172, 1),
            colorRight: Color.fromRGBO(222, 253, 255, 1)),
        signBut
      ],
    )));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dodogy',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SafeArea(child: signed ? Home() : loginPage()),
    );
  }
}

RaisedButton loginButt = RaisedButton(
  onPressed: () {},
  textColor: Colors.white,
  padding: const EdgeInsets.all(0.0),
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: <Color>[
          Color.fromRGBO(24, 115, 172, 1),
          Color.fromRGBO(222, 253, 255, 1)
        ],
      ),
      borderRadius: BorderRadius.all(Radius.elliptical(10, 20)),
    ),
    padding: const EdgeInsets.all(10.0),
    child: const Text('Sign in with Google', style: TextStyle(fontSize: 20)),
  ),
);

class SexyText extends StatefulWidget {
  final Color colorLeft;
  final Color colorRight;

  SexyText({@required this.colorLeft, @required this.colorRight});

  @override
  _SexyTextDrive createState() => _SexyTextDrive();
}

GlobalKey sexyTextKey = GlobalKey();

Shader getTextGradient(RenderBox renderBox, Color colorLeft, Color colorRight) {
  if (renderBox == null) return null;
  return LinearGradient(
    colors: <Color>[colorLeft, colorRight],
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
    print(
        getTextGradient(textRenderObject, widget.colorLeft, widget.colorRight));
    return Text(
      'Dodoggy',
      key: sexyTextKey,
      style: new TextStyle(
          fontSize: 60.0,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..shader = getTextGradient(
                textRenderObject, widget.colorLeft, widget.colorRight)),
    );
  }
}

Widget signBut = GestureDetector(
onTap: ()=> print(1),
child:Padding(
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
                style: TextStyle(color: Color.fromRGBO(24, 115, 172, 1)),
              ))
        ],
      ),
    )));
