import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/partner_module/models/group_response.dart';
import 'package:conecapp/partner_module/models/member_info_response.dart';
import 'package:conecapp/partner_module/models/members_response.dart';
import 'package:conecapp/partner_module/models/requestsmember_response.dart';
import 'package:conecapp/partner_module/models/search_m_response.dart';
import 'package:conecapp/partner_module/repository/partner_repository.dart';
import 'package:conecapp/partner_module/ui/member/member_detail_page.dart';
import 'package:flutter/foundation.dart';

class MemberBloc {
  PartnerRepository _repository;

  MemberBloc() {
    _repository = PartnerRepository();
  }

  //member list
  StreamController<ApiResponse<List<Member>>> _membersController =
      StreamController();

  Stream<ApiResponse<List<Member>>> get membersStream =>
      _membersController.stream;

  //add member
  StreamController<ApiResponse<Member>> _addMemberController =
      StreamController();

  Stream<ApiResponse<Member>> get addMemberStream =>
      _addMemberController.stream;

  //confirm request
  StreamController<ApiResponse<Member>> _confirmRequestController =
  StreamController();

  Stream<ApiResponse<Member>> get confirmRequestStream =>
      _confirmRequestController.stream;

  //update member
  StreamController<ApiResponse<Member>> _updateMemberController =
      StreamController();

  Stream<ApiResponse<Member>> get updateMemberStream =>
      _updateMemberController.stream;

  //member
  StreamController<ApiResponse<List<MemberSearch>>> _memberSearchController =
      StreamController();

  Stream<ApiResponse<List<MemberSearch>>> get memberSearchStream =>
      _memberSearchController.stream;

  //group
  StreamController<ApiResponse<List<Group>>> _groupController =
      StreamController();

  Stream<ApiResponse<List<Group>>> get groupSearchStream =>
      _groupController.stream;

  //member detail
  StreamController<ApiResponse<Member>> _memberDetailController =
      StreamController();

  Stream<ApiResponse<Member>> get memberDetailStream =>
      _memberDetailController.stream;

  //gr detail
  StreamController<ApiResponse<Group>> _groupDetailController =
      StreamController();

  Stream<ApiResponse<Group>> get groupDetailStream =>
      _groupDetailController.stream;

  //gr detail
  StreamController<List<int>> _numberOfMembers = StreamController();

  Stream<List<int>> get numberOfMembersStream => _numberOfMembers.stream;

  //group
  StreamController<ApiResponse<List<Request>>> _requestController =
      StreamController();

  Stream<ApiResponse<List<Request>>> get requestStream =>
      _requestController.stream;

  //gr detail
  StreamController<ApiResponse<MemberInfo>> _memberInfoController =
  StreamController();

  Stream<ApiResponse<MemberInfo>> get memberInfoStream =>
      _memberInfoController.stream;

  void requestGetMembers(int page,
      {String userGroupId, int memberType = 0}) async {
    print('page $page');
    _membersController.sink.add(ApiResponse.completed([]));
    try {
      final result =
          await _repository.getAllMember(page, userGroupId: userGroupId);
      _numberOfMembers.sink
          .add([result.members.length, result.pendingMembers.length]);
      if (memberType == 0) {
        print("sink members $page ${result.members.length}");
        _membersController.sink.add(ApiResponse.completed(result.members));
      } else {
        print("sink pendingMembers $page ${result.pendingMembers.length}");
        _membersController.sink
            .add(ApiResponse.completed(result.pendingMembers));
      }
    } catch (e) {
      _membersController.sink.addError(ApiResponse.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  void requestGetGroup() async {
    _groupController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.fetchGroup();
      _groupController.sink.add(ApiResponse.completed(result.groups));
    } catch (e) {
      _groupController.sink.add(ApiResponse.error(e.toString()));
      print("requestGetGroup ERROR: " + e.toString());
    }
  }

  void requestAddMember(dynamic body) async {
    _addMemberController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.addMember(body);
      _addMemberController.sink.add(ApiResponse.completed(result));
    } catch (e) {
      _addMemberController.sink.add(ApiResponse.error(e.toString()));
      print("Add_member_Error: " + e.toString());
    }
  }

  void requestConfirmRequest(dynamic body) async {
    _confirmRequestController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.confirmRequest(body);
      _confirmRequestController.sink.add(ApiResponse.completed(result));
    } catch (e) {
      _confirmRequestController.sink.add(ApiResponse.error(e.toString()));
      print("Confirm_Request_Error: " + e.toString());
    }
  }

  void requestUpdateMember(dynamic body) async {
    _updateMemberController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.updateMember(body);
      _updateMemberController.sink.add(ApiResponse.completed(result));
    } catch (e) {
      _updateMemberController.sink.add(ApiResponse.error(e.toString()));
      print("Update_Member_Error: " + e.toString());
    }
  }

  void requestSearchMember(String keyword) async {
    _memberSearchController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.searchMember(keyword);
      _memberSearchController.sink.add(ApiResponse.completed(result.members));
    } catch (e) {
      _memberSearchController.sink.add(ApiResponse.error(e.toString()));
      print("Update_Member_Error: " + e.toString());
    }
  }

  Future<bool> requestDeleteMember(String id) async {
    final response = await _repository.deleteMember(id);
    return response;
  }

  Future<bool> requestDeleteGroup(String id) async {
    final response = await _repository.deleteGroup(id);
    return response;
  }

  Future<bool> requestDeleteRequest(String id) async {
    final response = await _repository.deleteGroup(id);
    return response;
  }

  Future<bool> requestSwapGroup(String userMemberId, String userGroupId) async {
    final response = await _repository.swapGroup(userMemberId, userGroupId);
    return response;
  }

  Future<String> requestGetNote(String id) async {
    final response = await _repository.getNote(id);
    return response;
  }

  Future<bool> requestNotifyPayment(dynamic body) async {
    final response = await _repository.notifyPayment(body);
    return response;
  }

  Future<bool> requestNotifyMemberConfirm(dynamic body) async {
    final response = await _repository.notifyMemberConfirm(body);
    return response;
  }

  Future<bool> requestCompletePayment(dynamic body, PAYMENT_TYPE type) async {
    final response = await _repository.completePayment(body, type);
    return response;
  }

  Future<bool> addGroup(dynamic body) async {
    final response = await _repository.addGroup(body);
    return response;
  }

  Future<bool> updateGroup(dynamic body) async {
    final response = await _repository.updateGroup(body);
    return response;
  }

  void requestGetMemberDetail(String id) async {
    _memberDetailController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.getMemberDetail(id);
      _memberDetailController.sink.add(ApiResponse.completed(result.member));
    } catch (e) {
      _memberDetailController.sink.add(ApiResponse.error(e.toString()));
      print("Get_Member_Error: " + e.toString());
    }
  }

  void requestGetGroupDetail(String groupId) async {
    _groupDetailController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.fetchGroupDetail(groupId);
      _groupDetailController.sink.add(ApiResponse.completed(result));
    } catch (e) {
      _groupDetailController.sink.addError(ApiResponse.error(e.toString()));
    }
  }

  void requestGetMemberInfo(String id) async {
    _memberInfoController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.fetchMemberInfo(id);
      _memberInfoController.sink.add(ApiResponse.completed(result.memberInfo));
    } catch (e) {
      _memberInfoController.sink.addError(ApiResponse.error(e.toString()));
    }
  }

  void requestGetMemberRequest() async {
    _requestController.sink.add(ApiResponse.loading());
    try {
      final result = await _repository.fetchMemberRequest();
      _requestController.sink.add(ApiResponse.completed(result.requests));
    } catch (e) {
      _requestController.sink.addError(ApiResponse.error(e.toString()));
    }
  }

  void dispose() {
    _membersController?.close();
    _addMemberController?.close();
    _updateMemberController?.close();
    _memberSearchController?.close();
    _memberDetailController?.close();
    _groupController?.close();
    _groupDetailController?.close();
    _numberOfMembers?.close();
    _requestController?.close();
    _memberInfoController?.close();
    _confirmRequestController?.close();
  }
}
