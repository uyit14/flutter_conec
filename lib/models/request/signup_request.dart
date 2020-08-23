import 'package:flutter/foundation.dart';

class SignUpRequest {
  String name;
  String birthDay;
  String gender;
  String phone;
  String passWord;
  String confirmPassword;
  String email;
  String city;
  String district;
  String ward;
  String address;
  SignUpRequest();

  SignUpRequest.person(
      {@required this.name,
      this.birthDay,
      this.gender,
      @required this.phone,
      @required this.passWord,
      @required this.confirmPassword,
      this.email,
      this.city,
      this.district,
      this.ward,
      this.address});

  SignUpRequest.club(
      {@required this.name,
      @required this.phone,
      @required this.passWord,
      @required this.confirmPassword,
      this.email,
      this.city,
      this.district,
      this.ward,
      this.address});

  Map<String, dynamic> toJsonClub() =>
      {
        'name': name,
        'phone': phone,
        'password': passWord,
        'confirm_password': confirmPassword,
        'email' : email,
        'city': city,
      };
}
