import 'package:conecapp/models/response/slider.dart';

class SliderResponse {
  List<Slider> sliders;

  SliderResponse(this.sliders);

  SliderResponse.fromJson(Map<String, dynamic> json) {
    if (json['sliders'] != null) {
      sliders = new List<Slider>();
      json['sliders'].forEach((v) {
        sliders.add(new Slider.fromJson(v));
      });
    }
  }

}