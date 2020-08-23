import 'package:conecapp/models/response/sport.dart';

class SportResponse {
  List<Sport> sports;

  SportResponse(this.sports);

  SportResponse.fromJson(Map<String, dynamic> json) {
    if (json['ads'] != null) {
      sports = new List<Sport>();
      json['ads'].forEach((v) {
        sports.add(new Sport.fromJson(v));
      });
    }
  }

}