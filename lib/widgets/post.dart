import 'package:visibility_detector/visibility_detector.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dodogy_challange/models/user.dart';
import 'package:dodogy_challange/pages/activity_feed.dart';
import 'package:dodogy_challange/pages/comments.dart';
import 'package:dodogy_challange/homyz.dart';
import 'package:dodogy_challange/widgets/custom_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class Post extends StatefulWidget {
  final bool myPhoto;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;
  final bool addDivider;
  final BuildContext masterContext;
  final Timestamp timestamp;
  final String thumb;
  final int heightf;
  final int widthf;

  Post(
      {this.myPhoto = false,
      this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes,
      this.timestamp,
      this.addDivider = false,
      this.thumb,
      this.masterContext,
      this.heightf = 0,
      this.widthf = 0})
      : super(key: ValueKey(postId));

  factory Post.fromDocument(DocumentSnapshot doc,
      {bool addDivider = false,
      BuildContext masterContext,
      bool myPhoto = false}) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
      timestamp: doc["timestamp"],
      addDivider: addDivider,
      masterContext: masterContext,
      myPhoto: myPhoto,
      thumb: doc["thumb"] ?? "",
      heightf: doc["height"] ?? 0,
      widthf: doc["width"] ?? 0,
    );
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      username: this.username,
      location: this.location,
      description: this.description,
      mediaUrl: this.mediaUrl,
      likes: this.likes,
      likeCount: getLikeCount(this.likes),
      timestamp: this.timestamp,
      thumb: this.thumb,
      widthf: this.widthf,
      heightf: this.heightf);
}

class _PostState extends State<Post> with TickerProviderStateMixin {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final Timestamp timestamp;
  bool isVisible = true;
  bool showHeart = false;
  bool isLiked;
  int likeCount;
  Map likes;
  final String thumb;
  final int heightf;
  final int widthf;

  _PostState(
      {this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes,
      this.likeCount,
      this.timestamp,
      this.thumb,
      this.heightf = 0,
      this.widthf = 0});

  buildPostHeader(BuildContext context) {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        Widget toShow = Container(
          height: 80,
        );
        if (!snapshot.hasData) {
          toShow = Container(
            height: 80,
          );
        } else {
          User user = User.fromDocument(snapshot.data);
          bool isPostOwner = currentUserId == ownerId;
          toShow = Container(
            child: GestureDetector(
                onTap: () => showProfile(context, profileId: user.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 80,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(
                                height: 80,
                                width: 80,
                                child: CachedNetworkImage(
                                    imageUrl: user.photoUrl ??
                                        "https://www.asjfkfhdgihdknjskdjfeid.com",
                                    imageBuilder: (context, imageProvider) =>
                                        CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          backgroundImage: imageProvider,
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            //heret
                                            child: Icon(
                                              CupertinoIcons.person_solid,
                                              color: Colors.black,
                                            ))),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        user.username,
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(24, 115, 172, 1),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 20),
                                      ),
                                    ),
                                    Visibility(
                                        visible: location.length > 0,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              child: Text(
                                                location,
                                              ),
                                            ),
                                          ],
                                        )),
                                    Container(
                                      child: Text(
                                        timeago.format(timestamp.toDate()),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                    Spacer()
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 80,
                                ),
                                flex: 1,
                              ),
                              Container(
                                child: isPostOwner
                                    ? IconButton(
                                        onPressed: () =>
                                            handleDeletePost(context),
                                        icon: Icon(CupertinoIcons.delete_solid),
                                      )
                                    : Expanded(
                                        child: SizedBox(
                                        height: 80,
                                      )),
                              ),
                            ]),
                      ),
                    ),
                    Visibility(
                        visible: description.length > 0,
                        child: Container(
                          child: Text(
                            description,
                            style: TextStyle(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 9,
                          ),
                          margin: EdgeInsets.only(
                              left: 26.0, bottom: 6, top: 6),
                        )),
                  ],
                )),
          );
        }
        return AnimatedSize(
          curve: Curves.fastOutSlowIn,
          vsync: this,
          duration: Duration(milliseconds: 500),
          child: AnimatedSwitcher(
              switchInCurve: Curves.fastOutSlowIn,
              duration: const Duration(seconds: 1),
              child: toShow),
        );
      },
    );
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("Remove this post?"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    deletePost();
                    if (widget.masterContext != null) {
                      Navigator.pop(widget.masterContext);
                    }
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  )),
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel')),
            ],
          );
        });
  }

  // Note: To delete post, ownerId and currentUserId must be equal, so they can be used interchangeably
  deletePost() async {
    // delete post itself
    postsRef
        .document(ownerId)
        .collection('userPosts')
        .document(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete uploaded image for thep ost
    try {
      storageRef.child("post_$postId.jpg").delete();
    } catch (e) {
      print("This was not a photo");
    }

    try {
      storageRef.child("post_$postId.mp4").delete();
    } catch (e) {
      print("This was not a vid");
    }
//
//    try{
//      storageRef.child("post_$postId.gif").delete();
//    }
//    catch(e){
//      print("This was not a gif");
//    }

    // then delete all activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .document(ownerId)
        .collection("feedItems")
        .where('postId', isEqualTo: postId)
        .getDocuments();
    activityFeedSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // then delete all comments
    QuerySnapshot commentsSnapshot = await commentsRef
        .document(postId)
        .collection('comments')
        .getDocuments();
    commentsSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    setState(() {
      isVisible = false;
    });
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;

        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLikeToActivityFeed() {
    // add a notification to the postOwner's activity feed only if comment made by OTHER user (to avoid getting notification for our own like)
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": DateTime.now(),
        "thumb": thumb
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists && doc["type"] == "like") {
          doc.reference.delete();
        }
      });
    }
  }

  buildPostImage() {
    if (mediaUrl == "") {
      return Container();
    }
    bool vid = mediaUrl.toLowerCase().contains(".mp4");
    double h = 260;
    double ar = (heightf / widthf);
    if (heightf != 0 && widthf != 0) {
      h = ar * MediaQuery.of(context).size.width;
      h = h < MediaQuery.of(context).size.height * .76
          ? h
          : MediaQuery.of(context).size.height * .76;
    }
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Container(
          margin: EdgeInsets.only(top: 6,bottom: 6),
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      width: .4, color: Colors.blueGrey.withOpacity(.5)))),
          child: Row(
            children: [
              SizedBox(
                height: h,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    vid
                        ?
                        // Theme(
                        //         data: ThemeData.light().copyWith(
                        //           platform: TargetPlatform.iOS,
                        //         ),
                        //         child:
                        VideoItem(mediaUrl, thumb, h, ar: ar)
                        // )
                        : cachedNetworkImage(mediaUrl),
                    showHeart
                        ? Animator(
                            duration: Duration(milliseconds: 300),
                            tween: Tween(begin: 0.8, end: 1.4),
                            curve: Curves.elasticOut,
                            cycles: 0,
                            builder: (anim) => Transform.scale(
                              scale: anim.value,
                              child: Icon(
                                CupertinoIcons.heart,
                                size: 80.0,
                                color: Colors.pink,
                              ),
                            ),
                          )
                        : Text(""),
                  ],
                ),
              ),
            ],
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
          )),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 0, left: 30.0)),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                isLiked ? CupertinoIcons.heart_solid : CupertinoIcons.heart,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => showComments(context,
                  postId: postId,
                  ownerId: ownerId,
                  mediaUrl: mediaUrl,
                  thumb: thumb),
              child: Icon(
                CupertinoIcons.conversation_bubble,
                size: 34.0,
                color: Color.fromRGBO(24, 115, 172, 1),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 30.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                    fontSize: 18),
              ),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);

    return Visibility(
        visible: isVisible,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildPostHeader(context),
            buildPostImage(),
            buildPostFooter(),
            (widget.addDivider)
                ? Padding(
                    padding: const EdgeInsets.only(
                        right: 75.0, left: 75, top: 20, bottom: 20),
                    child: Divider(
                      height: 8.0,
                      color: Color.fromRGBO(24, 115, 172, .6),
                      thickness: .15,
                    ),
                  )
                : Text(""),
          ],
        ));
  }
}

showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl, String thumb}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
      thumb: thumb,
    );
  }));
}

class VideoItem extends StatefulWidget {
  final String url;
  final String thumbUrl;
  final double h;
  final double ar;
  final double start;
  final double stop;

  VideoItem(this.url, this.thumbUrl, this.h, {this.ar = 1,this.start = .7, this.stop = .3});

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  // ChewieController _chewieController;
  // VideoPlayerController _controller;
  // Future<void> _initializeVideoPlayerFuture;
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
    // Ensure disposing of the VideoPlayerController to free up resources.
    // _chewieController.dispose();
    // _controller.pause();
    // _controller.seekTo(Duration(seconds: 0));
    // await _controller.dispose();
    // setState(() {
    //   _controller = null;
    // });
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
          play = playAtFirst == 2;
          if (play) {
            playAtFirst = 1;
          }
          if (_videoController == null) {
            _videoController = CachedVideoPlayerController.network(widget.url);
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
          if (playAtFirst == 1) {
            playAtFirst = 2;
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
                      playAtFirst = 0;
                    } else {
                      _videoController?.play();
                      playAtFirst = 1;
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
                      child: CachedVideoPlayer(_videoController),
                      aspectRatio: 1 / widget.ar,
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

          return videoBurrow(context, thumbUrl: widget.thumbUrl, h: widget.h);
        },
      ),
    ));
  }
}

Widget videoBurrow(BuildContext context, {String thumbUrl = "", double h}) {
  return SizedBox(
//    height: h,
    child: Container(
      //color: Colors.pink,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          thumbUrl != ""
              ? Container(
                  // color:Colors.red,
                  child: Container(
                      child: Container(
                  child: CachedNetworkImage(
                      imageUrl: thumbUrl,
                      imageBuilder: (context, imageProvider) => SizedBox(
                              child: Image(
                            image: imageProvider,
                            fit: BoxFit.contain,
                            height: h,
                          )),
                      errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(color: Colors.black87)),
                      placeholder: (context, url) => Container(
                          decoration: BoxDecoration(color: Colors.black12))),
                )))
              : Container(decoration: BoxDecoration(color: Colors.black87)),
          Positioned(
              child: Icon(
            h != null ? CupertinoIcons.paw : CupertinoIcons.play_arrow_solid,
            color: Colors.white70,
            size: h != null ? 126 : 54,
          ))
        ],
      ),
    ),
  );
}
