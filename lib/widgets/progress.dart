import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 10.0),
      child: CupertinoActivityIndicator(radius:24));
}
