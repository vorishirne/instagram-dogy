import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:dodogy_challange/widgets/progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget cachedNetworkImage(String mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl ??
        "https://www.asjfkfhdgihdknjskdjfeid.com",
    fit: BoxFit.cover,
    placeholder: (context, url) => Padding(
      child: circularProgress(),//Container(height: 200, color: Colors.black12,child: SizedBox(height: 200,),),
      padding: EdgeInsets.symmetric(vertical:200.0),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}

Widget cachedPostNetworkImage(String mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl??
        "https://www.asjfkfhdgihdknjskdjfeid.com",
    fit: BoxFit.cover,
    placeholder: (context, url) => Padding(
      child: CircularProgressIndicator(),
      padding: EdgeInsets.all(80.0),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}

Widget cachedNetworkImageLead(String mediaUrl) {
  bool vid = mediaUrl.toLowerCase().contains(".mp4");
  return vid? VideoItem(mediaUrl) : CachedNetworkImage(
    imageUrl: mediaUrl ??
        "https://www.asjfkfhdgihdknjskdjfeid.com",
    fit: BoxFit.cover,
    placeholder: (context, url) => Padding(
      child: CircularProgressIndicator(),
      padding: EdgeInsets.all(7.0),
    ),
    errorWidget: (context, url, error) => Padding(padding: EdgeInsets.all(12),child:Icon(CupertinoIcons.video_camera_solid),
  ));
}



class VideoItem extends StatefulWidget{
  final String url;
  VideoItem(String this.url);
  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});  //when your thumbnail will show.
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.initialized
        ? Container(

      child: VideoPlayer(_controller),
    )
        : CircularProgressIndicator();

  }
}
