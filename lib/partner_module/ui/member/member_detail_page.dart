import 'dart:convert';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/partner_module/models/members_response.dart';
import 'package:conecapp/partner_module/ui/member/swap_group.dart';
import 'package:conecapp/ui/chat/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'add_member_page.dart';
import 'complete_update_payment.dart';
import 'member_bloc.dart';
import 'update_member_page.dart';

enum PAYMENT_TYPE { UPDATE, COMPLETE }

class MemberDetailPage extends StatefulWidget {
  static const ROUTE_NAME = '/member-detail';

  @override
  _MemberDetailPageState createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  MemberBloc _memberBloc = MemberBloc();
  Member _member = Member();
  String id;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _member = ModalRoute.of(context).settings.arguments;
    id = _member.id;
    _memberBloc.requestGetMemberDetail(id);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(_member.name ?? ""),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                // _member.memberId != null
                //     ? PopupMenuItem(
                //         value: 'message',
                //         child: Text('Gửi tin nhắn'),
                //       )
                //     : null,
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Chỉnh sửa'),
                ),
                _member.memberId != null
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
                    style: TextStyle(color: Colors.red),
                  ),
                )
              ];
            },
            onSelected: (String value) {
              switch (value) {
                case 'message':
                  Navigator.of(context).pushNamed(ChatPage.ROUTE_NAME,
                      arguments: {"memberId": _member.memberId});
                  break;
                case 'edit':
                  Navigator.of(context)
                      .pushNamed(UpdateMemberPage.ROUTE_NAME,
                          arguments: _member)
                      .then((value) {
                    if (value == 1) {
                      _memberBloc.requestGetMemberDetail(id);
                    }
                  });
                  break;
                case 'notify':
                  sendNotify(_member.id);
                  break;
                case 'swap':
                  Navigator.of(context)
                      .pushNamed(SwapGroup.ROUTE_NAME, arguments: _member)
                      .then((value) {
                    if (value == 1) {
                      _memberBloc.requestGetMemberDetail(id);
                    }
                  });
                  break;
                case 'delete':
                  Helper.showDeleteDialog(context, "Xóa thành viên",
                      "Bạn có chắc chắn muốn xóa thành viên này?", () async {
                    final result =
                        await _memberBloc.requestDeleteMember(_member.id);
                    if (result) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    } else {
                      Fluttertoast.showToast(
                          msg: "Vui lòng thử lại",
                          gravity: ToastGravity.CENTER);
                    }
                  });
                  break;
              }
            },
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: StreamBuilder<ApiResponse<Member>>(
              stream: _memberBloc.memberDetailStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  switch (snapshot.data.status) {
                    case Status.LOADING:
                      return UILoading(loadingMessage: snapshot.data.message);
                    case Status.ERROR:
                      return UIError(errorMessage: snapshot.data.message);
                    case Status.COMPLETED:
                      _member = snapshot.data.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // infoCard(_member.userName ?? "Tên tài khoản",
                                  //     TYPE.ACCOUNT),
                                  // SizedBox(height: 8),
                                  // infoCard(_member.name ?? "Họ tên", TYPE.NAME),
                                  // SizedBox(height: 8),
                                  // infoCard(_member.phoneNumber ?? "Số điện thoại",
                                  //     TYPE.PHONE),
                                  // SizedBox(height: 8),
                                  // infoCard(_member.email ?? "Email", TYPE.EMAIL),
                                  doubleRowsWithFlex("Email", _member.email ?? ""),
                                  SizedBox(height: 8),
                                  doubleRows2("Số điện thoại",
                                      _member.phoneNumber ?? ""),
                                  SizedBox(height: 8),
                                  doubleRows2(
                                      "Nhóm / lớp", _member.groupName ?? ""),
                                  SizedBox(height: 8),
                                  doubleRows2("Ngày tham gia",
                                      _member.joinedDate ?? ""),
                                  SizedBox(height: 8),
                                  doubleRowsWithFlex("Ngày thanh toán kế tiếp",
                                      _member.paymentDate ?? ""),
                                  SizedBox(height: 8),
                                  doubleRows2("Phí tham gia",
                                      '${Helper.formatMoney(_member.amount)} / ${_member.joiningFeePeriod}'),
                                  SizedBox(height: 8),
                                  doubleRows2("Ghi chú", _member.notes ?? ""),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                FlatButton.icon(
                                    onPressed: _member.memberId != null
                                        ? () {
                                            Navigator.of(context).pushNamed(
                                                ChatPage.ROUTE_NAME,
                                                arguments: {
                                                  "memberId": _member.memberId
                                                });
                                          }
                                        : null,
                                    icon: Icon(Icons.messenger,
                                        color: _member.memberId == null
                                            ? Colors.grey[300]
                                            : Colors.indigoAccent),
                                    label: Text("Nhắn tin")),
                                FlatButton.icon(
                                    onPressed: _member.memberId != null
                                        ? () {
                                            sendNotify(_member.id);
                                          }
                                        : null,
                                    icon: Icon(Icons.notifications,
                                        color: _member.memberId == null
                                            ? Colors.grey[300]
                                            : Colors.yellow),
                                    label: Text("Nhắc nhỡ đóng tiền"))
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          Text("Danh sách thanh toán"),
                          SizedBox(height: 4),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _member.payments.length,
                              itemBuilder: (context, index) {
                                List<Payment> _payment = _member.payments;
                                return Stack(
                                  children: [
                                    Card(
                                      elevation: 5,
                                      color: _payment[index].paymentDate != null
                                          ? Colors.green[300]
                                          : Colors.red[300],
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            doubleRows("Ngày đóng dự kiến",
                                                _payment[index].created ?? ""),
                                            SizedBox(height: 6),
                                            doubleRows(
                                                "Số tiền dự kiến",
                                                Helper.formatMoney(
                                                    _payment[index].amount)),
                                            Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 4),
                                                width: double.infinity,
                                                height: 0.5,
                                                color: Colors.grey),
                                            doubleRows(
                                                "Ngày đóng",
                                                _payment[index].paymentDate ??
                                                    ""),
                                            SizedBox(height: 6),
                                            doubleRows(
                                              "Số tiền",
                                              Helper.formatMoney(_payment[index]
                                                  .paymentAmount),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    _payment[index].paymentDate == null
                                        ? Positioned(
                                            right: -8,
                                            top: -4,
                                            child: PopupMenuButton(
                                              itemBuilder: (context) {
                                                return [
                                                  PopupMenuItem(
                                                    value: 'complete',
                                                    child: Text('Thanh toán'),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'update',
                                                    child: Text('Chỉnh sửa'),
                                                  ),
                                                ];
                                              },
                                              onSelected: (String value) {
                                                switch (value) {
                                                  case 'complete':
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            CompleteUpdatePayment
                                                                .ROUTE_NAME,
                                                            arguments: {
                                                          "payment": _member
                                                              .payments[index],
                                                          "type": PAYMENT_TYPE
                                                              .COMPLETE
                                                        }).then((value) {
                                                      if (value == 1) {
                                                        _memberBloc
                                                            .requestGetMemberDetail(
                                                                id);
                                                      }
                                                    });
                                                    break;
                                                  case 'update':
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            CompleteUpdatePayment
                                                                .ROUTE_NAME,
                                                            arguments: {
                                                          "payment": _member
                                                              .payments[index],
                                                          "type": PAYMENT_TYPE
                                                              .UPDATE
                                                        }).then((value) {
                                                      if (value == 1) {
                                                        _memberBloc
                                                            .requestGetMemberDetail(
                                                                id);
                                                      }
                                                    });
                                                    break;
                                                }
                                              },
                                            ),
                                          )
                                        : Container()
                                  ],
                                );
                              })
                        ],
                      );
                  }
                }
                return Center(child: CircularProgressIndicator());
              }),
        ),
      ),
    ));
  }

  Icon iconByType(TYPE type) {
    switch (type) {
      case TYPE.ACCOUNT:
        return Icon(Icons.info, color: Colors.blue);
      case TYPE.NAME:
        return Icon(Icons.perm_identity_rounded, color: Colors.blue);
      case TYPE.PHONE:
        return Icon(Icons.phone_android, color: Colors.blue);
      case TYPE.EMAIL:
        return Icon(Icons.email, color: Colors.blue);
      default:
        return Icon(Icons.email, color: Colors.blue);
    }
  }

  Widget infoCard(String info, TYPE type) {
    return InkWell(
      onTap: null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: <Widget>[
            iconByType(type),
            SizedBox(width: 16),
            Text(
              info,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }

  Widget doubleRows(String strFirst, strSecond) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(strFirst,
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
        ),
        Expanded(
          child: Text(strSecond,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }

  Widget doubleRows2(String strFirst, strSecond) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(strFirst,
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
        ),
        Expanded(
          child: Text(strSecond,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }

  Widget doubleRowsWithFlex(String strFirst, strSecond) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(strFirst,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
        Spacer(),
        Container(
          alignment: Alignment.centerRight,
          child: Text(strSecond,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }
}
