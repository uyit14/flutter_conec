class SignUpResponse {
  bool status;
  String token;
  List<Error> errors;

  SignUpResponse({this.status, this.token, this.errors});

  SignUpResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    token = json['token'];
    if (json['errors'] != null) {
      errors = new List<Error>();
      json['errors'].forEach((v) {
        errors.add(new Error.fromJson(v));
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

class Error {
  String code;
  String description;

  Error({this.code, this.description});

  Error.fromJson(Map<String, dynamic> json) {
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