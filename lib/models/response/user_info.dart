import 'package:flutter/foundation.dart';

class UserInfo {
  String userId;
  String userName;
  String gender;
  String birthDay;
  String city;
  String district;
  String ward;
  String address;
  String phone;
  String email;

  UserInfo(
      {@required this.userId,
      @required this.userName,
      this.gender = "",
      this.birthDay = "",
      @required this.city,
      @required this.district,
      @required this.ward,
      @required this.address,
      @required this.phone,
      @required this.email});
}
