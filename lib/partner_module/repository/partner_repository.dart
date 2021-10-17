import 'dart:convert';

import 'package:conecapp/common/api/api_base_helper.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/partner_module/models/group_response.dart';
import 'package:conecapp/partner_module/models/members_response.dart';
import 'package:conecapp/partner_module/models/p_notify_detail.dart';
import 'package:conecapp/partner_module/models/p_notify_reponse.dart';
import 'package:conecapp/partner_module/models/push_notify_response.dart';
import 'package:conecapp/partner_module/models/search_m_response.dart';
import 'package:conecapp/partner_module/ui/member/member_detail_page.dart';

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

  Future<bool> addGroup(dynamic body) async {
    final response = await _helper.post('/api/MemberGroup/AddUserGroup',
        body: body, headers: await Helper.header());
    print(response);
    return response['status'];
  }

  Future<bool> updateGroup(dynamic body) async {
    final response = await _helper.post('/api/MemberGroup/UpdateUserGroup',
        body: body, headers: await Helper.header());
    print(response);
    return response['status'];
  }

  Future<PNotifyFull> updatePNotify(dynamic body) async {
    final response = await _helper.post('/api/Notification/UpdateNotification',
        body: body, headers: await Helper.header());
    print(response);
    return PNotifyDetailResponse.fromJson(response).notifyFull;
  }

  Future<PushNotifyResponse> pushNotify(String id) async {
    final response = await _helper.get('/api/Notification/PushNotify?id=$id',
        headers: await Helper.header());
    print(response);
    return PushNotifyResponse.fromJson(response);
  }

  //---------------------------member----------------------------------//
  Future<MembersResponse> getAllMember(int page, {String userGroupId}) async {
    String param = userGroupId != null ? '&userGroupId=$userGroupId' : '';
    final response = await _helper.get(
        '/api/Member/GetAllMembers?page=$page$param',
        headers: await Helper.header());
    print(response);
    return MembersResponse.fromJson(response);
  }

  Future<Member> addMember(dynamic body) async {
    final response = await _helper.post('/api/Member/AddMember',
        body: body, headers: await Helper.header());
    print(response);
    return Member.fromJson(response);
  }

  Future<Member> updateMember(dynamic body) async {
    final response = await _helper.post('/api/Member/UpdateMember',
        body: body, headers: await Helper.header());
    print(response);
    return Member.fromJson(response);
  }

  Future<SearchMResponse> searchMember(String keyWord) async {
    final response = await _helper.get(
        '/api/Member/SearchMember?search=$keyWord',
        headers: await Helper.header());
    print(response);
    return SearchMResponse.fromJson(response);
  }

  Future<bool> deleteMember(String id) async {
    final response = await _helper.post("/api/Member/DeleteMember?id=$id",
        headers: await Helper.header());
    print(response);
    return response['status'];
  }

  Future<String> getNote(String id) async {
    final response = await _helper.get('/api/Member/GetNotifyPayment?id=$id',
        headers: await Helper.header());
    print(response);
    return response['notes'];
  }

  Future<bool> notifyPayment(dynamic body) async {
    final response = await _helper.post('/api/Member/NotifyPayment',
        body: body, headers: await Helper.header());
    print(response);
    return response['status'];
  }

  Future<bool> notifyMemberConfirm(dynamic body) async {
    final response = await _helper.post('/api/Member/AcceptedReminder',
        body: body, headers: await Helper.header());
    print(response);
    return response['status'];
  }

  Future<MemberDetailResponse> getMemberDetail(String id) async {
    final response = await _helper.get("/api/Member/GetUserMember?id=$id",
        headers: await Helper.header());
    print(response);
    return MemberDetailResponse.fromJson(response);
  }

  Future<bool> completePayment(dynamic body, PAYMENT_TYPE type) async {
    String urlType =
        type == PAYMENT_TYPE.COMPLETE ? "CompletePayment" : "UpdatePayment";
    final response = await _helper.post('/api/Member/$urlType',
        body: body, headers: await Helper.header());
    print(response);
    return response['status'];
  }

  Future<GroupResponse> fetchGroup() async {
    final response = await _helper.get('/api/MemberGroup/GetAllUserGroups',
        headers: await Helper.header());
    print(response);
    return GroupResponse.fromJson(response);
  }

  Future<bool> deleteGroup(String id) async {
    final response = await _helper.post(
        "/api/MemberGroup/DeleteUserGroup?id=$id",
        headers: await Helper.header());
    print(response);
    return response['status'];
  }

  Future<bool> swapGroup(String userMemberId, String userGroupId) async {
    final response = await _helper.post("/api/MemberGroup/ChangeGroup",
        body: jsonEncode(
            {'userMemberId': userMemberId, 'userGroupId': userGroupId}),
        headers: await Helper.header());
    print(response);
    return response['status'];
  }

  Future<Group> fetchGroupDetail(String groupId) async {
    final response = await _helper.get(
        "/api/MemberGroup/GetUserGroup?id=$groupId",
        headers: await Helper.header());
    print(response);
    return Group.fromJson(response['group']);
  }
}
