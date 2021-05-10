import 'dart:async';
import 'dart:isolate';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/models/response/latest_item.dart';
import 'package:conecapp/models/response/nearby_club_response.dart';
import 'package:conecapp/models/response/nearby_response.dart';
import 'package:conecapp/models/response/news.dart';
import 'package:conecapp/models/response/page/hidden_response.dart';
import 'package:conecapp/models/response/page/page_response.dart';
import 'package:conecapp/models/response/slider.dart';
import 'package:conecapp/models/response/sport.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/repositories/home/home_remote_repository.dart';
import 'package:flutter/foundation.dart';

class HomeBloc {
  static HomeRemoteRepository _repository = HomeRemoteRepository();

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
  StreamController.broadcast();
  Stream<ApiResponse<NearbyResponse>> get nearByStream => _nearByController.stream;

  //nearby
  StreamController<ApiResponse<List<LatestItem>>> _nearByClubController =
  StreamController();
  Stream<ApiResponse<List<LatestItem>>> get nearByClubStream => _nearByClubController.stream;

  //page response
  StreamController<ApiResponse<Profile>> _pageIntroController =
  StreamController();
  Stream<ApiResponse<Profile>> get pageIntroStream => _pageIntroController.stream;
  //page response
  StreamController<ApiResponse<bool>> _ratingIntroController =
  StreamController.broadcast();
  Stream<ApiResponse<bool>> get ratingIntroStream => _ratingIntroController.stream;

  //page response
  StreamController<ApiResponse<int>> _numberNotifyController =
  StreamController.broadcast();
  Stream<ApiResponse<int>> get numberNotifyStream => _numberNotifyController.stream;

  // HomeBloc() {
  //   _repository = HomeRemoteRepository();
  // }

  void requestPageIntroduce(String clubId)async{
    _pageIntroController.sink.add(ApiResponse.loading());
    final _pageData = await _repository.fetchPageIntroduce(clubId);
    if(_pageData.status){
      _pageIntroController.sink.add(ApiResponse.completed(_pageData.profile));
    }else{
      _pageIntroController.sink.addError(ApiResponse.error(_pageData.error));
    }
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

  void requestGetNearByClub(double lat, double lng) async {
    _nearByClubController.sink.add(ApiResponse.loading());
    try {
      final nearby = await _repository.fetchNearByClub(lat, lng);
      _nearByClubController.sink.add(ApiResponse.completed(nearby));
    } catch (e) {
      _nearByClubController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  //
  Isolate isolate;
  //topic
  void startTopic() async {
    ReceivePort receivePort= ReceivePort(); //port for isolate to receive messages.
    isolate = await Isolate.spawn(runTopic, receivePort.sendPort);
    receivePort.listen((data) {
      print("Receive Topic: ${data.length}");
      requestGetTopic(data);
    });
  }

  static void runTopic(SendPort sendPort) async{
    final topics = await _repository.fetchTopic();
      sendPort.send(topics);
  }


  void requestGetTopic(var topics) async {
    _topicController.sink.add(ApiResponse.loading());
    try {
      //final topics = await _repository.fetchTopic();
      _topicController.sink.add(ApiResponse.completed(topics));
    } catch (e) {
      _topicController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  //slide
  void startSlider() async {
    ReceivePort receivePort= ReceivePort(); //port for isolate to receive messages.
    isolate = await Isolate.spawn(runSlider, receivePort.sendPort);
    receivePort.listen((data) {
      print("Receive Slider: ${data.length}");
      requestGetSlider(data);
    });
  }

  static void runSlider(SendPort sendPort) async{
    final sliders = await _repository.fetchSlider();
    sendPort.send(sliders);
  }

  void requestGetSlider(var sliders) async {
    _sliderController.sink.add(ApiResponse.loading());
    try {
      //final sliders = await _repository.fetchSlider();
      _sliderController.sink.add(ApiResponse.completed(sliders));
    } catch (e) {
      _sliderController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  //new item
  void startLatestItem() async {
    ReceivePort receivePort= ReceivePort(); //port for isolate to receive messages.
    isolate = await Isolate.spawn(runLatestItem, receivePort.sendPort);
    receivePort.listen((data) {
      print("Receive LatestItem: ${data.length}");
      requestGetLatestItem(data);
    });
  }

  static void runLatestItem(SendPort sendPort) async{
    final items = await _repository.fetchLatestItem();
    sendPort.send(items);
  }

  void requestGetLatestItem(var items) async {
    _latestItemController.sink.add(ApiResponse.loading());
    try {
      //final items = await _repository.fetchLatestItem();
      _latestItemController.sink.add(ApiResponse.completed(items));
    } catch (e) {
      _latestItemController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  void startSport() async {
    ReceivePort receivePort= ReceivePort(); //port for isolate to receive messages.
    isolate = await Isolate.spawn(runSport, receivePort.sendPort);
    receivePort.listen((data) {
      print("Receive Sport: ${data.length}");
      requestGetSport(data);
    });
  }

  static void runSport(SendPort sendPort) async{
    final sports = await _repository.fetchSport();
    sendPort.send(sports);
  }

  void requestGetSport(var sports) async {
    _sportController.sink.add(ApiResponse.loading());
    try {
      //final sports = await _repository.fetchSport();
      _sportController.sink.add(ApiResponse.completed(sports));
    } catch (e) {
      _sportController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }


  void startNews() async {
    ReceivePort receivePort= ReceivePort(); //port for isolate to receive messages.
    isolate = await Isolate.spawn(runNews, receivePort.sendPort);
    receivePort.listen((data) {
      print("Receive News: ${data.length}");
      requestGetNews(data);
    });
  }

  static void runNews(SendPort sendPort) async{
    final news = await _repository.fetchNews();
    sendPort.send(news);
  }
  void requestGetNews(var news) async {
    _newsController.sink.add(ApiResponse.loading());
    try {
      //final news = await _repository.fetchNews();
      _newsController.sink.add(ApiResponse.completed(news));
    } catch (e) {
      _newsController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  void requestRatingClub(dynamic body) async{
    final response = await _repository.ratingClub(body);
    if(response!=null && response){
      _ratingIntroController.sink.add(ApiResponse.completed(true));
    }else{
      _ratingIntroController.sink.add(ApiResponse.completed(false));
    }
  }

  void requestGetNumberNotify() async{
    final response = await _repository.getNumberNotify();
    if(response.status){
      _numberNotifyController.sink.add(ApiResponse.completed(response.notifyCounter));
    }else{
      print("Fail to get notify");
      _numberNotifyController.sink.add(ApiResponse.completed(0));
    }
  }

  Future<bool> requestGiftCheck() async {
    final response = await _repository.giftCheck();
    return response;
  }

  Future<bool> requestGiftReceive() async {
    final response = await _repository.giftReceive();
    return response;
  }

  Future<String> requestGetAppVersion() async {
    final response = await _repository.getAppVersion();
    return response;
  }

  Future<HiddenResponse> requestHidden(String ownerId, String userId) async {
    final response = await _repository.getHidden(ownerId, userId);
    return response;
  }

  Future<String> requestRegisterDeviceToken(String deviceToken, String userId) async {
    final response = await _repository.registerDeviceToken(deviceToken, userId);
    return response;
  }

  void stop() {
    if (isolate != null) {
      isolate.kill(priority: Isolate.immediate);
      isolate = null;
    }
  }

  void dispose() {
    _topicController.close();
    _sliderController.close();
    _latestItemController.close();
    _sportController.close();
    _newsController.close();
    _numberNotifyController.close();
    _nearByClubController.close();
    stop();
  }

  void disposeNearBy(){
    _nearByController.close();
  }

  void disposePage(){
    _pageIntroController.close();
  }

  void disposeRating(){
    _ratingIntroController.close();
  }
}
