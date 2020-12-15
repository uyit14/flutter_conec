import 'package:conecapp/common/helper.dart';

import 'latest_item.dart';

class NearbyResponse {
  Data data;

  NearbyResponse({this.data});

  NearbyResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }
}

class Data {
  List<Users> users;
  List<Trainer> trainers;
  List<LatestItem> userPosts;
  List<LatestItem> trainerPosts;

  Data({this.users, this.trainers});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['users'] != null) {
      users = new List<Users>();
      json['users'].forEach((v) {
        users.add(new Users.fromJson(v));
      });
    }
    if (json['trainers'] != null) {
      trainers = new List<Trainer>();
      json['trainers'].forEach((v) {
        trainers.add(new Trainer.fromJson(v));
      });
    }
    if(json['userPosts'] != null){
      userPosts = new List<LatestItem>();
      json['userPosts'].forEach((v) {
        userPosts.add(new LatestItem.fromJson(v));
      });
    }
    if(json['trainerPosts'] != null){
      trainerPosts = new List<LatestItem>();
      json['trainerPosts'].forEach((v) {
        trainerPosts.add(new LatestItem.fromJson(v));
      });
    }
  }
}

class Users {
  String id;
  String name;
  String avatar;
  String getAddress;
  num lat;
  num lng;
  num ratingCount;
  num ratingAvg;
  String ratingHtml;
  String joinedDate;
  String type;
  String dob;
  String gender;
  String phoneNumber;
  String email;
  num distance;

  Users(
      {this.id,
        this.name,
        this.avatar,
        this.getAddress,
        this.lat,
        this.lng,
        this.ratingCount,
        this.ratingAvg,
        this.ratingHtml,
        this.joinedDate,
        this.type,
        this.dob,
        this.gender,
        this.phoneNumber,
        this.email, this.distance});

  Users.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    avatar = json['avatar']!=null && !json['avatar'].contains("http") ? Helper.baseURL + json['avatar'] : json['avatar'];
    getAddress = json['getAddress'];
    lat = json['lat'];
    lng = json['lng'];
    ratingCount = json['ratingCount'];
    ratingAvg = json['ratingAvg'];
    ratingHtml = json['rating_Html'];
    joinedDate = json['joinedDate'];
    type = json['type'];
    dob = json['dob'];
    gender = json['gender'];
    phoneNumber = json['phoneNumber'];
    email = json['email'];
    distance = json['distance'];
  }
}

class Trainer {
  String id;
  String name;
  String avatar;
  String getAddress;
  num lat;
  num lng;
  num ratingCount;
  num ratingAvg;
  String ratingHtml;
  String joinedDate;
  String type;
  String dob;
  String gender;
  String phoneNumber;
  String email;
  num distance;

  Trainer(
      {this.id,
        this.name,
        this.avatar,
        this.getAddress,
        this.lat,
        this.lng,
        this.ratingCount,
        this.ratingAvg,
        this.ratingHtml,
        this.joinedDate,
        this.type,
        this.dob,
        this.gender,
        this.phoneNumber,
        this.email, this.distance});

  Trainer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    avatar = json['avatar']!=null && !json['avatar'].contains("http") ? Helper.baseURL + json['avatar'] : json['avatar'];
    getAddress = json['getAddress'];
    lat = json['lat'];
    lng = json['lng'];
    ratingCount = json['ratingCount'];
    ratingAvg = json['ratingAvg'];
    ratingHtml = json['rating_Html'];
    joinedDate = json['joinedDate'];
    type = json['type'];
    dob = json['dob'];
    gender = json['gender'];
    phoneNumber = json['phoneNumber'];
    email = json['email'];
    distance = json['distance'];
  }
}