import 'package:cached_network_image/cached_network_image.dart';
import 'package:dodogy_challange/widgets/progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//mainPhotoWidget
Widget cachedNetworkImage(String mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl ?? "https://www.asjfkfhdgihdknjskdjfeid.com",
    fit: BoxFit.cover,
    placeholder: (context, url) => circularProgress(),
    errorWidget: (context, url, error) => Icon(Icons.error,size:32),
  );
}
//for activity feed
Widget cachedNetworkImageLead(
    BuildContext context, String mediaUrl, String thumb) {
  bool vid = mediaUrl.toLowerCase().contains(".mp4");
  return vid
      ? videoBurrowCustom(context, thumbUrl: thumb)
      : CachedNetworkImage(
          imageUrl: mediaUrl ?? "https://www.asjfkfhdgihdknjskdjfeid.com",
          fit: BoxFit.cover,
          placeholder: (context, url) => Padding(
                child: CircularProgressIndicator(),
                padding: EdgeInsets.all(7.0),
              ),
          errorWidget: (context, url, error) => Padding(
                padding: EdgeInsets.all(12),
                child: Icon(CupertinoIcons.video_camera_solid),
              ));
}

Widget videoBurrowCustom(BuildContext context,
    {String thumbUrl = "", double h}) {
  return SizedBox(
    height: 50,
    width: 50,
    child: Container(
      child: Stack(
        fit: StackFit.passthrough,
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
                            fit: BoxFit.cover,
                            // height: h,
                          )),
                      errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(color: Colors.black54)),
                      placeholder: (context, url) => Container(
                          decoration: BoxDecoration(color: Colors.black54))),
                )))
              : Container(decoration: BoxDecoration(color: Colors.black54)),
          Positioned(
              child: Icon(
            CupertinoIcons.play,
            color: Colors.white70,
            size: 28,
          ))
        ],
      ),
    ),
  );
}


//Widget kheechMeriPhoto
// Widget profileImage(double height, String url, {bool light = true}) {
//   Color borderC = light
//       ? Color.fromRGBO(222, 253, 255, 1)
//       : Color.fromRGBO(24, 115, 172, 1);
//   if (url != "" && url != null) {
//     return FutureBuilder(
//       builder: (context, snapshot) {
//         if (!snapshot.hasData){
//           return SizedBox(height: height,width: height );
//         }
//         return widget;
//       },
//       future: currentFUser.getIdToken(),
//     );
//   }
//   return loader;
// }

