import 'package:conecapp/common/helper.dart';

class ProfileResponse {
  bool status;
  String error;
  Profile profile;

  ProfileResponse({this.status, this.error, this.profile});

  ProfileResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if(json['error']!=null){
      error = json['error'];
    }
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
    name = json['name'] == null ? null : json['name'];
    email = json['email'] == null ? null : json['email'];
    avatar = json['avatar'] == null ? null : Helper.baseURL + json['avatar'];
    gender = json['gender'] == null ? null : json['gender'];
    dob = json['dob'] == null ? null : Helper.formatDob(json['dob']);
    phoneNumber = json['phoneNumber'] == null ? null : json['phoneNumber'];
    type = json['type'] == null ? null : json['type'];
    province = json['province'] == null ? null : json['province'];
    district = json['district'] == null ? null : json['district'];
    ward = json['ward'] == null ? null : json['ward'];
    address = json['address'] == null ? null : json['address'];
    lat = json['lat'] == null ? null : json['lat'];
    lng = json['lng'] == null ? null : json['lng'];
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