class ProfileRequest {
  String name;
  String email;
  Map avatar;
  String gender;
  dynamic dob;
  String phoneNumber;
  String type;
  String province;
  String district;
  String ward;
  String address;
  double lat;
  double lng;

  ProfileRequest(
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

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (avatar != null) 'avatar': avatar,
        if (gender != null) 'gender': gender,
        if (dob != null) 'dob': dob,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (type != null) 'type': type,
        if (province != null) 'province': province,
        if (district != null) 'district': district,
        if (ward != null) 'ward': ward,
        if (address != null) 'address': address,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      };

//  Map<String, dynamic> toJson() => {
//     'name': name,
//     'email': email,
//    'avatar': avatar,
//     'gender': gender,
//     'dob': dob,
//     'phoneNumber': phoneNumber,
//     'type': type,
//     'province': province,
//    'district': district,
//     'ward': ward,
//    'address': address,
//     'lat': lat,
//     'lng': lng,
//  };
}
