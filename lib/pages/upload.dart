import 'dart:io';
import 'package:dodogy_challange/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodogy_challange/widgets/progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';

class Upload extends StatefulWidget {
  final CollectionReference usersRef;
  final CollectionReference postsRef;
  final FirebaseUser user;
  final User curruser;

  Upload(FirebaseUser this.user, User this.curruser,
      CollectionReference this.usersRef, CollectionReference this.postsRef);

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  final _flutterVideoCompress = FlutterVideoCompress();
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  final StorageReference storageRef = FirebaseStorage.instance.ref();
  File file;
  File file2;
  int height_upload = 0;
  int width_upload = 0;
  bool isPic = true;
  bool isUploading = false;
  String postId = Uuid().v4();

  Widget mainOptions() {
    return Container(
        child: Column(
      children: <Widget>[
        ListTile(
          leading: SizedBox(
            height: 45,
            width: 45,
            child: CachedNetworkImage(
                imageUrl: widget.user.photoUrl ??
                    "https://www.asjfkfhdgihdknjskdjfeid.com",
                imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: imageProvider,
                    ),
                errorWidget: (context, url, error) => new Icon(
                      CupertinoIcons.person_solid,
                      size: 20,
                    )),
          ),
          title: Container(
            width: 250.0,
            child: TextField(
              controller: captionController,
              decoration: InputDecoration(
                hintText: "Write a story...",
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        Divider(),
        ListTile(
          leading: Icon(
            CupertinoIcons.location_solid,
            color: Color.fromRGBO(24, 115, 172, 1),
            size: 35.0,
          ),
          title: Container(
            width: 250.0,
            child: TextField(
              controller: locationController,
              decoration: InputDecoration(
                hintText: "Where was this media taken?",
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: getUserLocation,
          child: Container(
              width: 200.0,
              height: 50.0,
              alignment: Alignment.center,
              child: Text(
                "Use this Location?",
                style: TextStyle(color: Color.fromRGBO(24, 115, 172, 1)),
              )),
        ),
      ],
    ));
  }

  Widget bottomOptions() {
    return Container(
        child: Column(
      children: <Widget>[
        ListTile(
          leading: CachedNetworkImage(
              imageUrl: widget.user.photoUrl ??
                  "https://www.asjfkfhdgihdknjskdjfeid.com",
              imageBuilder: (context, imageProvider) => CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: imageProvider,
                  ),
              errorWidget: (context, url, error) => new Icon(
                    CupertinoIcons.person_solid,
                    color: Color.fromRGBO(24, 115, 172, 1),
                  )),
          title: Container(
            width: 250.0,
            child: TextField(
              style: TextStyle(color: Colors.white),
              controller: captionController,
              decoration: InputDecoration(
                  hintText: "Write a caption...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  fillColor: Colors.white),
            ),
          ),
        ),
        Divider(),
        ListTile(
          leading: Icon(
            CupertinoIcons.location_solid,
            color: Color.fromRGBO(24, 115, 172, 1),
            size: 35.0,
          ),
          title: Container(
            width: 250.0,
            child: TextField(
              style: TextStyle(color: Colors.white),
              controller: locationController,
              decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey),
                  hintText: "Attach a location?",
                  border: InputBorder.none,
                  fillColor: Colors.white,
                  focusColor: Colors.white,
                  hoverColor: Colors.white),
            ),
          ),
        ),
        GestureDetector(
          onTap: getUserLocation,
          child: Padding(
            padding: const EdgeInsets.only(left: 28.0, bottom: 28, top: 8),
            child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Use this Location?",
                  style: TextStyle(color: Color.fromRGBO(24, 115, 172, 1)),
                )),
          ),
        ),
      ],
    ));
  }

  Widget noImge() {
    return Container(
        height: MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height -
                //kBottomNavigationBarHeight -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                kToolbarHeight -
                50
            : MediaQuery.of(context).size.height -
                //kBottomNavigationBarHeight -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                kToolbarHeight -
                50 +
                MediaQuery.of(context).size.height * .27,
//              CupertinoTabBar(
//                items: [
//                  BottomNavigationBarItem(
//                      icon: Icon(CupertinoIcons.game_controller_solid)),
//                  BottomNavigationBarItem(
//                      icon: Icon(CupertinoIcons.game_controller_solid))
//                ],
//              ).preferredSize.height,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            uploadItem(),
            mainOptions(),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                file == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 23.0),
                            child: Image.asset(
                              "assets/images/upload.png",
                              height: MediaQuery.of(context).size.height * .27,
                            ),
                          ),
                        ],
                      )
                    : Container(width: 0.0, height: 0.0)
              ],
            )
          ],
        ));
  }

  Widget withImage() {
    print("is pic");
    print(isPic);
    return Container(
      decoration: BoxDecoration(
          //AssetImage("assets/images/source.gif",)
          image: DecorationImage(
              image: isPic ? FileImage(file) : Image.file(file2).image,
              fit: BoxFit.contain)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              children: <Widget>[
                bottomOptions(),
                isUploading
                    ? linearProgress()
                    : Container(width: 0.0, height: 0.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Caption Post",
          style: TextStyle(
              color: Color.fromRGBO(24, 115, 172, 1),
              fontWeight: FontWeight.w300),
        ),
        leading: file == null
            ? Text("")
            : IconButton(
                icon: Icon(
                  CupertinoIcons.clear_thick,
                  color: Color.fromRGBO(24, 115, 172, 1),
                ),
                onPressed: clearImage,
              ),
        actions: file == null
            ? null
            : [
                FlatButton(
                  onPressed: isUploading ? null : () => handleSubmit(),
                  child: Text(
                    "Post",
                    style: TextStyle(
                      color: Color.fromRGBO(24, 115, 172, 1),
                      fontWeight: FontWeight.w400,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ],
      ), //boldy
      body: file == null
          ? LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
              return ListView(children: <Widget>[noImge()]);
            })
          : withImage(),
      bottomNavigationBar: Container(
        width: 0,
        height: 0,
      ),
    );

    ;
  }

  clearImage() {
    setState(() {
      file = null;
      height_upload = 0;
      width_upload = 0;
      postId = Uuid().v4();
    });
  }

//#
  compressImage(File filed) async {
    final snackBar = SnackBar(
      content: Text('Our Video is right on the way there!'),
      duration: Duration(seconds: 1000),
      backgroundColor: Color.fromRGBO(24, 115, 172, 1),
    );
    Scaffold.of(context).showSnackBar(snackBar);
    print("####################################3");
    print(filed.path);
    print("%^&^%#@#%^*U&^%");
    final File filex = await _flutterVideoCompress.convertVideoToGif(filed.path,
        startTime: 0, // default(0)
        duration: 3, // default(-1)
        endTime: -1 // default(-1)
        );
    Scaffold.of(context).hideCurrentSnackBar();
    setState(() {
      file = filed;
      file2 = filex;
    });
  }

//windowStopped(true) false io.flutter.embedding.android.FlutterSurfaceView{5344268
  Future<List<String>> uploadImage(File imageFile) async {
    print("Came here to print");
    String name = isPic ? "post_$postId.jpg" : "post_$postId.mp4";
    String thumbnail = "";
    File thumbFile;
    String thumbName = "";
    if (!isPic) {
      final File thumb =
          await _flutterVideoCompress.getThumbnailWithFile(imageFile.path,
              quality: 55, // default(100)
              position: -1 // default(-1)
              );
      var decodedImage = await decodeImageFromList(thumb.readAsBytesSync());
      print("bheki hawwa sa tha voh");
      print(decodedImage.width);
      print(decodedImage.height);
      height_upload = decodedImage.height;
      width_upload = decodedImage.width;
      final MediaInfo info = await _flutterVideoCompress.compressVideo(
        imageFile.path,
        deleteOrigin: true,
        quality: VideoQuality.HighestQuality,
      );
      thumbFile = thumb;
      imageFile = info.file;
      thumbName = "post_$postId.jpg";
    } else {
      var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
      print("milne hum ayenge tumko sajna");
      print(decodedImage.width);
      print(decodedImage.height);
      height_upload = decodedImage.height;
      width_upload = decodedImage.width;
    }
    if (thumbName != "") {
      StorageUploadTask uploadTask =
          storageRef.child(thumbName).putFile(thumbFile);
      StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
      thumbnail = await storageSnap.ref.getDownloadURL();
      print("New url");
      print(thumbnail);
    }
    print("tarka bhai tarak bhai");


    StorageUploadTask uploadTask = storageRef.child(name).putFile(imageFile);
    print("golanf");
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    print("bolla");
    String downloadUrl = await storageSnap.ref.getDownloadURL();

    print(downloadUrl);
    try{
      print(await storageRef.child(name).getDownloadURL());
      print("originalOne");
    }
    catch(e){
      print("bo bbbi bhai aha");
      print(e);
    }
//    imageFile.delete(recursive: true);

    // Directory tempdir= await getApplicationDocumentsDirectory();
    // print("hogai bhai hogai");
    // print(tempdir.path);
    // tempdir= await getApplicationSupportDirectory();
    // print("hogai bhai hogai");
    // print(tempdir.path);
    // tempdir= await getLibraryDirectory();
    // print("hogai bhai hogai");
    // print(tempdir.path);
    Directory tempdir =
        Directory((await getExternalStorageDirectory()).path + "/Pictures");
    print("hogai bhai hogai");
    print(tempdir.path);
    tempdir.deleteSync(recursive: true);
    tempdir.create();

    await _flutterVideoCompress.deleteAllCache();
    final snackBar = SnackBar(
      content: Text('Media Shared!'),
      duration: Duration(seconds: 2),
      backgroundColor: Color.fromRGBO(24, 115, 172, 1),
    );
    Scaffold.of(context).showSnackBar(snackBar);

    return [downloadUrl, thumbnail];
  }

  createPostInFirestore(
      {String mediaUrl, String thumb, String location, String description}) {
    print("hua bhi ya nhi");
    widget.postsRef
        .document(widget.user.uid)
        .collection("userPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "thumb": thumb,
      "ownerId": widget.user.uid,
      "username": widget.curruser.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": DateTime.now(),
      "likes": {},
      "height": height_upload,
      "width": width_upload
    });
    print("hogya");
  }

//$
  handleSubmit() async {
    setState(() {
      isUploading = true;
    });

    //await compressImage();
//yh hoga fir
    //yh hoga fir
    //yh hoga fir
    //yh hoga fir //yh hoga fir
    //yh hoga fir
    //yh hoga fir
    //yh hoga fir

    List<String> mediaUrl = await uploadImage(file);
    print(mediaUrl);
    createPostInFirestore(
      mediaUrl: mediaUrl[0],
      thumb: mediaUrl[1],
      location: locationController.text,
      description: captionController.text,
    );
    print("post is created");
    captionController.clear();
    locationController.clear();
    setState(() {
      height_upload = 0;
      width_upload = 0;
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  handleTakePhoto() async {
    isPic = true;
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    print("mitti");
    if (file == null) {
      return;
    }
    setState(() {
      this.file = file;
    });
    await cropImage();
  }

  handleTakeVideo() async {
    isPic = false;
    File filed = await ImagePicker.pickVideo(
      source: ImageSource.camera,
    );
    if (filed == null) {
      return;
    }
    await compressImage(filed);
//    setState(() {
//      this.file = file2;
//    });
  }

  handleTakeVideoFromLibrary() async {
    isPic = false;

    File filed = await ImagePicker.pickVideo(
      source: ImageSource.gallery,
    );
    if (filed == null) {
      return;
    }
    print("^^^^^^^^^^^^^^^^^^^^^^^^");
    print(filed.absolute);

    final String path =
        (await getExternalStorageDirectory()).path + "/Pictures";
    print("mega info");
    print(path);
    print(filed.path);
    final File newImage = await filed.copy("$path/xcv.mp4");
    await compressImage(newImage);
//    setState(() {
//      this.file = newImage;
//    });
  }

  handleChooseFromGallery() async {
    isPic = true;
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return;
    }
    setState(() {
      this.file = file;
    });
    await cropImage();
    //Navigator.pop(context);
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Text("Create Post"),
          actions: <Widget>[
            FlatButton(
                child: Text("Click with Camera"),
                onPressed: () {
                  Navigator.pop(context);
                  handleTakePhoto();
                }),
            FlatButton(
                child: Text("Record with Camera"),
                onPressed: () {
                  Navigator.pop(context);
                  handleTakeVideo();
                }),
            FlatButton(
                child: Text("Pick from Gallery"),
                onPressed: () {
                  Navigator.pop(context);
                  handleChooseFromGallery();
                }),
            FlatButton(
                child: Text("Pick from reel"),
                onPressed: () {
                  Navigator.pop(context);
                  handleTakeVideoFromLibrary();
                }),
            FlatButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.lightBlue),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Padding uploadItem() => Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          width: 200.0,
          height: 100.0,
          alignment: Alignment.center,
          child: RaisedButton.icon(
            label: Text(
              "Pick a story!",
              style: TextStyle(color: Colors.white),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            color: Color.fromRGBO(24, 115, 172, 1),
            onPressed: () => selectImage(context),
            icon: Icon(
              CupertinoIcons.fullscreen,
              color: Colors.white,
            ),
          ),
        ),
      );

  Padding revertItem() => Padding(
        padding: const EdgeInsets.all(12.0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
                icon: Icon(
                  CupertinoIcons.fullscreen_exit,
                  color: Colors.white,
                  size: 35,
                ),
                label: Text(
                  "Retake?",
                  style: TextStyle(
                      color: Colors.white, backgroundColor: Colors.blue),
                ),
                color: Colors.blue,
                onPressed: clearImage),
          ),
        ]),
      );

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    print(completeAddress);
    String formattedAddress =
        "${placemark.subThoroughfare} ${placemark.thoroughfare} ${placemark.subLocality}, ${placemark.locality}";
    locationController.text = formattedAddress.trim();
  }

  @override
  bool get wantKeepAlive {
    return true;
  }

  Future<Null> cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        compressQuality: 75,
        sourcePath: file.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Edit',
            toolbarColor: Color.fromRGBO(24, 115, 172, 1),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            activeControlsWidgetColor: Color.fromRGBO(24, 115, 172, 1),
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Edit',
        ));
    var decodedImage = await decodeImageFromList(croppedFile.readAsBytesSync());
    print("hora hai pyar sajna");
    print(decodedImage.width);
    print(decodedImage.height);
    if (croppedFile != null) {
      setState(() {
        // file.deleteSync(recursive: true);
        file = croppedFile;
      });
    }
  }
}
