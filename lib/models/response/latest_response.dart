import 'package:conecapp/models/response/latest_item.dart';

class LatestResponse {
  List<LatestItem> items;

  LatestResponse(this.items);

  LatestResponse.fromJson(Map<String, dynamic> json) {
    if (json['posts'] != null) {
      items = new List<LatestItem>();
      json['posts'].forEach((v) {
        items.add(new LatestItem.fromJson(v));
      });
    }
  }

}