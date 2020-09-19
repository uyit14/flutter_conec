import 'dart:async';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/latest_item.dart';
import 'package:conecapp/models/response/nearby_response.dart';
import 'package:conecapp/models/response/news.dart';
import 'package:conecapp/models/response/slider.dart';
import 'package:conecapp/models/response/sport.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/repositories/home/home_remote_repository.dart';
import 'package:flutter/foundation.dart';

class HomeBloc {
  HomeRemoteRepository _repository;

  //topic
  StreamController<ApiResponse<List<Topic>>> _topicController =
      StreamController();
  Stream<ApiResponse<List<Topic>>> get topicStream => _topicController.stream;

  //slider
  StreamController<ApiResponse<List<Slider>>> _sliderController =
      StreamController();
  Stream<ApiResponse<List<Slider>>> get sliderStream =>
      _sliderController.stream;

  //new
  StreamController<ApiResponse<List<LatestItem>>> _latestItemController =
      StreamController();
  Stream<ApiResponse<List<LatestItem>>> get latestItemStream =>
      _latestItemController.stream;

  //ads
  StreamController<ApiResponse<List<Sport>>> _sportController =
      StreamController();
  Stream<ApiResponse<List<Sport>>> get sportStream => _sportController.stream;

  //news
  StreamController<ApiResponse<List<News>>> _newsController =
  StreamController();
  Stream<ApiResponse<List<News>>> get newsStream => _newsController.stream;

  //nearby
  StreamController<ApiResponse<NearbyResponse>> _nearByController =
  StreamController();
  Stream<ApiResponse<NearbyResponse>> get nearByStream => _nearByController.stream;

  HomeBloc() {
    _repository = HomeRemoteRepository();
  }

  void requestGetNearBy(double lat, double lng, int distance) async {
    _nearByController.sink.add(ApiResponse.loading());
    try {
      final nearby = await _repository.fetchNearBy(lat, lng, distance);
      _nearByController.sink.add(ApiResponse.completed(nearby));
    } catch (e) {
      _nearByController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  void requestGetTopic() async {
    _topicController.sink.add(ApiResponse.loading());
    try {
      final topics = await _repository.fetchTopic();
      _topicController.sink.add(ApiResponse.completed(topics));
    } catch (e) {
      _topicController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  void requestGetSlider() async {
    _sliderController.sink.add(ApiResponse.loading());
    try {
      final sliders = await _repository.fetchSlider();
      _sliderController.sink.add(ApiResponse.completed(sliders));
    } catch (e) {
      _sliderController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  void requestGetLatestItem() async {
    _latestItemController.sink.add(ApiResponse.loading());
    try {
      final items = await _repository.fetchLatestItem();
      _latestItemController.sink.add(ApiResponse.completed(items));
    } catch (e) {
      _latestItemController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  void requestGetSport() async {
    _sportController.sink.add(ApiResponse.loading());
    try {
      final sports = await _repository.fetchSport();
      _sportController.sink.add(ApiResponse.completed(sports));
    } catch (e) {
      _sportController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  void requestGetNews() async {
    _newsController.sink.add(ApiResponse.loading());
    try {
      final news = await _repository.fetchNews();
      _newsController.sink.add(ApiResponse.completed(news));
    } catch (e) {
      _newsController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  void dispose() {
    _topicController.close();
    _sliderController.close();
    _latestItemController.close();
    _sportController.close();
    _newsController.close();
  }

  void disposeNearBy(){
    _nearByController.close();
  }
}
