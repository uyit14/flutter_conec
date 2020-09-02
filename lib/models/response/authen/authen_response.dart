class VerifyUserNameResponse{
  bool status;
  String error;

  VerifyUserNameResponse({this.status, this.error});

  VerifyUserNameResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if(json['error']!=null){
      error = json['error'];
    }
  }
}