import 'dart:convert';
import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/delete_response.dart';
import 'package:conecapp/models/response/item_detail.dart';
import 'package:conecapp/models/response/location/city_response.dart';
import 'package:conecapp/models/response/mypost_response.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/models/response/topic_response.dart';

class MyPostRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<List<Topic>> fetchTopicWithHeader() async {
    final response = await _helper.get("/api/MyPost/GetTopic",
        headers: await Helper.header());
    return TopicResponse.fromJson(response).topics;
  }

  Future<List<Topic>> fetchSubTopicWithHeader(bool isTopic,
      {String topicId}) async {
    String query = isTopic ? "/api/Topic" : "/api/SubTopic?topicId=$topicId";
    final response = await _helper.get(query, headers: await Helper.header());
    if (isTopic) {
      return TopicResponse.fromJson(response).topics;
    } else {
      return SubTopicResponse.fromJson(response).topics;
    }
  }

  Future<String> fetchTitle(String topicId) async {
    final response = await _helper.post("/api/Mypost/GetTitle?id=$topicId",
        headers: await Helper.header());
    print(response);
    return response['title'];
  }

  Future<List<Province>> getListProvince() async {
    final response = await _helper.get('/api/Address/LoadProvinces');
    return CityResponse.fromJson(response).provinces;
  }

  Future<List<Province>> getListDistrict(String provinceId) async {
    final response = await _helper
        .get('/api/Address/LoadDistrictByProvinceIds?provinceId=$provinceId');
    return DistrictResponse.fromJson(response).districts;
  }

  Future<List<Province>> getListDistrictByProvinceName(
      String provinceName) async {
    final response = await _helper
        .get('/api/Address/LoadDistrictByProvinceNames?province=$provinceName');
    return DistrictResponse.fromJson(response).districts;
  }

  Future<List<Province>> getListWard(String districtId) async {
    final response = await _helper
        .get('/api/Address/LoadWardByDistrictIds?districtId=$districtId');
    return WardResponse.fromJson(response).wards;
  }

  Future<List<Province>> getListWardByName(String districtName) async {
    final response = await _helper
        .get('/api/Address/LoadWardByDistrictNames?district=$districtName');
    return WardResponse.fromJson(response).wards;
  }

  Future<List<MyPost>> getMyPostByType(int page, String myPostType) async {
    final response = await _helper.get('/api/MyPost/$myPostType?page=$page',
        headers: await Helper.header());
    return MyPostResponse.fromJson(response).myPosts;
  }

  Future<ItemDetail> postMyPost(dynamic body, String type) async {
    final response = await _helper.post('/api/MyPost/$type',
        body: body, headers: await Helper.header());
    return ItemDetailResponse.fromJson(response).itemDetail;
  }

  Future<ItemDetail> updateMyPost(dynamic body) async {
    final response = await _helper.post('/api/MyPost/Update',
        body: body, headers: await Helper.header());
    print(ItemDetailResponse.fromJson(response).status.toString());
    return ItemDetailResponse.fromJson(response).itemDetail;
  }

  Future<DeleteResponse> deleteMyPost(String postId, String type,
      {bool isPush, bool isPriority}) async {
    String pushQuery =
        type == "Push" ? "&push=$isPush&priority=$isPriority" : "";
    final response = await _helper.post(
        '/api/MyPost/$type?id=$postId$pushQuery',
        headers: await Helper.header());
    print(response);
    return DeleteResponse.fromJson(response);
  }

  Future<DeleteResponse> deleteImage(String id, String type) async {
    final response = await _helper.post('/api/$type/DeleteImage?id=$id',
        headers: await Helper.header());
    print(response);
    return DeleteResponse.fromJson(response);
  }
}
