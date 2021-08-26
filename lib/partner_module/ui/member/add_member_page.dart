import 'dart:convert';
import 'dart:io';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_loading_opacity.dart';
import 'package:conecapp/partner_module/models/group_response.dart';
import 'package:conecapp/partner_module/models/member_request.dart';
import 'package:conecapp/partner_module/models/search_m_response.dart';
import 'package:conecapp/partner_module/ui/member/member_bloc.dart';
import 'package:conecapp/partner_module/ui/member/search_group.dart';
import 'package:conecapp/partner_module/ui/member/search_member_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'add_custom_member.dart';

enum TYPE { ACCOUNT, NAME, PHONE, EMAIL }

class AddMemberPage extends StatefulWidget {
  static const ROUTE_NAME = '/add-member';

  @override
  _AddMemberPageState createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  MemberBloc _memberBloc = MemberBloc();
  var _paymentDate;
  //var _joinDate;
  int _selectedType;
  Group _group;
  bool _isLoading = false;
  String _type = "";
  MemberSearch _member = MemberSearch();
  TextEditingController _joiningFreeController = TextEditingController();
  TextEditingController _noteController = TextEditingController();

  ImageProvider avatarImage(File local, String url) {
    if (local != null) return FileImage(local);
    if (url != null) return NetworkImage(url);
    return AssetImage("assets/images/avatar.png");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context).settings.arguments;
    _group = routeArgs;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text("Thêm thành viên")),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FlatButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(CustomMemberPage.ROUTE_NAME)
                                .then((value) {
                              if (value != null) {
                                setState(() {
                                  _member = value;
                                });
                                print(_member.name);
                              }
                            });
                          },
                          icon: Icon(Icons.person_add, color: Colors.green),
                          label: Text("Thêm mới")),
                      FlatButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(SearchMemberPage.ROUTE_NAME)
                                .then((value) {
                              if (value != null) {
                                setState(() {
                                  _member = value;
                                });
                                print(_member.name);
                              }
                            });
                          },
                          icon: Icon(Icons.search, color: Colors.blue),
                          label: Text("Tìm kiếm")),
                    ],
                  ),
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12),
                        Row(
                          children: [
                            infoCard(_member.userName ?? "Tên tài khoản",
                                TYPE.ACCOUNT),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey,
                              backgroundImage: avatarImage(
                                  _member.avatarSource, _member.avatar),
                            )
                          ],
                        ),
                        SizedBox(height: 8),
                        infoCard(_member.name ?? "Họ tên", TYPE.NAME),
                        SizedBox(height: 8),
                        infoCard(
                            _member.phoneNumber ?? "Số điện thoại", TYPE.PHONE),
                        SizedBox(height: 8),
                        infoCard(_member.email ?? "Email", TYPE.EMAIL),
                      ],
                    ),
                  ),
                  Text("Nhóm / Lớp"),
                  Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(SearchGroupPage.ROUTE_NAME)
                            .then((value) {
                          if (value != null) {
                            setState(() {
                              _group = value;
                            });
                          }
                        });
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.group),
                              SizedBox(width: 16),
                              Text(
                                _group != null
                                    ? _group.name
                                    : "Chọn nhóm / lớp",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Spacer(),
                              Text("Thay đổi",
                                  style: AppTheme.changeTextStyle(true))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(height: 8),
                  // Text("Ngày tham gia"),
                  // Card(
                  //   child: InkWell(
                  //     onTap: () {
                  //       DatePicker.showDatePicker(context,
                  //           showTitleActions: true,
                  //           minTime: DateTime(1945, 1, 1),
                  //           maxTime: DateTime(2030, 31, 12),
                  //           theme: DatePickerTheme(
                  //               headerColor: Colors.orange,
                  //               backgroundColor: Colors.blue,
                  //               itemStyle: TextStyle(
                  //                   color: Colors.white,
                  //                   fontWeight: FontWeight.bold,
                  //                   fontSize: 18),
                  //               doneStyle: TextStyle(
                  //                   color: Colors.white,
                  //                   fontSize: 16)), onChanged: (date) {
                  //         setState(() {
                  //           _joinDate = date != null ? date : null;
                  //         });
                  //       }, onConfirm: (date) {
                  //         setState(() {
                  //           _joinDate = date != null ? date : null;
                  //         });
                  //       },
                  //           currentTime: _joinDate.toString().contains("0001")
                  //               ? DateTime(2000, 6, 16)
                  //               : _joinDate,
                  //           locale: LocaleType.vi);
                  //     },
                  //     child: Card(
                  //       margin: EdgeInsets.symmetric(horizontal: 0),
                  //       child: Padding(
                  //         padding: const EdgeInsets.symmetric(
                  //             vertical: 12, horizontal: 8),
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.start,
                  //           children: <Widget>[
                  //             Icon(Icons.date_range),
                  //             SizedBox(width: 16),
                  //             Text(
                  //               _joinDate != null
                  //                   ? DateFormat('dd-MM-yyyy').format(
                  //                       _joinDate ?? DateTime(2000, 6, 16))
                  //                   : "Chọn ngày",
                  //               textAlign: TextAlign.left,
                  //               style: TextStyle(
                  //                   fontSize: 16, fontWeight: FontWeight.w500),
                  //             ),
                  //             Spacer(),
                  //             Text("Thay đổi",
                  //                 style: AppTheme.changeTextStyle(true))
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 8),
                  Text("Ngày thanh toán kế tiếp"),
                  Card(
                    child: InkWell(
                      onTap: () {
                        DatePicker.showDatePicker(context,
                            showTitleActions: true,
                            minTime: DateTime(1945, 1, 1),
                            maxTime: DateTime(2030, 31, 12),
                            theme: DatePickerTheme(
                                headerColor: Colors.orange,
                                backgroundColor: Colors.blue,
                                itemStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                                doneStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16)), onChanged: (date) {
                          setState(() {
                            _paymentDate = date != null ? date : null;
                          });
                        }, onConfirm: (date) {
                          setState(() {
                            _paymentDate = date != null ? date : null;
                          });
                        },
                            currentTime:
                                _paymentDate.toString().contains("0001")
                                    ? DateTime(2000, 6, 16)
                                    : _paymentDate,
                            locale: LocaleType.vi);
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.monetization_on),
                              SizedBox(width: 16),
                              Text(
                                _paymentDate != null
                                    ? DateFormat('dd-MM-yyyy').format(
                                        _paymentDate ?? DateTime(2000, 6, 16))
                                    : "Chọn ngày",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Spacer(),
                              Text("Thay đổi",
                                  style: AppTheme.changeTextStyle(true))
                            ],
                          ),
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
                        controller: _joiningFreeController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                            hintText: 'Nhập phí tham gia',
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.green, width: 1)),
                            contentPadding: EdgeInsets.only(left: 8),
                            prefixIcon: Icon(
                              Icons.attach_money,
                              color: Colors.black,
                            ),
                            border: const OutlineInputBorder()),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: _selectedType == 0
                                            ? Colors.red
                                            : Colors.grey,
                                        width: 1,
                                        style: BorderStyle.solid),
                                    borderRadius: BorderRadius.circular(50)),
                                textColor: _selectedType == 0
                                    ? Colors.red
                                    : Colors.grey,
                                onPressed: () {
                                  setState(() {
                                    _type = "Giờ";
                                    _selectedType = 0;
                                  });
                                },
                                child: Text("Giờ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold))),
                          ),
                          SizedBox(width: 3),
                          Expanded(
                            child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: _selectedType == 1
                                            ? Colors.red
                                            : Colors.grey,
                                        width: 1,
                                        style: BorderStyle.solid),
                                    borderRadius: BorderRadius.circular(50)),
                                textColor: _selectedType == 1
                                    ? Colors.red
                                    : Colors.grey,
                                onPressed: () {
                                  setState(() {
                                    _type = "Ngày";
                                    _selectedType = 1;
                                  });
                                },
                                child: Text("Ngày",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold))),
                          ),
                          SizedBox(width: 3),
                          Expanded(
                            child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: _selectedType == 2
                                            ? Colors.red
                                            : Colors.grey,
                                        width: 1,
                                        style: BorderStyle.solid),
                                    borderRadius: BorderRadius.circular(50)),
                                textColor: _selectedType == 2
                                    ? Colors.red
                                    : Colors.grey,
                                onPressed: () {
                                  setState(() {
                                    _type = "Tháng";
                                    _selectedType = 2;
                                  });
                                },
                                child: Text("Tháng",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold))),
                          ),
                          SizedBox(width: 3),
                          Expanded(
                            child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: _selectedType == 3
                                            ? Colors.red
                                            : Colors.grey,
                                        width: 1,
                                        style: BorderStyle.solid),
                                    borderRadius: BorderRadius.circular(50)),
                                textColor: _selectedType == 3
                                    ? Colors.red
                                    : Colors.grey,
                                onPressed: () {
                                  setState(() {
                                    _type = "Năm";
                                    _selectedType = 3;
                                  });
                                },
                                child: Text("Năm",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold))),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  Text("Ghi chú"),
                  SizedBox(height: 4),
                  TextFormField(
                    maxLines: 7,
                    controller: _noteController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1)),
                        focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1)),
                        contentPadding: EdgeInsets.all(8),
                        border: const OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FlatButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        onPressed: () async {
                          if (!_isPostButtonEnable()) {
                            Helper.showFailDialog(context);
                          } else {
                            setState(() {
                              _isLoading = true;
                            });
                            doAddAction();
                          }
                        },
                        color: Colors.green,
                        textColor: Colors.white,
                        icon: Icon(Icons.check),
                        padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width / 5),
                        label: Text("Lưu lại",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500))),
                  )
                ],
              ),
            ),
          ),
          _isLoading ? UILoadingOpacity() : Container()
        ],
      ),
    ));
  }

  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }

  void doAddAction() async {
    MemberRequest _memberRequest = MemberRequest(
        memberId: _member.userId != null ? _member.userId : null,
        amount: _joiningFreeController.text.length > 0
            ? int.parse(_joiningFreeController.text, onError: (source) => null)
            : null,
        //joinedDate: myEncode(_joinDate),
        paymentDate: myEncode(_paymentDate),
        joiningFeePeriod: _type,
        avatarSource: _member.avatarSource != null
            ? {
                "fileName": _member.avatarSource.path.split("/").last,
                "base64": base64Encode(_member.avatarSource.readAsBytesSync())
              }
            : null,
        userName: _member.userName,
        name: _member.name,
        email: _member.email,
        phoneNumber: _member.phoneNumber,
        userGroupId: _group != null ? _group.userGroupId : null,
        notes: _noteController.text);
    //
    print("add_member_request: " + jsonEncode(_memberRequest.toJson()));
    _memberBloc.requestAddMember(jsonEncode(_memberRequest.toJson()));
    _memberBloc.addMemberStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          setState(() {
            _isLoading = true;
          });
          break;
        case Status.COMPLETED:
          setState(() {
            _isLoading = false;
          });
          Helper.showOKDialog(context, () {
            Navigator.of(context).pop();
            Navigator.of(context).pop(1);
          }, "Thêm thành viên thành công");
          break;
        case Status.ERROR:
          setState(() {
            _isLoading = false;
          });
          Fluttertoast.showToast(msg: event.message, textColor: Colors.black87);
          break;
      }
    });
  }

  bool _isPostButtonEnable() {
    if (_paymentDate == null ||
        _joiningFreeController.text.length == 0) {
      return false;
    }
    return true;
  }

  onCardPress(TYPE type) {
    switch (type) {
      case TYPE.ACCOUNT:
        break;
      case TYPE.NAME:
        break;
      case TYPE.PHONE:
        break;
      case TYPE.EMAIL:
        break;
    }
  }

  Icon iconByType(TYPE type) {
    switch (type) {
      case TYPE.ACCOUNT:
        return Icon(Icons.info);
      case TYPE.NAME:
        return Icon(Icons.perm_identity_rounded);
      case TYPE.PHONE:
        return Icon(Icons.phone_android);
      case TYPE.EMAIL:
        return Icon(Icons.email);
      default:
        return Icon(Icons.email);
    }
  }

  Widget infoCard(String info, TYPE type) {
    return InkWell(
      onTap: () => onCardPress(type),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: <Widget>[
            iconByType(type),
            SizedBox(width: 16),
            Container(
              width: type == TYPE.ACCOUNT
                  ? MediaQuery.of(context).size.width - 150
                  : MediaQuery.of(context).size.width - 100,
              child: Text(
                info,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ),
    );
  }
}
