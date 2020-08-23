import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/ads_detail.dart';
import 'package:conecapp/models/response/news.dart';
import 'package:conecapp/models/response/news_detail.dart';
import 'package:conecapp/models/response/sport.dart';
import 'package:conecapp/repositories/news/news_repository.dart';
import 'package:flutter/foundation.dart';

class NewsBloc {
  NewsRepository _repository;

  NewsBloc() {
    _repository = NewsRepository();
  }

  //news
  StreamController<ApiResponse<List<News>>> _newsController =
      StreamController();

  Stream<ApiResponse<List<News>>> get allNewsStream => _newsController.stream;

  //news detail
  StreamController<ApiResponse<NewsDetail>> _newsDetailController =
      StreamController();

  Stream<ApiResponse<NewsDetail>> get newsDetailStream =>
      _newsDetailController.stream;

  //all ads
  StreamController<ApiResponse<List<Sport>>> _allAdsController =
      StreamController();

  Stream<ApiResponse<List<Sport>>> get allAdsStream => _allAdsController.stream;

  //ads detail
  StreamController<ApiResponse<AdsDetail>> _adsDetailController =
      StreamController();

  Stream<ApiResponse<AdsDetail>> get adsDetailStream =>
      _adsDetailController.stream;

  void requestGetAllNews() async {
    _newsController.sink.add(ApiResponse.loading());
    try {
      final allNews = await _repository.fetchAllNews();
      _newsController.sink.add(ApiResponse.completed(allNews));
    } catch (e) {
      _newsController.sink.addError(ApiResponse.error(e.toString()));
    }
  }

  void requestNewsDetail(String postId) async {
    _newsDetailController.sink.add(ApiResponse.loading());
    try {
      final newsDetail = await _repository.fetchNewsDetail(postId);
      _newsDetailController.sink.add(ApiResponse.completed(newsDetail));
    } catch (e) {
      _newsDetailController.sink.addError(ApiResponse.error(e.toString()));
    }
  }

  void requestGetAllAds() async {
    _allAdsController.sink.add(ApiResponse.loading());
    try {
      final allAds = await _repository.fetchAllAds();
      _allAdsController.sink.add(ApiResponse.completed(allAds));
    } catch (e) {
      _allAdsController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  void requestAdsDetail(String postId) async {
    _adsDetailController.sink.add(ApiResponse.loading());
    try {
      final adsDetail = await _repository.fetchAdsDetail(postId);
      _adsDetailController.sink.add(ApiResponse.completed(adsDetail));
    } catch (e) {
      _adsDetailController.sink.addError(ApiResponse.error(e.toString()));
    }
  }

  void dispose() {
    _newsController.close();
    _newsDetailController.close();
    _allAdsController.close();
    _adsDetailController.close();
  }
}
