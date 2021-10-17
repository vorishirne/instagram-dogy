import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dodogy_challange/models/user.dart';
import 'package:dodogy_challange/models/postmini.dart';
import 'package:dodogy_challange/pages/edit_profile.dart';
import 'package:dodogy_challange/pages/search.dart';
import 'package:dodogy_challange/homyz.dart';
import 'package:dodogy_challange/widgets/header.dart';
import 'package:dodogy_challange/widgets/post.dart';
import 'package:dodogy_challange/widgets/post_tile.dart';
import 'package:dodogy_challange/widgets/progress.dart';
import 'dart:math';
import 'activity_feed.dart';
import 'chat.dart';

class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;

  String postOrientation = "grid";
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = -1;
  int followerCount = 0;
  int followingCount = 0;
  int tempflrcount = 0;
  List posts = [];
  User user;

  @override
  void initState() {
    super.initState();

    getFollowers();
    getFollowing();
    checkIfFollowing();
    getProfilePosts();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists && widget.profileId != currentUserId;
    });
  }

  getFollowers() async {
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .snapshots()
        .listen((event) {
      setState(() {
        followerCount = event.documents.length;
      });
    });
  }

  getFollowing() async {
    followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .snapshots()
        .listen((event) {
      setState(() {
        print("olka");
        followingCount = event.documents.length;
      });
    });
  }

  getProfilePosts() async {
    postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .snapshots()
        .listen((event) {
      setState(() {
        print("i made a mistake");
        postCount = event.documents.length;
      });
    });
  }

  Widget buildCountColumn(String label, int count, Function f) {
    return GestureDetector(
        onTap: f,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Text((count > 0 ? count : 0).toString(),
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.w400)),
                ),
                Container(
                  margin: EdgeInsets.only(top: 0.0),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            )));
  }

  void viewActivity(contextx) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (contex) => ActivityFeed()
            // EditProfile(
            //         currentUserId: currentUserId,
            //         mastercontext: contextx,
            //       ))

            ));
  }

  void editProfile(contextx) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (contex) => EditProfile(
                  currentUserId: currentUserId,
                  mastercontext: contextx,
                )));
  }

  Widget buildButton({String text, Function function}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        height: 40,
        child: CupertinoButton(
          padding: EdgeInsets.symmetric(horizontal: 4),
          color: Color.fromRGBO(24, 115, 172, 1),
          onPressed: function,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: "See activity",
        function: () {
          viewActivity(context);
        },
      );
    } else {
      return Row(children: [
        buildButton(
            text: "Message",
            function: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (contex) => Chat(
                            currentUserId: currentUserId,
                            friendId: widget.profileId,
                          )));
            }),
        SizedBox(
          width: 12,
        ),
        (isFollowing)
            ? buildButton(
                text: "Unfollow",
                function: handleUnfollowUser,
              )
            : buildButton(
                text: "Follow",
                function: handleFollowUser,
              )
      ]);
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete activity feed item for them
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // Make auth user follower of THAT user (update THEIR followers collection)
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({});
    // Put THAT user on YOUR following collection (update your following collection)
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({});
    // add activity feed item for that user to notify about new follower (us)
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": currentUser.username,
      "userId": currentUserId,
      "userProfileImg": currentUser.photoUrl,
      "timestamp": DateTime.now(),
    });
  }

  buildProfileHeader(BuildContext childContext) {
    return SizedBox(
        height: 250,
        child: FutureBuilder(
            future: usersRef.document(widget.profileId).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: Center(
                    child: SizedBox(
                      height: 250,
                    ),
                  ),
                ); //cll
              }
              if (!snapshot.data.exists) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  Navigator.of(childContext).popUntil((route) => route.isFirst);
                });
              }
              user = User.fromDocument(snapshot.data);
              print("ole ole ole");
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => editProfile(context),
                            child: SizedBox(
                              height: 75,
                              width: 75,
                              child: CachedNetworkImage(
                                  imageUrl: user.photoUrl ??
                                      "https://www.asjfkfhdgihdknjskdjfeid.com",
                                  imageBuilder: (context, imageProvider) =>
                                      CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        backgroundImage: imageProvider,
                                        radius: 40,
                                      ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                          color: Colors.white10,
                                          padding: EdgeInsets.all(25),
                                          child: Icon(
                                            CupertinoIcons.person_solid,
                                          ))),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    buildCountColumn("posts", postCount, null),
                                    buildCountColumn(
                                        "followers", followerCount - 1, () {
                                      if (widget.profileId == currentUserId) {
                                        setState(() {
                                          //miniPageController.jumpToPage(1);
                                          miniPageIndex = 1;
                                          pageController.jumpToPage(1);
                                          pageIndex = 1;
                                          print("applied page index");
                                          miniPageController.animateTo(1);
                                        });
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                      }
                                    }),
                                    buildCountColumn(
                                        "following", followingCount - 1, () {
                                      if (widget.profileId == currentUserId) {
                                        setState(() {
                                          miniPageIndex = 0;
                                          pageController.jumpToPage(1);
                                          pageIndex = 1;
                                          print("applied page index");
                                          //miniPageIndex = 0;
                                          miniPageController.animateTo(0);
                                        });
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                      }
                                    }),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[buildProfileButton()],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 12.0),
                        child: Text(
                          user.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Color.fromRGBO(24, 115, 172, 1),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text(
                          user.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 2.0),
                        child: Text(
                          user.bio,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  buildProfilePosts() {
    //return Text("");
    return StreamBuilder(
        stream: postsRef
            .document(widget.profileId)
            .collection('userPosts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          } else {
            tempflrcount = snapshot.data.documents.length;
            print("okhla");
//            WidgetsBinding.instance.addPostFrameCallback((_) {
//              setState(() {
//                postCount = tempflrcount;
//              });
//            });
            if (tempflrcount == 0) {
              final Size size = MediaQuery.of(context).size;
              return Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Image.asset('assets/images/search.png',
                          height: max(size.height / 7, size.width / 5)),
                      Text(
                        "No meme for me.. . .",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(127, 127, 127, 1),
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w200,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (postOrientation == "grid") {
              List<GridTile> gridTiles = [];
              snapshot.data.documents.forEach((post) {
                gridTiles.add(
                    GridTile(child: PostTile(postmini.fromDocument(post))));
              });
              return Container(
                // decoration: BoxDecoration(color: Colors.black87),
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                  childAspectRatio: 1.0,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: gridTiles,
                ),
              );
            } else if (postOrientation == "list") {
              List<Post> postsa = [];
              snapshot.data.documents.forEach((post) {
                postsa.add(
                    Post.fromDocument(post, addDivider: true, myPhoto: true));
              });
              return Column(children: postsa);
            }
          }
        });
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
      //postCount = tempflrcount;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(left: 30, right: 30, bottom: 8),
            child: IconButton(
              onPressed: () => setPostOrientation("grid"),
              icon: Icon(CupertinoIcons.fullscreen_exit),
              color: postOrientation == 'grid'
                  ? Color.fromRGBO(24, 115, 172, 1)
                  : Colors.grey,
            )),
        Padding(
            padding: EdgeInsets.only(left: 30, right: 30, bottom: 8),
            child: IconButton(
              onPressed: () => setPostOrientation("list"),
              icon: Icon(CupertinoIcons.fullscreen),
              color: postOrientation == 'list'
                  ? Color.fromRGBO(24, 115, 172, 1)
                  : Colors.grey,
            )),
      ],
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Profile"),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(context),
          Divider(),
          buildTogglePostOrientation(),
          Divider(
            height: 0.0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
