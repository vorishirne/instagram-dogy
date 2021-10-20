import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'homyz.dart';

class MediaInteract {
  final FlutterVideoCompress flutterVideoCompress = FlutterVideoCompress();
  final TextEditingController captionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  bool uploading=false;
  bool onGoing=false;
  int meter = 0;
  bool isPic = true;
  File mediaFile;
  File thumbnailFile;
  String thumbUrl = "";
  String mediaUrl = "";

  int heightH = 0;
  int widthW = 0;

  final BuildContext context;
  String titel;

  MediaInteract(this.context, this.titel);

  dial(String number) async {
    switch (number) {
      case "pc":
        return (await handleTakePhoto());
      case "vc":
        return (await handleTakeVideo());
      case "pg":
        return (await handleChooseFromGallery());
      case "vg":
        return (await handleTakeVideoFromLibrary());
      case "na":
        return;
    }
  }

  selectImageVideo(BuildContext parentContext, String what) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Text(titel),
          actions: <Widget>[
            Visibility(
              visible: ["pic", "both"].contains(what),
              child: FlatButton(
                  child: Text("Click with Camera"),
                  onPressed: () {
                    Navigator.pop(context, "pc");
                  }),
            ),
            Visibility(
                visible: ["vid", "both"].contains(what),
                child: FlatButton(
                    child: Text("Record with Camera"),
                    onPressed: () {
                      Navigator.pop(context, "vc");
                    })),
            Visibility(
                visible: ["pic", "both"].contains(what),
                child: FlatButton(
                    child: Text("Pick from Gallery"),
                    onPressed: () {
                      Navigator.pop(context, "pg");
                    })),
            Visibility(
                visible: ["vid", "both"].contains(what),
                child: FlatButton(
                    child: Text("Pick from reel"),
                    onPressed: () {
                      Navigator.pop(context, "vg");
                    })),
            FlatButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.lightBlue),
              ),
              onPressed: () => Navigator.pop(context, "na"),
            )
          ],
        );
      },
    );
  }

  Future handleTakePhoto() async {
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    if (file == null) {
      return;
    } else {
      isPic = true;
    }
    print("got the photo");
    (await cropImage(file));

    print("murthal");
  }

  Future handleTakeVideo() async {
    File file = await ImagePicker.pickVideo(
      source: ImageSource.camera,
    );
    if (file == null) {
      return;
    } else {
      isPic = false;
    }
    mediaFile = file;
    await getThumbnail();
    print("misss india");
  }

  Future handleTakeVideoFromLibrary() async {
    File file = await ImagePicker.pickVideo(
      source: ImageSource.gallery,
    );
    if (file == null) {
      print("gori");
      return;
    } else {
      isPic = false;
    }
    final String path =
        (await getExternalStorageDirectory()).path + "/Pictures";
    file = await file.copy("$path/xcv.mp4");
    mediaFile = file;
    await getThumbnail();
  }

  Future handleChooseFromGallery() async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return;
    } else {
      isPic = true;
    }
    await cropImage(file);
    print("badtameez");
  }

  getThumbnail() async {
    thumbnailFile =
        await flutterVideoCompress.getThumbnailWithFile(mediaFile.path,
            quality: 35, // default(100)
            position: -1 // default(-1)
            );
    var decodedImage =
        await decodeImageFromList(thumbnailFile.readAsBytesSync());
    heightH = decodedImage.height;
    widthW = decodedImage.width;
  }

  Future<Null> cropImage(File file) async {
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
    mediaFile = croppedFile;
    print("meet the cropped version");
    var decodedImage = await decodeImageFromList(mediaFile.readAsBytesSync());
    heightH = decodedImage.height;
    widthW = decodedImage.width;
  }

  uploadPic(String mediaid) async {
    if (mediaFile == null) {
      init();
      return;
    }
    StorageUploadTask uploadTask =
        storageRef.child(mediaid + ".jpg").putFile(mediaFile);
    print("golanf");
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    print("bolla");
    Directory tempdir =
        Directory((await getExternalStorageDirectory()).path + "/Pictures");
    tempdir.deleteSync(recursive: true);
    tempdir.create();
    mediaUrl = (await storageSnap.ref.getDownloadURL());
  }

  uploadVid(String mediaid) async {
    if (thumbnailFile == null || mediaFile == null) {
      init();
      return;
    }
    StorageUploadTask uploadTask =
        storageRef.child(mediaid + "thumb.jpg").putFile(thumbnailFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    thumbUrl = await storageSnap.ref.getDownloadURL();

    mediaFile = (await flutterVideoCompress.compressVideo(
      mediaFile.path,
      deleteOrigin: true,
      quality: VideoQuality.HighestQuality,
    ))
        .file;

    StorageUploadTask uploadTaskV =
        storageRef.child(mediaid + ".mp4").putFile(mediaFile);
    StorageTaskSnapshot storageSnapV = await uploadTaskV.onComplete;
    mediaUrl = await storageSnapV.ref.getDownloadURL();

    await flutterVideoCompress.deleteAllCache();
  }

  init() {
    mediaFile = null;
    mediaUrl = "";
    thumbnailFile = null;
    thumbUrl = "";
    heightH = 0;
    widthW = 0;
    onGoing=false;
    uploading=false;
  }
}
