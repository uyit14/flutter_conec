import 'package:conecapp/common/helper.dart';

class NearByClubResponse {
  List<Clubs> clubs;

  NearByClubResponse({this.clubs});

  NearByClubResponse.fromJson(Map<String, dynamic> json) {
    if (json['clubs'] != null) {
      clubs = new List<Clubs>();
      json['clubs'].forEach((v) {
        clubs.add(new Clubs.fromJson(v));
      });
    }
  }
}

class Clubs {
  String id;
  String name;
  String avatar;
  String getAddress;
  num lat;
  num lng;
  int ratingCount;
  num ratingAvg;
  String ratingHtml;
  String joinedDate;
  String type;
  String dob;
  String gender;
  String phoneNumber;
  String email;

  Clubs(
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

  Clubs.fromJson(Map<String, dynamic> json) {
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