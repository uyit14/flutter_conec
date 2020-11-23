import 'package:conecapp/common/helper.dart';

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
  int ratingAvg;
  String ratingHtml;
  String joinedDate;
  String type;
  String dob;
  String gender;
  String phoneNumber;
  String email;

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
        this.email});

  Users.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    avatar = json['avatar']!=null ? Helper.baseURL + json['avatar'] : json['avatar'];
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
  int ratingAvg;
  String ratingHtml;
  String joinedDate;
  String type;
  String dob;
  String gender;
  String phoneNumber;
  String email;

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
        this.email});

  Trainer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    avatar = json['avatar']!=null ? Helper.baseURL + json['avatar'] : json['avatar'];
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
  }
}