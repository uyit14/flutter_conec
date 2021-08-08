import 'dart:convert';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/partner_module/models/members_response.dart';
import 'package:conecapp/partner_module/ui/member/add_member_page.dart';
import 'package:conecapp/partner_module/ui/member/member_bloc.dart';
import 'package:conecapp/partner_module/ui/member/member_detail_page.dart';
import 'package:conecapp/partner_module/ui/member/update_member_page.dart';
import 'package:conecapp/ui/chat/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ACTION_TYPE { MESSAGE, EDIT, REMIND, DETAIL, DELETE }

class MemberPage extends StatefulWidget {
  static const ROUTE_NAME = '/member';

  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  List<Member> _members = List();
  MemberBloc _memberBloc = MemberBloc();
  ScrollController _scrollController;
  bool _shouldLoadMore = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController()..addListener(_scrollListener);
    _memberBloc.requestGetMembers(_currentPage);
    _currentPage = 1;
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 250) {
      if (_shouldLoadMore) {
        _shouldLoadMore = false;
        _memberBloc.requestGetMembers(_currentPage);
        setState(() {
          _currentPage++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Thành viên")),
        body: Container(
          margin: EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 50),
          child: StreamBuilder<ApiResponse<List<Member>>>(
              stream: _memberBloc.membersStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  switch (snapshot.data.status) {
                    case Status.LOADING:
                      return UILoading(loadingMessage: snapshot.data.message);
                    case Status.ERROR:
                      return UIError(errorMessage: snapshot.data.message);
                    case Status.COMPLETED:
                      if (snapshot.data.data.length > 0) {
                        print("at UI: " + snapshot.data.data.length.toString());
                        _members.addAll(snapshot.data.data);
                        _shouldLoadMore = true;
                      } else {
                        _shouldLoadMore = false;
                      }
                      if (_members.length > 0) {
                        return ListView.builder(
                            itemCount: _members.length,
                            controller: _scrollController,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 5,
                                margin: EdgeInsets.all(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Tên thành viên",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      SizedBox(height: 4),
                                      Text(_members[index].name ?? "",
                                          style: TextStyle(fontSize: 16)),
                                      Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 4),
                                          width: double.infinity,
                                          height: 0.5,
                                          color: Colors.grey),
                                      doubleRows(
                                          "Số điện thoại", "Email", true),
                                      SizedBox(height: 4),
                                      doubleRows(
                                          _members[index].phoneNumber ?? "",
                                          _members[index].email ?? "",
                                          false),
                                      Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 4),
                                          width: double.infinity,
                                          height: 0.5,
                                          color: Colors.grey),
                                      doubleRows("Ngày tham gia",
                                          "Ngày đóng tiền", true),
                                      SizedBox(height: 4),
                                      doubleRows(
                                          _members[index].joinedDate ?? "",
                                          _members[index].paymentDate ?? "",
                                          false),
                                      Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 4),
                                          width: double.infinity,
                                          height: 0.5,
                                          color: Colors.grey),
                                      Text("Số tiền",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      SizedBox(height: 4),
                                      Text(
                                          '${_members[index].amount ?? ""} / ${_members[index].joiningFeePeriod ?? ""}',
                                          style: TextStyle(fontSize: 16)),
                                      Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 4),
                                          width: double.infinity,
                                          height: 0.5,
                                          color: Colors.grey),
                                      Text("Ngày cập nhật",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      SizedBox(height: 4),
                                      Text(_members[index].modifiedDate ?? "",
                                          style: TextStyle(fontSize: 16)),
                                      Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 4),
                                          width: double.infinity,
                                          height: 0.5,
                                          color: Colors.grey),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          iconAction(ACTION_TYPE.MESSAGE,
                                              index: index),
                                          iconAction(ACTION_TYPE.EDIT,
                                              index: index),
                                          iconAction(ACTION_TYPE.REMIND,
                                              index: index),
                                          iconAction(ACTION_TYPE.DETAIL,
                                              index: index),
                                          iconAction(ACTION_TYPE.DELETE,
                                              index: index),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      }
                      return Center(
                          child: Text(
                        "Chưa có thành viên nào",
                        style: TextStyle(fontSize: 18),
                      ));
                  }
                }
                return CircularProgressIndicator();
              }),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context)
                .pushNamed(AddMemberPage.ROUTE_NAME)
                .then((value) {
              if (value == 1) {
                _members.clear();
                _memberBloc.requestGetMembers(0);
              }
            });
          },
          label: Text('Thêm thành viên'),
          icon: Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  Icon iconByType(ACTION_TYPE type) {
    switch (type) {
      case ACTION_TYPE.MESSAGE:
        return Icon(Icons.messenger, color: Colors.indigoAccent);
      case ACTION_TYPE.EDIT:
        return Icon(Icons.edit, color: Colors.green);
      case ACTION_TYPE.REMIND:
        return Icon(Icons.notifications_active_rounded, color: Colors.yellow);
      case ACTION_TYPE.DETAIL:
        return Icon(Icons.person_search, color: Colors.blue);
      case ACTION_TYPE.DELETE:
        return Icon(Icons.delete, color: Colors.red);
      default:
        return Icon(Icons.messenger, color: Colors.indigoAccent);
    }
  }

  void onPress(ACTION_TYPE type, {int index}) {
    switch (type) {
      case ACTION_TYPE.MESSAGE:
        Navigator.of(context).pushNamed(ChatPage.ROUTE_NAME,
            arguments: {"memberId": _members[index].memberId});
        break;
      case ACTION_TYPE.EDIT:
        Navigator.of(context)
            .pushNamed(UpdateMemberPage.ROUTE_NAME, arguments: _members[index])
            .then((value) {
          if (value == 1) {
            _members.clear();
            _memberBloc.requestGetMembers(0);
          }
        });
        break;
      case ACTION_TYPE.REMIND:
        sendNotify(_members[index].id);
        break;
      case ACTION_TYPE.DETAIL:
        Navigator.of(context).pushNamed(MemberDetailPage.ROUTE_NAME,
            arguments: _members[index].id);
        break;
      case ACTION_TYPE.DELETE:
        Helper.showDeleteDialog(context, "Xóa thành viên",
            "Bạn có chắc chắn muốn xóa thành viên này?", () async {
          final result =
              await _memberBloc.requestDeleteMember(_members[index].id);
          if (result) {
            //_members.removeWhere((element) => element.id == _members[index].id);
            _members.clear();
            _memberBloc.requestGetMembers(0);
            setState(() {

            });
            Navigator.of(context).pop();
          } else {
            Fluttertoast.showToast(
                msg: "Vui lòng thử lại", gravity: ToastGravity.CENTER);
          }
        });
        break;
      default:
        break;
    }
  }

  void sendNotify(String id) async {
    String result = await _memberBloc.requestGetNote(id);
    Helper.showRemindDialog(context, result, (message) {
      var requestParam = jsonEncode({"id": id, "notes": message});
      _memberBloc.requestNotifyPayment(requestParam);
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: "Gửi thông báo thành công", textColor: Colors.black87);
    });
  }

  Widget iconAction(ACTION_TYPE type, {int index}) {
    return IconButton(
        icon: iconByType(type), onPressed: () => onPress(type, index: index));
  }

  Widget doubleRows(String strFirst, strSecond, bool bold) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(strFirst,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w400,
                  fontSize: 16)),
        ),
        Expanded(
          child: Text(strSecond,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w400,
                  fontSize: 16)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _memberBloc.dispose();
  }
}
