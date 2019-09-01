import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiver/core.dart';


part 'service.g.dart';

const URL = "http://192.168.0.50:5000"; //address and port of server with REST
const FILE_PATH = 'list.txt'; //name of the file with list of saved photos

@JsonSerializable()
class DescribedPhoto {
  DescribedPhoto({this.name, this.url, this.descriptions});

  String name;
  String url;
  List<String> descriptions;

  factory DescribedPhoto.fromJson(Map<String, dynamic> json) => _$DescribedPhotoFromJson(json);
  Map<String, dynamic> toJson() => _$DescribedPhotoToJson(this);

  @override
  String toString() {
    return 'name: $name, url: $url, descriptions: $descriptions';
  }

  @override bool operator ==(o) {
    return o is DescribedPhoto && o.name == name
        && o.url == url && o.descriptions.toString() == descriptions.toString();
  }

  @override
  int get hashCode => hash3(name.hashCode, url.hashCode, descriptions.hashCode);
}

class RestService {

  Future<DescribedPhoto> classifyPhoto(String photoName, String photoURL) async {
    final url = '$URL/classify';
    Map<String, dynamic> body = {'name': photoName, 'url': photoURL};

    return http.post(url, body: body).then((http.Response response) {
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        print(statusCode);
        throw new Exception("Error while fetching data");
      }
      return DescribedPhoto.fromJson(json.decode(response.body));
    });
  }

}

class FileManager {


  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$FILE_PATH');
  }

  Future<File> savePhotos(List<DescribedPhoto> photos) async {
    final file = await _localFile;

    print(photos.map((photo) => photo.toJson()));
    List<Map<String, dynamic>> jsonList = (photos.map((photo) => photo.toJson())).toList();
    String jsonString = jsonEncode({'list': jsonList});


    return file.writeAsString(jsonString);
  }

  Future<List<DescribedPhoto>> loadPhotos() async {
    final file = await _localFile;

    try {
      String content = await file.readAsString();
      final list = jsonDecode(content);
      List<Map<String, dynamic>> photosList = list['list'].cast<Map<String, dynamic>>();
      List<DescribedPhoto> photos = photosList.map((m) => DescribedPhoto.fromJson(m)).toList();
      print(photos);

      return photos;
    }
    catch(e) {
        print(e);
        return [];
    }
  }

}



