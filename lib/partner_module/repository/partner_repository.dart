import 'dart:convert';

import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/partner_module/models/p_notify_detail.dart';
import 'package:conecapp/partner_module/models/p_notify_reponse.dart';

class PartnerRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<PNotifyResponse> getPartnerNotifies(int page) async {
    final response = await _helper.get(
        '/api/Notification/GetAllPosts?page=$page',
        headers: await Helper.header());
    print(response);
    return PNotifyResponse.fromJson(response);
  }

  Future<PNotifyDetailResponse> fetchPartnerNotifyDetail(
      String pNotifyID) async {
    final response = await _helper.get(
        "/api/Notification/GetPost?id=$pNotifyID",
        headers: await Helper.header());
    print(response);
    return PNotifyDetailResponse.fromJson(response);
  }

  Future<bool> deletePNotify(String notifyId) async {
    final response = await _helper.post("/api/Notification/Delete?id=$notifyId",
        headers: await Helper.header());
    return response['status'];
  }

  Future<PNotifyFull> addPNotify(dynamic body) async {
    final response = await _helper.post('/api/Notification/AddNotification',
        body: body, headers: await Helper.header());
    print(response);
    return PNotifyDetailResponse.fromJson(response).notifyFull;
  }

  Future<PNotifyFull> updatePNotify(dynamic body) async {
    final response = await _helper.post('/api/Notification/UpdateNotification',
        body: body, headers: await Helper.header());
    print(response);
    return PNotifyDetailResponse.fromJson(response).notifyFull;
  }
}
