import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:dodogy_challange/models/user.dart';
import 'package:dodogy_challange/widgets/progress.dart';
import 'package:dodogy_challange/homyz.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  final BuildContext mastercontext;

  EditProfile({this.currentUserId, this.mastercontext});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String updatedUrlPhoto;
  bool showPassword = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayNameValid = true;
  bool _bioValid = true;

  String calltheProfilePicUpoader(String osamaUrl) {
    tempfn1();
    tempfn2();
    return "https://picsum.photos/250?image=9";

  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Display Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "Display Name too short",
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Update Bio",
            errorText: _bioValid ? null : "Bio too long",
          ),
        )
      ],
    );
  }

  updateProfileData(BuildContext contextx) {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_displayNameValid && _bioValid) {
      usersRef.document(widget.currentUserId).updateData({
        "displayName": displayNameController.text,
        "bio": bioController.text,
      });
      final snackBar = SnackBar(
        content: Text('Profile Updated!'),
        duration: Duration(seconds: 2),
        backgroundColor: Color.fromRGBO(24, 115, 172, 1),
      );
      Scaffold.of(widget.mastercontext).showSnackBar(snackBar);
      Navigator.of(widget.mastercontext).pop();
    }
  }

  logout() async {
    await vauth.signOut();
    print("Signed out");
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Edit our profile",
          style: TextStyle(
              color: Color.fromRGBO(24, 115, 172, 1),
              fontWeight: FontWeight.w300),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
              icon: Icon(CupertinoIcons.lock,
                  color: Color.fromRGBO(24, 115, 172, 1)),
              onPressed: logout)
        ],
      ),
      body: isLoading
          ? circularProgress()
          : Container(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24.0, horizontal: 36),
                  child: ListView(
                    children: <Widget>[
                      SizedBox(
                        height: 40,
                      ),
                      Center(
                        child: Stack(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                if (mounted) {
                                  setState(() {
                                    updatedUrlPhoto =
                                        calltheProfilePicUpoader(user.id);
                                  });
                                }
                              },
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 4,
                                      color: Color.fromRGBO(24, 115, 172, 1)),
                                  boxShadow: [
                                    BoxShadow(
                                        spreadRadius: 2,
                                        blurRadius: 10,
                                        color: Colors.black.withOpacity(0.1),
                                        offset: Offset(0, 10))
                                  ],
                                  shape: BoxShape.circle,
                                ),
                                child: CachedNetworkImage(
                                    key: ObjectKey( updatedUrlPhoto??
                                        (user.photoUrl ??
                                            "https://www.asjfkfhdgihdknjskdjfeid.com")),
                                    imageUrl: ( updatedUrlPhoto??
                                        (user.photoUrl ??
                                            "https://www.asjfkfhdgihdknjskdjfeid.com")),
                                    imageBuilder: (context, imageProvider) =>
                                        CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          backgroundImage: imageProvider,
                                        ),
                                    errorWidget: (context, url, error) =>
                                        CircleAvatar(
                                            child: Icon(
                                          CupertinoIcons.person_solid,
                                          color:
                                              Color.fromRGBO(24, 115, 172, 1),
                                        ))),
                              ),
                            ),
                            Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 4,
                                      color: Colors.white,
                                    ),
                                    color: Color.fromRGBO(24, 115, 172, 1),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                )),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      buildDisplayName(
                          "Your name",
                          (user.displayName ??
                              (user.displayName == ""
                                  ? "Your display name"
                                  : user.displayName)),
                          _displayNameValid,
                          displayNameController,
                          "name too short"),
                      buildBio(
                          "Bio",
                          (user.bio ??
                              (user.bio == ""
                                  ? "Your biodata here"
                                  : user.bio)),
                          _bioValid,
                          bioController,
                          "Bio too long"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: OutlineButton(
                              padding: EdgeInsets.symmetric(horizontal: 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              onPressed: () {},
                              child: Text("CANCEL",
                                  style: TextStyle(
                                      fontSize: 14,
                                      letterSpacing: 2.2,
                                      color: Colors.black)),
                            ),
                          ),
                          RaisedButton(
                            onPressed: () {
                              updateProfileData(context);
                            },
                            color: Color.fromRGBO(24, 115, 172, 1),
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              "SAVE",
                              style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 2.2,
                                  color: Colors.white),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildBio(String labelText, String placeholder, bool valid,
      TextEditingController controller, String errormsg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        controller: controller,
        obscureText: false,
        decoration: InputDecoration(
            errorText: valid ? null : errormsg,
            suffixIcon: false
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: Colors.grey,
                    ),
                  )
                : null,
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: "Some bio tells good things about you",
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: "",
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w100,
              color: Colors.blueGrey,
            )),
      ),
    );
  }

  Widget buildDisplayName(String labelText, String placeholder, bool valid,
      TextEditingController controller, String errormsg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        controller: controller,
        obscureText: false,
        decoration: InputDecoration(
            errorText: valid ? null : errormsg,
            suffixIcon: false
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: Colors.grey,
                    ),
                  )
                : null,
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: "The display name here",
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: "",
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w100,
              color: Colors.blueGrey,
            )),
      ),
    );
  }
}

tempfn1 ()async {
  for( var i = 0 ; i <20; i++ ) {
    await Future.delayed(const Duration(seconds: 1), () => "1");
    print("abji hi yaha");
  }
}


tempfn2 ()async {
  for( var i = 0 ; i <20; i++ ) {
    await Future.delayed(const Duration(seconds: 1), () => "1");
    print("abji hu kahi aur");
  }
}