import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:plant_recognition/cure.dart';
import 'functionsAndVariables.dart';
import 'package:flutter_native_image/flutter_native_image.dart';


class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyImagePickerState createState() => new _MyImagePickerState();
}

class _MyImagePickerState extends State {
  List _recognitions;
  bool classifyButtonVisibility = false;
  bool diseaseLabelVisibility = false;
  bool cureButtonVisibility = false;

  getImageFromCamera() async {
    // ignore: deprecated_member_use
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    File compressedFile = await FlutterNativeImage.compressImage(image.path, quality: 80,
        targetWidth: 256, targetHeight: 256);


    setState(() {
      imageURI = compressedFile;
      path = compressedFile.path;
      classifyButtonVisibility = true;
      diseaseLabelVisibility = false;
      cureButtonVisibility = false;
    });
  }

  getImageFromGallery() async {
    // ignore: deprecated_member_use
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    File compressedFile = await FlutterNativeImage.compressImage(image.path, quality: 80,
        targetWidth: 256, targetHeight: 256);

    setState(() {
      imageURI = compressedFile;
      path = compressedFile.path;
      classifyButtonVisibility = true;
      diseaseLabelVisibility = false;
      cureButtonVisibility = false;
    });
  }

  classifyImage() async {
    await Tflite.loadModel(
        model: "assets/model/converted_modelv01.tflite",
        labels: "assets/model/labels.txt");
    var output = await Tflite.runModelOnImage(
        path: path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 3,
        threshold: 0.2,
        asynch: true);
    setState(() {
      _recognitions = output;
      classifyButtonVisibility = false;
      diseaseLabelVisibility = true;
      cureButtonVisibility = true;
    });
  }



  handleCure() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Cure(firstDisease),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Recognize sick plant"),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            imageURI == null
                ? Text('No image selected.')
                : Image.file(imageURI,
                    width: 300, height: 200, fit: BoxFit.cover),
            buildContainer(
                cameraButtonText, getImageFromCamera, cameraButtonIcon),
            buildContainer(
                galleryButtonText, getImageFromGallery, galleryButtonIcon),
            Visibility(
              child: buildContainer(
                  classifyButtonText, classifyImage, classifyButtonIcon),
              visible: classifyButtonVisibility,
            ),
            Visibility(
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Column(
                  children: _recognitions == null
                      ? []
                      : _recognitions.map((res) {
                          diseaseName = res['label'];
                          var split = diseaseName.split(' ');
                          diseaseName = split.skip(1).join(' ');

                         firstDisease = _recognitions.first['label'];
                          var split2 = firstDisease.split(' ');
                          firstDisease = split2.skip(1).join(' ');
                          return Text(
                            "$diseaseName - ${(res["confidence"] * 100).toStringAsFixed(0)}%",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.combine([
                                TextDecoration.underline,
                                TextDecoration.overline
                              ]),
                              decorationThickness: 2.0,
                              decorationColor: Colors.lightGreen,
                              decorationStyle: TextDecorationStyle.dashed,
                            ),
                          );
                        }).toList(),
                ),
              ),
              visible: diseaseLabelVisibility,
            ),
            Visibility(
              child: buildContainer(cureButtonText, handleCure, cureButtonIcon),
              visible: cureButtonVisibility,
            ),
          ],
        ),
      ),
    );
  }
}
