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
    id = ModalRoute.of(context).settings.arguments;
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
      appBar: AppBar(title: Text("Thông tin thành viên"), actions: [
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              _member.memberId != null ? PopupMenuItem(
                value: 'message',
                child: Text('Gửi tin nhắn'),
              ) : null,
              PopupMenuItem(
                value: 'edit',
                child: Text('Chỉnh sửa'),
              ),
              _member.memberId != null ? PopupMenuItem(
                value: 'notify',
                child: Text('Nhắc nhỡ'),
              ) : null,
              PopupMenuItem(
                value: 'swap',
                child: Text('Chuyển lớp'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Xóa lớp', style: TextStyle(color: Colors.red),),
              )
            ];
          },
          onSelected: (String value) {
            switch(value){
              case 'message':
                Navigator.of(context).pushNamed(ChatPage.ROUTE_NAME,
                    arguments: {"memberId": _member.memberId});
                break;
              case 'edit':
                Navigator.of(context)
                    .pushNamed(UpdateMemberPage.ROUTE_NAME, arguments: _member)
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
                Navigator.of(context).pushNamed(SwapGroup.ROUTE_NAME, arguments: _member).then((value) {
                  if(value == 1){
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
                            msg: "Vui lòng thử lại", gravity: ToastGravity.CENTER);
                      }
                    });
                break;
            }
          },
        )
      ],),
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
                            margin: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 12),
                                infoCard(_member.userName ?? "Tên tài khoản",
                                    TYPE.ACCOUNT),
                                SizedBox(height: 8),
                                infoCard(_member.name ?? "Họ tên", TYPE.NAME),
                                SizedBox(height: 8),
                                infoCard(_member.phoneNumber ?? "Số điện thoại",
                                    TYPE.PHONE),
                                SizedBox(height: 8),
                                infoCard(_member.email ?? "Email", TYPE.EMAIL),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text("Nhóm / lớp"),
                          Card(
                            child: Card(
                              margin: EdgeInsets.symmetric(horizontal: 0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(Icons.group, color: Colors.blue),
                                    SizedBox(width: 16),
                                    Text(
                                      _member.groupName ?? "",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text("Ngày tham gia"),
                          Card(
                            child: Card(
                              margin: EdgeInsets.symmetric(horizontal: 0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(Icons.date_range, color: Colors.blue),
                                    SizedBox(width: 16),
                                    Text(
                                      _member.joinedDate ?? "",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text("Ngày thanh toán kế tiếp"),
                          Card(
                            child: Card(
                              margin: EdgeInsets.symmetric(horizontal: 0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(Icons.monetization_on, color: Colors.blue),
                                    SizedBox(width: 16),
                                    Text(
                                      _member.paymentDate ?? "",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Phí tham gia"),
                              SizedBox(height: 4),
                              TextFormField(
                                maxLines: 1,
                                enabled: false,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                style: TextStyle(fontSize: 18),
                                decoration: InputDecoration(
                                    labelText:
                                        '${_member.amount} / ${_member.joiningFeePeriod}',
                                    hintText: 'Nhập phí tham gia',
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.green, width: 1)),
                                    contentPadding: EdgeInsets.only(left: 8),
                                    prefixIcon: Icon(
                                      Icons.attach_money,
                                      color: Colors.blue,
                                    ),
                                    border: const OutlineInputBorder()),
                              ),
                              SizedBox(
                                height: 12,
                              )
                            ],
                          ),
                          SizedBox(height: 8),
                          Text("Ghi chú"),
                          SizedBox(height: 4),
                          Text(_member.notes ?? ""),
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
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Ngày đóng dự kiến",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                            SizedBox(height: 4),
                                            Text(_payment[index].created ?? "",
                                                style: TextStyle(fontSize: 16)),
                                            Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 4),
                                                width: double.infinity,
                                                height: 0.5,
                                                color: Colors.grey),
                                            Text("Số tiền dự kiến",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                            SizedBox(height: 4),
                                            Text(
                                                _payment[index]
                                                        .amount
                                                        .toString() ??
                                                    "",
                                                style: TextStyle(fontSize: 16)),
                                            Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 4),
                                                width: double.infinity,
                                                height: 0.5,
                                                color: Colors.grey),
                                            Text("Ngày đóng",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                            SizedBox(height: 4),
                                            Text(
                                                _payment[index].paymentDate ??
                                                    "",
                                                style: TextStyle(fontSize: 16)),
                                            Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 4),
                                                width: double.infinity,
                                                height: 0.5,
                                                color: Colors.grey),
                                            Text("Số tiền",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                            SizedBox(height: 4),
                                            Text(
                                                _payment[index].paymentAmount !=
                                                        null
                                                    ? _payment[index]
                                                        .paymentAmount
                                                        .toString()
                                                    : "",
                                                style: TextStyle(fontSize: 16)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 10,
                                      top: 6,
                                      child: Row(
                                        children: [
                                          IconButton(
                                              icon: Icon(Icons.edit,
                                                  color: Colors.blue, size: 30),
                                              onPressed: () {
                                                Navigator.of(context).pushNamed(
                                                    CompleteUpdatePayment
                                                        .ROUTE_NAME,
                                                    arguments: {
                                                      "payment": _member
                                                          .payments[index],
                                                      "type":
                                                          PAYMENT_TYPE.UPDATE
                                                    }).then((value) {
                                                  if (value == 1) {
                                                    _memberBloc
                                                        .requestGetMemberDetail(
                                                            id);
                                                  }
                                                });
                                              }),
                                          IconButton(
                                              icon: Icon(Icons.check_box,
                                                  color: Colors.green,
                                                  size: 30),
                                              onPressed: () {
                                                Navigator.of(context).pushNamed(
                                                    CompleteUpdatePayment
                                                        .ROUTE_NAME,
                                                    arguments: {
                                                      "payment": _member
                                                          .payments[index],
                                                      "type":
                                                          PAYMENT_TYPE.COMPLETE
                                                    }).then((value) {
                                                  if (value == 1) {
                                                    _memberBloc
                                                        .requestGetMemberDetail(
                                                            id);
                                                  }
                                                });
                                              })
                                        ],
                                      ),
                                    )
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
}
