class ChangePassWordResponse {
  bool status;
  String token;
  String expires;
  List<Errors> errors;

  ChangePassWordResponse({this.status, this.token, this.errors, this.expires});

  ChangePassWordResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    token = json['token'];
    expires = json['expires'];
    if (json['errors'] != null) {
      errors = new List<Errors>();
      json['errors'].forEach((v) {
        errors.add(new Errors.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['token'] = this.token;
    if (this.errors != null) {
      data['errors'] = this.errors.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Errors {
  String code;
  String description;

  Errors({this.code, this.description});

  Errors.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['description'] = this.description;
    return data;
  }
}