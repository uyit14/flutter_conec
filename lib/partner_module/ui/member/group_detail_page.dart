import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/partner_module/models/group_response.dart';
import 'package:conecapp/partner_module/models/members_response.dart';
import 'package:conecapp/partner_module/ui/member/member_bloc.dart';
import 'package:conecapp/partner_module/ui/member/swap_group.dart';
import 'package:conecapp/partner_module/ui/member/update_member_page.dart';
import 'package:conecapp/ui/chat/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'add_member_page.dart';
import 'member_detail_page.dart';

class GroupDetailPage extends StatefulWidget {
  static const ROUTE_NAME = '/group-detail';

  @override
  _GroupDetailPageState createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  Group _group;
  List<Member> _members = List();
  MemberBloc _memberBloc = MemberBloc();
  ScrollController _scrollController;
  bool _shouldLoadMore = true;
  int _currentPage = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context).settings.arguments;
    _group = routeArgs;
    _memberBloc.requestGetMembers(_currentPage,
        userGroupId: _group.userGroupId);
    _currentPage = 1;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 250) {
      if (_shouldLoadMore) {
        _shouldLoadMore = false;
        _memberBloc.requestGetMembers(_currentPage,
            userGroupId: _group.userGroupId);
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
        appBar: AppBar(
          title: Text(_group.name ?? "Chi tiết"),
          actions: [
            Center(
              child: Badge(
                padding: const EdgeInsets.all(8),
                position: BadgePosition.topEnd(top: 0, end: 0),
                badgeContent: Text(
                  _group.memberCount.toString() ?? "0",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                badgeColor: Colors.yellow,
                showBadge: true,
              ),
            ),
            SizedBox(width: 16),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6),
                Text("  Thông tin nhóm",
                    style:
                        TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                SizedBox(height: 4),
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Text("Tên nhóm",
                        //     style: TextStyle(
                        //         fontWeight: FontWeight.w400, fontSize: 12)),
                        // SizedBox(
                        //   height: 4,
                        // ),
                        // Text(_group.name,
                        //     maxLines: 1,
                        //     overflow: TextOverflow.ellipsis,
                        //     style: TextStyle(
                        //         fontWeight: FontWeight.bold, fontSize: 16)),
                        // Container(
                        //     margin: EdgeInsets.symmetric(vertical: 4),
                        //     width: double.infinity,
                        //     height: 0.5,
                        //     color: Colors.grey),
                        // Text("Số lượng thành viên",
                        //     style: TextStyle(
                        //         fontWeight: FontWeight.w400, fontSize: 12)),
                        // SizedBox(
                        //   height: 4,
                        // ),
                        // Text(_group.memberCount.toString(),
                        //     style: TextStyle(
                        //         fontWeight: FontWeight.w500, fontSize: 15)),
                        // Container(
                        //     margin: EdgeInsets.symmetric(vertical: 4),
                        //     width: double.infinity,
                        //     height: 0.5,
                        //     color: Colors.grey),
                        Row(
                          children: [
                            Text("Thời gian tập luyện: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 12)),
                            Text(_group.times ?? "",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 15)),
                          ],
                        ),
                        //doubleRows("Thời gian tập luyện", _group.times.toString()),
                        // Container(
                        //     margin: EdgeInsets.symmetric(vertical: 4),
                        //     width: double.infinity,
                        //     height: 0.5,
                        //     color: Colors.grey),
                        Row(
                          children: [
                            Text("Ghi chú:  ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 12)),
                            Text(_group.notes ?? "",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: FlatButton.icon(
                      onPressed: () {
                        Helper.showDeleteDialog(context, "Xóa nhóm",
                            "Bạn có chắc chắn muốn xóa nhóm này?", () async {
                          final result = await _memberBloc
                              .requestDeleteGroup(_group.userGroupId);
                          if (result) {
                            Fluttertoast.showToast(
                                msg: "Xóa thành công",
                                gravity: ToastGravity.CENTER);
                            Navigator.of(context).pop(1);
                            Navigator.of(context).pop(1);
                          } else {
                            Navigator.of(context)
                                .pop();
                            Fluttertoast.showToast(
                                msg: "Vui lòng thử lại",
                                gravity: ToastGravity.CENTER);
                          }
                        });
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      label: Text(
                        "Xóa nhóm",
                        style: TextStyle(color: Colors.red),
                      )),
                ),
                SizedBox(height: 12),
                Text("    Danh sách thành viên",
                    style:
                        TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                Container(
                  margin:
                      EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 50),
                  child: StreamBuilder<ApiResponse<List<Member>>>(
                      stream: _memberBloc.membersStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          switch (snapshot.data.status) {
                            case Status.LOADING:
                              return UILoading(
                                  loadingMessage: snapshot.data.message);
                            case Status.ERROR:
                              return UIError(
                                  errorMessage: snapshot.data.message);
                            case Status.COMPLETED:
                              if (snapshot.data.data.length > 0) {
                                print("at UI: " +
                                    snapshot.data.data.length.toString());
                                _members.addAll(snapshot.data.data);
                                _shouldLoadMore = true;
                              } else {
                                _shouldLoadMore = false;
                              }
                              if (_members.length > 0) {
                                return ListView.builder(
                                    itemCount: _members.length,
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return Stack(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context)
                                                  .pushNamed(
                                                      MemberDetailPage
                                                          .ROUTE_NAME,
                                                      arguments:
                                                          _members[index])
                                                  .then((value) {
                                                _members.clear();
                                                _memberBloc.requestGetMembers(0,
                                                    userGroupId:
                                                        _group.userGroupId);
                                              });
                                            },
                                            child: Card(
                                              elevation: 5,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 20,
                                                          backgroundColor:
                                                              Colors.grey,
                                                          backgroundImage: _members[
                                                                          index]
                                                                      .avatar !=
                                                                  null
                                                              ? NetworkImage(
                                                                  _members[
                                                                          index]
                                                                      .avatar)
                                                              : AssetImage(
                                                                  "assets/images/avatar.png"),
                                                        ),
                                                        _members[index]
                                                                    .memberId ==
                                                                null
                                                            ? Positioned(
                                                                left: -4,
                                                                top: -4,
                                                                child: Icon(
                                                                  Icons
                                                                      .warning_amber_rounded,
                                                                  color: Colors
                                                                      .deepOrangeAccent,
                                                                  size: 24,
                                                                ))
                                                            : Container()
                                                      ],
                                                    ),
                                                    SizedBox(width: 8),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              110,
                                                          child: Text(
                                                              _members[index]
                                                                      .name ??
                                                                  "",
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      16)),
                                                        ),
                                                        SizedBox(height: 4),
                                                        // Text(_members[index].name ?? "",
                                                        //     style:
                                                        //         TextStyle(fontSize: 16)),
                                                        Row(
                                                          children: [
                                                            Text(
                                                                "Ngày đóng tiền:  ",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize:
                                                                        12)),
                                                            Text(
                                                                _members[index]
                                                                        .paymentDate ??
                                                                    "",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                )),
                                                          ],
                                                        ),
                                                        // doubleRows("Số điện thoại",
                                                        //     "Email", true),
                                                        // SizedBox(height: 4),
                                                        // doubleRows(
                                                        //     _members[index].phoneNumber ??
                                                        //         "",
                                                        //     _members[index].email ?? "",
                                                        //     false),
                                                        // Container(
                                                        //     margin: EdgeInsets.symmetric(
                                                        //         vertical: 4),
                                                        //     width: double.infinity,
                                                        //     height: 0.5,
                                                        //     color: Colors.grey),
                                                        // doubleRows("Ngày tham gia",
                                                        //     "Ngày đóng tiền", true),
                                                        // SizedBox(height: 4),
                                                        // doubleRows(
                                                        //     _members[index].joinedDate ??
                                                        //         "",
                                                        //     _members[index].paymentDate ??
                                                        //         "",
                                                        //     false),
                                                        // Container(
                                                        //     margin: EdgeInsets.symmetric(
                                                        //         vertical: 4),
                                                        //     width: double.infinity,
                                                        //     height: 0.5,
                                                        //     color: Colors.grey),
                                                        // Text("Số tiền",
                                                        //     style: TextStyle(
                                                        //         fontWeight:
                                                        //             FontWeight.w400,
                                                        //         fontSize: 12)),
                                                        // SizedBox(height: 4),
                                                        // Text(
                                                        //     '${_members[index].amount ?? ""} / ${_members[index].joiningFeePeriod ?? ""}',
                                                        //     style:
                                                        //         TextStyle(fontSize: 14, fontWeight:
                                                        //         FontWeight.w500,)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 8,
                                            child: PopupMenuButton(
                                              itemBuilder: (context) {
                                                return [
                                                  _members[index].memberId != null
                                                      ? PopupMenuItem(
                                                          value: 'message',
                                                          child: Text('Gửi tin nhắn'),
                                                        )
                                                      : null,
                                                  PopupMenuItem(
                                                    value: 'edit',
                                                    child: Text('Chỉnh sửa'),
                                                  ),
                                                  _members[index].memberId != null
                                                      ? PopupMenuItem(
                                                          value: 'notify',
                                                          child: Text('Nhắc nhỡ đóng tiền'),
                                                        )
                                                      : null,
                                                  PopupMenuItem(
                                                    value: 'swap',
                                                    child: Text('Chuyển lớp'),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text(
                                                      'Xóa thành viên',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  )
                                                ];
                                              },
                                              onSelected: (String value) {
                                                switch (value) {
                                                  case 'message':
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            ChatPage.ROUTE_NAME,
                                                            arguments: {
                                                          "memberId":
                                                              _members[index]
                                                                  .memberId
                                                        });
                                                    break;
                                                  case 'edit':
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            UpdateMemberPage
                                                                .ROUTE_NAME,
                                                            arguments:
                                                                _members[index])
                                                        .then((value) {
                                                      if (value == 1) {
                                                        _members.clear();
                                                        _memberBloc
                                                            .requestGetMembers(
                                                                0,
                                                                userGroupId: _group
                                                                    .userGroupId);
                                                      }
                                                    });
                                                    break;
                                                  case 'notify':
                                                    sendNotify(
                                                        _members[index].id);
                                                    break;
                                                  case 'swap':
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            SwapGroup
                                                                .ROUTE_NAME,
                                                            arguments:
                                                                _members[index])
                                                        .then((value) {
                                                      if (value == 1) {
                                                        _members.clear();
                                                        _memberBloc
                                                            .requestGetMembers(
                                                                0,
                                                                userGroupId: _group
                                                                    .userGroupId);
                                                      }
                                                    });
                                                    break;
                                                  case 'delete':
                                                    Helper.showDeleteDialog(
                                                        context,
                                                        "Xóa thành viên",
                                                        "Bạn có chắc chắn muốn xóa thành viên này?",
                                                        () async {
                                                      final result =
                                                          await _memberBloc
                                                              .requestDeleteMember(
                                                                  _members[
                                                                          index]
                                                                      .id);
                                                      if (result) {
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.of(context)
                                                            .pop();
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Vui lòng thử lại",
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER);
                                                      }
                                                    });
                                                    break;
                                                }
                                              },
                                            ),
                                          )
                                        ],
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
                )
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context)
                .pushNamed(AddMemberPage.ROUTE_NAME, arguments: _group)
                .then((value) {
              if (value == 1) {
                _members.clear();
                _memberBloc.requestGetMembers(0,
                    userGroupId: _group.userGroupId);
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

  Widget doubleRows(String strFirst, strSecond) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(strFirst,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16)),
        ),
        Expanded(
          child: Text(strSecond,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
      ],
    );
  }
}