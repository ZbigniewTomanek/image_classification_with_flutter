import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' show basename;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class PhotoWithDescription extends StatefulWidget {
  PhotoWithDescription({this.photo, this.delete});

  final DescribedPhoto photo;
  final Function delete;

  @override
  State createState() {
    return _PhotoWithDescriptionState(photo: photo, delete: delete);
  }
}
class _PhotoWithDescriptionState extends State<PhotoWithDescription> {
  _PhotoWithDescriptionState({this.photo, this.delete});

  final DescribedPhoto photo;
  final Function delete;

  void _showPhoto() {
    final title = '${photo.descriptions[0].toUpperCase()} (?)';
    final description = photo.descriptions.join(', ');

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body:
                Center(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Image.network(photo.url),
                      ),
                      Text(
                        'This photo might contain:',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Divider(),
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(18.0),
                          child: Text(
                            description,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          );
        },
      ),
    );
  }


    @override
    Widget build(BuildContext context) {
      return
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InkWell(
                onTap: _showPhoto,
                child: Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(backgroundImage: NetworkImage(photo.url)),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(photo.descriptions[0], style: Theme.of(context).textTheme.subhead,),
                    Container(
                      margin: const EdgeInsets.only(top: 5.0),
                      child: Text(photo.descriptions.sublist(1).join(', ')),
                    )
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => delete(photo),
              ),
            ],

          ),
      );
    }

}

enum PhotoDialogAnswers{CAMERA, STORAGE}
class _MyHomePageState extends State<MyHomePage> {

  final _restService = RestService();
  final _fileManager = FileManager();

  var _photos = <PhotoWithDescription>[];
  GlobalKey<ScaffoldState> _key = GlobalKey();

  Future _addPhoto() async {
    switch (
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Add photo from:'),
            children: <Widget>[
              SimpleDialogOption(
                child: ListTile(
                  title: Text('Camera'),
                  leading: Icon(Icons.camera),
                ),
                onPressed: () => Navigator.pop(context, PhotoDialogAnswers.CAMERA),
              ),
              SimpleDialogOption(
                child: ListTile(
                  title: Text('Gallery'),
                  leading: Icon(Icons.photo),
                ),
                onPressed: () => Navigator.pop(context, PhotoDialogAnswers.STORAGE),
              ),
            ],
          );
        })
    ) {
      case PhotoDialogAnswers.STORAGE:
        _classifyPhoto(ImageSource.gallery);
        break;

      case PhotoDialogAnswers.CAMERA:
        _classifyPhoto(ImageSource.camera);
        break;
    }
  }

  Future<File> _loadPhoto(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    return image;
  }

  // Uploads photo to the storage and returns photos url
  Future<List<String>> _uploadPhoto(File image) async {
    final fileName = basename(image.path);
    final storageRef = FirebaseStorage.instance.ref().child(fileName);

    //show loading animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Container(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text('Working...',
                      textAlign: TextAlign.center,))
                ],
        ),
            ),
          ],
        );
      }
    );

    final uploadTask = storageRef.putFile(image);
    final taskSnapshot = await uploadTask.onComplete;
    final url = await storageRef.getDownloadURL();

    setState(() {
      //show snackbar via gloablkey
      _key.currentState.showSnackBar(SnackBar(content: Text('File uploaded')));
      _key.currentState.showSnackBar(SnackBar(content: Text('File uploaded')));
    });

    return [fileName, url];
  }

  Future<void> showErrorDialog(String title, String message) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void _classifyPhoto(ImageSource source) async {
    final file = await _loadPhoto(source);

    if (file == null) {
      showErrorDialog("Error", "Can't load photo");
      return;
    } else {

      try {
        final data = await _uploadPhoto(file);
        DescribedPhoto describedPhoto = await _restService.classifyPhoto(data[0], data[1]);


        setState(() {
          //dismiss loading dialog
          Navigator.pop(context);
          _key.currentState.hideCurrentSnackBar();
          _key.currentState.showSnackBar(SnackBar(content: Text('Photo was classified')));

          final photo = PhotoWithDescription(photo: describedPhoto, delete: _delete,);


          //push classified photo on screen
          _photos.add(photo);
          _savePhotos();
        });
      }
      catch(e){

        setState(() {
          Navigator.pop(context);
        });

        showErrorDialog("Error", "Cannot process this photo :c");
      }
    }
  }

  //callback function that permanently deletes record
  void _delete(DescribedPhoto dp) {
    setState(() {
      _photos.removeWhere((p) => (p.photo == dp));
    });

    _savePhotos();
  }

  void _loadPhotos() async {
    var data = await _fileManager.loadPhotos();

    setState(() {
      _photos = data.map((dp) => PhotoWithDescription(photo: dp, delete: _delete,)).toList();
    });
  }

  void _savePhotos() async {
    print('Saving list');
    final data = _photos.map((p) => p.photo).toList();
    final f = await _fileManager.savePhotos(data);
  }

  var _firstStart = true;

  @override
  Widget build(BuildContext context) {

    if (_firstStart) {
      _firstStart = false;
      _loadPhotos();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Image Recognition'),
      ),
      key: _key,
      body: Container(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemBuilder: (_, int index) => _photos[index],
                itemCount: _photos.length,
              ),
            ),
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPhoto,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
