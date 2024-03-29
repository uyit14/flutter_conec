import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/ads_detail.dart';
import 'package:conecapp/models/response/news.dart';
import 'package:conecapp/models/response/news_detail.dart';
import 'package:conecapp/models/response/sport.dart';
import 'package:conecapp/repositories/news/news_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:tiengviet/tiengviet.dart';

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

  //ads detail
  StreamController<ApiResponse<AdsDetail>> _adsDetailController2 =
  StreamController();

  Stream<ApiResponse<AdsDetail>> get adsDetailStream2 =>
      _adsDetailController2.stream;

  List<News> _originalNews = List<News>();
  List<Sport> _originalSport = List<Sport>();

  void requestGetAllNews(int page, {String keyword}) async {
    _newsController.sink.add(ApiResponse.completed([]));
    try {
      final allNews = await _repository.fetchAllNews(page, keyword: keyword);
      _originalNews.addAll(allNews);
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

  void requestGetAllAds(int page,
      {String province, String district, String topic, String club, String keyword, String topics}) async {
    print(topics);
    _allAdsController.sink.add(ApiResponse.completed([]));
    if (page != 1) {
      final allAds = await _repository.fetchAllAds(page,
          province: province, district: district, club: club, topic: topic, keyword: keyword, topics: topics);
      _originalSport.addAll(allAds);
      _allAdsController.sink.add(ApiResponse.completed(allAds));
    } else {
      _originalSport.clear();
      //_allAdsController.sink.add(ApiResponse.loading());
      try {
        final allAds = await _repository.fetchAllAds(page,
            province: province, district: district, club: club, topic: topic, keyword: keyword, topics: topics);
        _originalSport.addAll(allAds);
        _allAdsController.sink.add(ApiResponse.completed(allAds));
      } catch (e) {
        _allAdsController.sink.addError(ApiResponse.error(e.toString()));
        debugPrint(e.toString());
      }
    }
  }

  void requestAdsDetail(String postId) async {
    _adsDetailController.sink.add(ApiResponse.loading());
    try {
      final adsDetail = await _repository.fetchAdsDetail(postId);
      _adsDetailController.sink.add(ApiResponse.completed(adsDetail));
      _adsDetailController2.sink.add(ApiResponse.completed(adsDetail));
    } catch (e) {
      _adsDetailController.sink.addError(ApiResponse.error(e.toString()));
    }
  }

  void clearSearch() {
    _newsController.sink.add(ApiResponse.completed(_originalNews));
  }

  void searchAction(String keyWord) {
    List<News> _searchResult = List<News>();
    _originalNews.forEach((news) {
      if (_search(news, keyWord)) {
        _searchResult.add(news);
      }
    });
    _newsController.sink.add(ApiResponse.completed(_searchResult));
  }

  bool _search(News news, String txtSearch) {
    if (TiengViet.parse(news.title)
        .toLowerCase()
        .contains(txtSearch.toLowerCase())) {
      return true;
    }
    return false;
  }

  void clearSportSearch() {
    print("clean to ${_originalSport.length}");
    _allAdsController.sink.add(ApiResponse.completed(_originalSport));
  }

  void searchSportAction(String keyWord) {
    print("keylength  ${keyWord.length}");
    List<Sport> _searchResult = [];
    _originalSport.forEach((sport) {
      if (_searchSport(sport, keyWord)) {
        _searchResult.add(sport);
      }
    });
    print("sink to ${_searchResult.length}");
    _allAdsController.sink.add(ApiResponse.completed(_searchResult));
  }

  bool _searchSport(Sport sport, String txtSearch) {
    if (TiengViet.parse(sport.title)
        .toLowerCase()
        .contains(txtSearch.toLowerCase())) {
      return true;
    }
    return false;
  }

  void dispose() {
    _newsController.close();
    _newsDetailController.close();
    _allAdsController.close();
    _adsDetailController.close();
    _adsDetailController2?.close();
  }
}
