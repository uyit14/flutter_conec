import 'package:conecapp/models/response/news.dart';

class NewsResponse{
  List<News> news;

  NewsResponse(this.news);

  NewsResponse.fromJson(Map<String, dynamic> json) {
    if (json['news'] != null) {
      news = new List<News>();
      json['news'].forEach((v) {
        news.add(new News.fromJson(v));
      });
    }
  }
}