import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:dodogy_challange/homyz.dart';
import 'package:dodogy_challange/widgets/custom_image.dart';
import 'package:dodogy_challange/widgets/header.dart';
import 'package:dodogy_challange/widgets/post.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../compresso.dart';

class MediaPreview extends StatefulWidget {
  final Widget toShow;

  MediaPreview(this.toShow);

  @override
  MediaPreviewState createState() => MediaPreviewState();
}

class MediaPreviewState extends State<MediaPreview> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 16),
              alignment: Alignment.center,
                foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Colors.white38,
                          Colors.transparent,
                          Colors.transparent,
                          Colors.white38
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0, 0.2, 0.8, 1])),
                child: InteractiveViewer(child: widget.toShow)),
            Positioned(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:16.0,vertical: 32),
                child: IconButton(
                  icon: Icon(CupertinoIcons.back,),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              top: 0,
              left: 0,
            )
          ],
        ));
  }
}
