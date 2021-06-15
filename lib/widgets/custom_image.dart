import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget cachedNetworkImage(String mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl ??
        "https://www.asjfkfhdgihdknjskdjfeid.com",
    fit: BoxFit.cover,
    placeholder: (context, url) => Padding(
      child: CircularProgressIndicator(),
      padding: EdgeInsets.all(20.0),
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
  return CachedNetworkImage(
    imageUrl: mediaUrl ??
        "https://www.asjfkfhdgihdknjskdjfeid.com",
    fit: BoxFit.cover,
    placeholder: (context, url) => Padding(
      child: CircularProgressIndicator(),
      padding: EdgeInsets.all(7.0),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}