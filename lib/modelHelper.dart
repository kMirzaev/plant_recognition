import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:plant_recognition/cure.dart';
import 'functionsAndVariables.dart';

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

  getImageFromCamera() async {
    // ignore: deprecated_member_use
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      imageURI = image;
      path = image.path;
    });
  }

  getImageFromGallery() async {
    // ignore: deprecated_member_use
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      imageURI = image;
      path = image.path;
    });
  }

  classifyImage() async {
    await Tflite.loadModel(
        model: "assets/model/converted_model.tflite",
        labels: "assets/model/labels.txt");
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Cure(diseaseName),
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
            if (imageURI != null)
              buildContainer(
                  classifyButtonText, classifyImage, classifyButtonIcon),
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Column(
                children: _recognitions == null
                    ? []
                    : _recognitions.map((res) {
                        diseaseName = res['label'].substring(3);
                        return Text(
                          "$diseaseName - ${(res["confidence"] * 100).toStringAsFixed(0)}%",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            backgroundColor: Colors.green.shade400,
                          ),
                        );
                      }).toList(),
              ),
            ),
            if (diseaseName != null)
              buildContainer(cureButtonText, handleCure, cureButtonIcon),
          ],
        ),
      ),
    );
  }
}
