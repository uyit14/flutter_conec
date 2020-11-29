import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/ads_detail.dart';
import 'package:conecapp/models/response/news.dart';
import 'package:conecapp/models/response/news_detail.dart';
import 'package:conecapp/models/response/news_reponse.dart';
import 'package:conecapp/models/response/sport.dart';
import 'package:conecapp/models/response/sport_response.dart';

class NewsRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<List<News>> fetchAllNews(int page, {String keyword}) async {
    final response = await _helper.get("/api/news/getall?page=$page&keyword=${keyword ?? ""}");
    return NewsResponse.fromJson(response).news;
  }

  Future<NewsDetail> fetchNewsDetail(String postId) async {
    String _queryEnPoint = await Helper.token()!=null ? "GetWithLogin" : "Get";
    dynamic _header = await Helper.token()!=null ? await Helper.header() : null;
    final response = await _helper.get('/api/News/$_queryEnPoint?id=$postId', headers: _header);
    return NewsDetailResponse.fromJson(response).news;
  }

  Future<List<Sport>> fetchAllAds(int page,
      {String province, String district, String topic, String club, String keyword}) async {
    final response = await _helper.get(
        "/api/Ads/GetAll?page=$page&province=${province ?? ""}&district=${district ?? ""}&topic=${topic ?? ""}&club=${club ?? ""}&keyword=${keyword ?? ""}");
    return SportResponse.fromJson(response).sports;
  }

  Future<AdsDetail> fetchAdsDetail(String postId) async {
    String _queryEnPoint = await Helper.token()!=null ? "GetWithLogin" : "Get";
    dynamic _header = await Helper.token()!=null ? await Helper.header() : null;
    final response = await _helper.get('/api/Ads/$_queryEnPoint?id=$postId', headers: _header);
    return AdsDetailsResponse.fromJson(response).adsDetail;
  }
}
