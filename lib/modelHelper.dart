import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:plant_recognition/cure.dart';


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
  File imageURI;
  String result;
  String path;
  List _recognitions;
  String diseaseName;

  Future getImageFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      imageURI = image;
      path = image.path;
    });
  }

  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      imageURI = image;
      path = image.path;
    });
  }

  Future classifyImage() async {
    await Tflite.loadModel(
        model: "assets/model/model_unquant.tflite", labels: "assets/model/labels.txt");
    var output = await Tflite.runModelOnImage(
      path: path,
      numResults: 1,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _recognitions = output;
    });
  }

  handleCure() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Cure(diseaseName),
    ));
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
            Container(
                margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
                child: RaisedButton(
                  onPressed: () => getImageFromCamera(),
                  child: Text('Click Here To Select Image From Camera'),
                  textColor: Colors.white,
                  color: Colors.teal,
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                )),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: RaisedButton(
                onPressed: () => getImageFromGallery(),
                child: Text('Click Here To Select Image From Gallery'),
                textColor: Colors.white,
                color: Colors.teal,
                padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
              ),
            ),
            if (imageURI != null)
              Container(
                margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
                child: RaisedButton(
                  onPressed: () => classifyImage(),
                  child: Text('Classify Image'),
                  textColor: Colors.white,
                  color: Colors.teal,
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                ),
              ),
            Container(
              child: Column(
                children: _recognitions == null
                    ? []
                    : _recognitions.map((res) {
                  diseaseName = res['label'].substring(3);
                  return Text(
                    "$diseaseName - ${(res["confidence"] * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      backgroundColor: Colors.green.shade400,
                    ),
                  );
                }).toList(),
              ),
            ),
            if (diseaseName != null)
              Container(
                child: RaisedButton(
                  onPressed: handleCure,
                  child: Text("Cure"),
                  textColor: Colors.white,
                  color: Colors.teal,
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
