class CityResponse {
  List<Province> provinces;

  CityResponse({this.provinces});

  CityResponse.fromJson(Map<String, dynamic> json) {
    if (json['provinces'] != null) {
      provinces = new List<Province>();
      json['provinces'].forEach((v) {
        provinces.add(new Province.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.provinces != null) {
      data['provinces'] = this.provinces.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class Province {
  String id;
  String name;

  Province({this.id, this.name});

  Province.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

//
class DistrictResponse {
  List<Province> districts;

  DistrictResponse({this.districts});

  DistrictResponse.fromJson(Map<String, dynamic> json) {
    if (json['districts'] != null) {
      districts = new List<Province>();
      json['districts'].forEach((v) {
        districts.add(new Province.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.districts != null) {
      data['districts'] = this.districts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
//
class WardResponse {
  List<Province> wards;

  WardResponse({this.wards});

  WardResponse.fromJson(Map<String, dynamic> json) {
    if (json['wards'] != null) {
      wards = new List<Province>();
      json['wards'].forEach((v) {
        wards.add(new Province.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.wards != null) {
      data['wards'] = this.wards.map((v) => v.toJson()).toList();
    }
    return data;
  }
}