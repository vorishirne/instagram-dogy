import 'dart:async';

import 'package:dodogy_challange/widgets/header.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username;
  bool isButtonPressed = false;
  submit() {
    isButtonPressed =true;
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      SnackBar snackbar = SnackBar(content: Text("Welcome $username!"),backgroundColor: Color.fromRGBO(24, 115, 172, 1),);
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 23.0),
            child: Image.asset(
              "assets/images/ep2.png",
              height: MediaQuery.of(context).size.height * .42,
            ),
          ),
        ],
      ),
      key: _scaffoldKey,
      appBar: header(context, titleText: "Let's first setup"),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 55.0),
                  child: Center(
                    child: Text(
                      "The only thing needed is how can we call ya..",
                      style:
                          TextStyle(fontSize: 15.0, color: Color(0Xff7f7f7f)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 36, horizontal: 10),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: TextFormField(
                        onChanged: (value) => isButtonPressed =false ,
                        keyboardType: TextInputType.text,
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (val) {
                          if (!isButtonPressed){
                            return null;
                          }
                          if (val.isEmpty || val.trim().length < 3) {
                            return isButtonPressed ? "button is pressed": "Username too short";
                          } else if (val.trim().length > 12) {
                            return "Username too long";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => username = val.trim(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Your unchangable username!",
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: "Must be at least 3 characters",
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(24, 115, 172, 1),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Feels Unique",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          //Positioned(child: Text("ok"),bottom: 2,right: 5,)
        ],
      ),
    );
  }
}
