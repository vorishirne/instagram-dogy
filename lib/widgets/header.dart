import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTitle = false, String titleText, removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: isAppTitle
        ? SizedBox(child:Image.asset("assets/images/ecorp.png",fit: BoxFit.scaleDown,),width: 115,)
        : Text(
            isAppTitle ? "Dodogy" : titleText,
            style: TextStyle(
                color: Color.fromRGBO(24, 115, 172, 1),
                fontWeight: FontWeight.w300),
            overflow: TextOverflow.ellipsis,
          ),
    backgroundColor: Colors.white,

    centerTitle: true,
  );
}
