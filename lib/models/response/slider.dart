import 'package:conecapp/common/helper.dart';

class Slider {
  String id;
  String title;
  String description;
  int orderNo;
  String thumbnail;

  Slider({this.id, this.title, this.description, this.orderNo, this.thumbnail});
  Slider.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    orderNo = json['orderNo'];
    thumbnail = Helper.baseURL + json['thumbnail'];
  }
}
