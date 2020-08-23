import 'dart:convert';

import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/models/request/post_action_request.dart';
import 'package:conecapp/models/response/delete_response.dart';
import 'package:conecapp/models/response/item_detail.dart';
import 'package:conecapp/models/response/location/city_response.dart';
import 'package:conecapp/models/response/mypost_response.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/models/response/topic_response.dart';
import '../../common/globals.dart' as globals;

class MyPostRepository {
  ApiBaseHelper _helper = ApiBaseHelper();
  static final _header = {
    'authorization': "Bearer ${globals.token}",
    'Content-Type': "application/json"
  };

  Future<List<Topic>> fetchTopicWithHeader() async {
    final response = await _helper.get("/api/MyPost/GetTopic", headers: _header);
    return TopicResponse.fromJson(response).topics;
  }

  Future<List<Province>> getListProvince() async {
    final response = await _helper.get('/api/Address/LoadProvinces');
    return CityResponse.fromJson(response).provinces;
  }
  Future<List<Province>> getListDistrict(String provinceId) async {
    final response = await _helper.get('/api/Address/LoadDistrictByProvinceIds?provinceId=$provinceId');
    return DistrictResponse.fromJson(response).districts;
  }
  Future<List<Province>> getListWard(String districtId) async {
    final response = await _helper.get('/api/Address/LoadWardByDistrictIds?districtId=$districtId');
    return WardResponse.fromJson(response).wards;
  }

  Future<List<MyPost>> getMyPostByType(int page, String myPostType)async{
    final response = await _helper.get('/api/MyPost/$myPostType?page=$page', headers: _header);
    return MyPostResponse.fromJson(response).myPosts;
  }

  Future<ItemDetail> postMyPost(dynamic body, String type) async {
    final response = await _helper.post('/api/MyPost/$type', body: body, headers: _header);
    return ItemDetailResponse.fromJson(response).itemDetail;
  }

  Future<ItemDetail> updateMyPost(dynamic body) async {
    final response = await _helper.post('/api/MyPost/Update', body: body, headers: _header);
    print(ItemDetailResponse.fromJson(response).status.toString());
    return ItemDetailResponse.fromJson(response).itemDetail;
  }

  Future<DeleteResponse> deleteMyPost(String postId) async {
    final response = await _helper.post('/api/MyPost/Delete?id=$postId', body: jsonEncode({"id": postId}), headers: _header);
    return DeleteResponse.fromJson(response);
  }

  Future<DeleteResponse> deleteImage(String id) async {
    final response = await _helper.post('/api/MyPost/DeleteImage', body: jsonEncode({"id":id}), headers: _header);
    return DeleteResponse.fromJson(response);
  }
}
