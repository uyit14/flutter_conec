import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/models/response/ads_detail.dart';
import 'package:conecapp/models/response/news.dart';
import 'package:conecapp/models/response/news_detail.dart';
import 'package:conecapp/models/response/news_reponse.dart';
import 'package:conecapp/models/response/sport.dart';
import 'package:conecapp/models/response/sport_response.dart';

class NewsRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<List<News>> fetchAllNews() async {
    final response = await _helper.get("/api/news/getall");
    return NewsResponse.fromJson(response).news;
  }

  Future<NewsDetail> fetchNewsDetail(String postId) async {
    final response = await _helper.get('/api/News/Get?id=$postId');
    return NewsDetailResponse.fromJson(response).news;
  }

  Future<List<Sport>> fetchAllAds(int page,
      {String province, String district, String topic, String club}) async {
    final response = await _helper.get(
        "/api/Ads/GetAll?page=$page&province=${province ?? ""}&district=${district ?? ""}&topic=${topic ?? ""}&club=${club ?? ""}");
    return SportResponse.fromJson(response).sports;
  }

  Future<AdsDetail> fetchAdsDetail(String postId) async {
    final response = await _helper.get('/api/Ads/Get?id=$postId');
    return AdsDetailsResponse.fromJson(response).adsDetail;
  }
}
