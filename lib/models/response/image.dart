import 'package:conecapp/common/helper.dart';

class Image {
  String id;
  String fileName;
  String created;

  Image({this.id, this.fileName, this.created});

  Image.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fileName = json['fileName'] !=null && !json['fileName'].contains("http") ? Helper.baseURL + json['fileName'] : json['fileName'];
    created = json['created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['fileName'] = this.fileName;
    data['created'] = this.created;
    return data;
  }
}
