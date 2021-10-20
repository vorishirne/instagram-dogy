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
import 'MediaPreview.dart';

class MediaShare extends StatefulWidget {
  final String currentUserId;
  final String friendId;
  final BuildContext mastercontext;

  MediaShare({this.currentUserId, this.friendId, this.mastercontext});

  @override
  MediaShareState createState() => MediaShareState();
}

class MediaShareState extends State<MediaShare>
    with AutomaticKeepAliveClientMixin<MediaShare> {
  MediaInteract mediaInteract;
  String postId = Uuid().v4();
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  void initState() {
    super.initState();
    mediaInteract = MediaInteract(context, "Share a post!");
  }

  @override
  Widget build(BuildContext context) {
    double uploadBoxHeight = MediaQuery.of(context).size.height * .6 -
        //kBottomNavigationBarHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        kToolbarHeight -
        50;
    return Scaffold(
        key: _scaffoldKey,
        appBar: header(context, titleText: "Share Posts"),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: ListView(
              children: [
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    mediaInteract.mediaFile == null
                        ? pikapi()
                        : Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                MediaPreview(mediaInteract.isPic
                                    ? (Image.file(
                                        mediaInteract.mediaFile,
                                        fit: BoxFit.contain,
                                      ))
                                    : videoFile(
                                        mediaInteract.mediaFile,
                                        mediaInteract.thumbnailFile,
                                        (MediaQuery.of(context).size.height *
                                            .9),
                                        ar: mediaInteract.heightH /
                                            mediaInteract.widthW,
                                        stop: .05,
                                      ))));
                  },
                  child: SizedBox(
                      //height: uploadBoxHeight,
                      //width: MediaQuery.of(context).size.width - 60,
                      child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Color.fromRGBO(24, 115, 172, 1)),
                        borderRadius: BorderRadius.circular(22)),
                    child: mediaInteract.mediaFile == null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  padding: EdgeInsets.all(16),
                                  height: uploadBoxHeight * .35,
                                  child: Text(
                                    "Pick a Story?",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromRGBO(24, 115, 172, 1),
                                        fontSize: 48),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  )),
                              Container(
                                height: uploadBoxHeight * .70,
                                child: Image.asset('assets/images/ep2.png',
                                    fit: BoxFit.scaleDown),
                              ),
                            ],
                          )
                        : SizedBox(
                            height: uploadBoxHeight,
                            child: (mediaInteract.isPic
                                ? Image.file(mediaInteract.mediaFile)
                                : videoBurrowFile(context,
                                    thumbFile: mediaInteract.thumbnailFile,
                                    h: uploadBoxHeight)),
                          ),
                  )),
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width * .7,
                    child: buildDisplayName(
                        "Write a story...", "", true, captionController, "")),
                SizedBox(
                    width: MediaQuery.of(context).size.width * .7,
                    child: buildDisplayName("Add your location...", "", true,
                        locationController, "")),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: OutlineButton(
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            mediaInteract.init();
                            locationController.clear();
                            captionController.clear();
                          });
                        },
                        child: Text("CLEAR",
                            style: TextStyle(
                                fontSize: 14,
                                letterSpacing: 2.2,
                                color: Colors.black)),
                      ),
                    ),
                    RaisedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        upy(); //       updateProfileData(context);
                      },
                      color: Color.fromRGBO(24, 115, 172, 1),
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "UPLOAD",
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.white),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  pikapi() async {
    mediaInteract.init();
    String number = await mediaInteract.selectImageVideo(context, "both");
    await mediaInteract.dial(number);
    setState(() {});
  }

  upy() async {
    if (mediaInteract.mediaFile != null || captionController.text != "") {
      final snackBar = SnackBar(
        content: Text('Our message is right on the way!'),
        duration: Duration(seconds: 1000, milliseconds: 500),
        backgroundColor: Color.fromRGBO(24, 115, 172, 1),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      String ts = DateTime.now().millisecondsSinceEpoch.toString();
      if (mediaInteract.mediaFile != null) {
        if (mediaInteract.isPic) {
          await mediaInteract.uploadPic("post" +
              currentUser.id +
              ts); //when this was condition, every photo was same in the entire chat, obv,
          //but while uploading they were differing. lol cahing!!
        } else {
          await mediaInteract.uploadVid("post" + currentUser.id + ts);
        }
        if (mediaInteract.mediaUrl == "") {
          if (mounted) {
            setState(() {
              mediaInteract.init();
            });
          }
          _scaffoldKey.currentState.hideCurrentSnackBar();
          return;
        }
      }
      var temp = {
        "postId": currentUser.id + ts,
        "thumb": mediaInteract.thumbUrl,
        "ownerId": currentUser.id,
        "username": currentUser.username,
        "mediaUrl": mediaInteract.mediaUrl,
        "description": captionController.text,
        "location": locationController.text,
        "timestamp": DateTime.now(),
        "likes": {},
        "height": mediaInteract.heightH,
        "width": mediaInteract.widthW
      };
      postsRef
          .document(currentUser.id)
          .collection("userPosts")
          .document(currentUser.id + ts)
          .setData(temp);
      _scaffoldKey.currentState.hideCurrentSnackBar();
      if (mounted) {
        setState(() {
          mediaInteract.init();
          locationController.clear();
          captionController.clear();
        });
      }
    }
  }
}

Widget buildDisplayName(String labelText, String placeholder, bool valid,
    TextEditingController controller, String errormsg) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0, top: 8),
    child: TextField(
      minLines: labelText == "Write a story..." ? 2 : 1,
      textCapitalization: TextCapitalization.sentences,
      controller: controller,
      keyboardType: labelText == "Write a story..."
          ? TextInputType.multiline
          : TextInputType.text,
      maxLines: null,
      obscureText: false,
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromRGBO(24, 115, 172, 1), width: 2.0),
            borderRadius: BorderRadius.circular(25.0),
          ),
          contentPadding: EdgeInsets.only(bottom: 3, left: 12, top: 24),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeholder,
          alignLabelWithHint: true,
          labelStyle: TextStyle(color: Color.fromRGBO(24, 115, 172, 1)),
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w100,
            color: Color.fromRGBO(24, 115, 172, 1),
          )),
    ),
  );
}

class videoFile extends StatefulWidget {
  final File url;
  final File thumbUrl;
  final double h;
  final double ar;
  final double start;
  final double stop;

  videoFile(this.url, this.thumbUrl, this.h,
      {this.ar = 1, this.start = .7, this.stop = .3});

  @override
  videoFileState createState() => videoFileState();
}

class videoFileState extends State<videoFile> {
  CachedVideoPlayerController _videoController;
  Completer videoPlayerInitialized = Completer();
  UniqueKey stickyKey = UniqueKey();
  bool readycontroller = false;
  bool play = false;

  @override
  void initstate() {
    super.initState();
  }

  @override
  void dispose() async {
    _videoController?.dispose()?.then((_) {
      readycontroller = false;
      _videoController = null;
      videoPlayerInitialized = Completer(); // resets the Completer
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // width: 200,
        // height: 200,
        child: VisibilityDetector(
      key: stickyKey,
      onVisibilityChanged: (VisibilityInfo info) {
        print("meri jung one man army");
        print(info.visibleFraction);
        if (info.visibleFraction > widget.start) {
          play = false;
          if (_videoController == null) {
            _videoController = CachedVideoPlayerController.file(widget.url);
            _videoController.initialize().then((_) {
              videoPlayerInitialized.complete(true);
              if (mounted) {
                setState(() {
                  readycontroller = true;
                });
              }
              _videoController.setLooping(true);
              if (play) {
                _videoController.play();
              }
            });
          }
        } else if (info.visibleFraction < widget.stop) {
          if (mounted) {
            setState(() {
              readycontroller = false;
            });
          }

          _videoController?.pause();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _videoController?.dispose()?.then((_) {
              setState(() {
                _videoController = null;
                videoPlayerInitialized = Completer(); // resets the Completer
              });
            });
          });
        }
      },
      child: FutureBuilder(
        future: videoPlayerInitialized.future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _videoController != null &&
              readycontroller) {
            // should also check that the video has not been disposed
            return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_videoController?.value?.isPlaying) {
                      _videoController?.pause();
                      setState(() {
                        play = false;
                      });
                    } else {
                      _videoController?.play();

                      setState(() {
                        play = true;
                      });
                    }
                  });
                },
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1 / widget.ar,
                      child: CachedVideoPlayer(_videoController),
                    ),
                    !play
                        ? Icon(
                            CupertinoIcons.paw_solid,
                            color: Colors.white70,
                            size: 126,
                          )
                        : Text("")
                  ],
                )); // display the video
          }

          return videoBurrowFile(context,
              thumbFile: widget.thumbUrl, h: widget.h);
        },
      ),
    ));
  }
}

Widget videoBurrowFile(BuildContext context, {File thumbFile, double h}) {
  return SizedBox(
    height: h,
    child: Container(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          thumbFile != null
              ? Container(
                  // color:Colors.red,
                  child: Container(
                      child: Container(
                  child: Image.file(
                    thumbFile,
                    fit: BoxFit.contain,
                    height: h,
                  ),
                )))
              : Container(decoration: BoxDecoration(color: Colors.black87)),
          Positioned(
              child: Icon(
            CupertinoIcons.paw,
            color: Colors.white70,
            size: 126,
          ))
        ],
      ),
    ),
  );
}
