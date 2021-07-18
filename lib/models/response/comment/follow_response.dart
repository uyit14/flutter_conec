import 'package:conecapp/common/helper.dart';

class FollowResponse {
  bool status;
  List<Follower> followers;

  FollowResponse({this.status, this.followers});

  FollowResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['datas'] != null) {
      followers = new List<Follower>();
      json['datas'].forEach((v) {
        followers.add(new Follower.fromJson(v));
      });
    }
  }
}

class Follower {
  String id;
  String owner;
  String avatar;

  Follower({this.id, this.owner, this.avatar});

  Follower.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    owner = json['owner'];
    avatar = json['avatar'] !=null && !json['avatar'].contains("http") ? Helper.baseURL + json['avatar'] : json['avatar'];
  }
}