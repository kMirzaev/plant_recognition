import 'dart:io';
import 'package:flutter/material.dart';

File imageURI;
String result;
String path;
String diseaseName;
String firstDisease;
String cameraButtonText = 'Click Here To Select Image From Camera';
Icon cameraButtonIcon = Icon(Icons.camera);
String galleryButtonText = 'Click Here To Select Image From Gallery';
Icon galleryButtonIcon = Icon(Icons.image);
String classifyButtonText = 'Classify Image';
Icon classifyButtonIcon = Icon(Icons.book);
String cureButtonText = 'Cure';
Icon cureButtonIcon = Icon(Icons.bolt);

Container buildContainer(String buttonText, Function buttonAction,
    Icon buttonIcon) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
    child: RaisedButton.icon(
      onPressed: () {
        buttonAction();
      },
      label: Text(buttonText),
      textColor: Colors.white,
      color: Colors.teal,
      icon: buttonIcon,
      padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
      shape:
          RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
      elevation: 5.0,
    ),
  );
}
