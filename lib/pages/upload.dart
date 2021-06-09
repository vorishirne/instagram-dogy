import 'dart:io';
import 'package:dodogy_challange/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as Im;
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
  bool isPic = true;
  bool isUploading = false;
  String postId = Uuid().v4();

  Widget mainOptions() {
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
              errorWidget: (context, url, error) =>
                  new Icon(CupertinoIcons.person_solid)),
          title: Container(
            width: 250.0,
            child: TextField(
              controller: captionController,
              decoration: InputDecoration(
                hintText: "Write a caption...",
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
                hintText: "Where was this photo taken?",
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
                  hintStyle: TextStyle(color: Colors.white),
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
                  hintStyle: TextStyle(color: Colors.white),
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
            padding: const EdgeInsets.only(left: 28.0,bottom: 28,top:8),
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
    return
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            uploadItem(),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
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
                ): Container(width: 0.0, height: 0.0)
              ],
            )
          ],

    );
  }



  Widget withImage() {
    print("is pic");
    print(isPic);
    return
        Container(
          decoration: BoxDecoration(
              //AssetImage("assets/images/source.gif",)
              image: DecorationImage(image: isPic ? FileImage(file) : Image.file(file2).image, fit: BoxFit.cover)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  children: <Widget>[
                    bottomOptions(),
                    isUploading ? linearProgress() : Container(width: 0.0, height: 0.0),

                  ],
                ),
              ),
            ],
          ),
        )
      ;
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
            actions:file == null
                ? null
                :  [
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
          ),
          body: file == null ? noImge() : withImage(),
bottomNavigationBar: Container(width: 0,height: 0,),
        );


    ;
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }
//#
  compressImage(File filed) async {
    final snackBar = SnackBar(content: Text('Yay! Your Video is right on the way there!'),duration: Duration(seconds: 1000),backgroundColor: Color.fromRGBO(24, 115, 172, 1),);
    Scaffold.of(context).showSnackBar(snackBar);
    print("####################################3");
    print(filed.path);
    print("%^&^%#@#%^*U&^%");
    final File filex = await _flutterVideoCompress.convertVideoToGif(
      filed.path,
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
  Future<String> uploadImage(imageFile) async {
    String name = isPic ? "post_$postId.jpg" : "post_$postId.mp4";
    if (!isPic){

      final MediaInfo info = await _flutterVideoCompress.compressVideo(
        imageFile.path,
        deleteOrigin: false,
        quality: VideoQuality.HighestQuality,
      );
      imageFile = info.file;
    }
    StorageUploadTask uploadTask =
        storageRef.child(name).putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    print(downloadUrl);
    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl, String location, String description}) {
    widget.postsRef
        .document(widget.user.uid)
        .collection("userPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.user.uid,
      "username": widget.curruser.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": DateTime.now(),
      "likes": {},
    });
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

    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
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
    print("^^^^^^^^^^^^^^^^^^^^^^^^");
    print(filed.absolute);

    final String path = (await getApplicationDocumentsDirectory()).path;
    final File newImage = await filed.copy("$path/xcv.mp4");
    await compressImage(newImage);
//    setState(() {
//      this.file = newImage;
//    });


  }

  handleChooseFromGallery() async {
    isPic = true;
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);

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
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 200.0,
          height: 100.0,
          alignment: Alignment.center,
          child: RaisedButton.icon(
            label: Text(
              "Pick a pic!",
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
    String formattedAddress = "${placemark.locality}, ${placemark.country}";
    locationController.text = formattedAddress;
  }

  @override
  bool get wantKeepAlive {
    return true;
  }

  Future<Null> cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
      compressQuality: 65,
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
    if (croppedFile != null) {

      setState(() {
        file= croppedFile;
      });
    }
  }

}
