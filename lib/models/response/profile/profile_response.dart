import 'package:conecapp/common/helper.dart';

class ProfileResponse {
  bool status;
  String error;
  Profile profile;

  ProfileResponse({this.status, this.error, this.profile});

  ProfileResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    profile =
    json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['error'] = this.error;
    if (this.profile != null) {
      data['profile'] = this.profile.toJson();
    }
    return data;
  }
}

class Profile {
  String name;
  String email;
  String avatar;
  String gender;
  String dob;
  String phoneNumber;
  String type;
  String province;
  String district;
  String ward;
  String address;
  double lat;
  double lng;

  Profile(
      {this.name,
        this.email,
        this.avatar,
        this.gender,
        this.dob,
        this.phoneNumber,
        this.type,
        this.province,
        this.district,
        this.ward,
        this.address,
        this.lat,
        this.lng});

  Profile.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    avatar = Helper.baseURL + json['avatar'];
    gender = json['gender'];
    dob = json['dob'];
    phoneNumber = json['phoneNumber'];
    type = json['type'];
    province = json['province'];
    district = json['district'];
    ward = json['ward'];
    address = json['address'];
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['avatar'] = this.avatar;
    data['gender'] = this.gender;
    data['dob'] = this.dob;
    data['phoneNumber'] = this.phoneNumber;
    data['type'] = this.type;
    data['province'] = this.province;
    data['district'] = this.district;
    data['ward'] = this.ward;
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
  }
}