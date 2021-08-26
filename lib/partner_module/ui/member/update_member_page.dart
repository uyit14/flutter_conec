import 'dart:convert';
import 'dart:io';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_loading_opacity.dart';
import 'package:conecapp/partner_module/models/group_response.dart';
import 'package:conecapp/partner_module/models/member_request.dart';
import 'package:conecapp/partner_module/models/members_response.dart';
import 'package:conecapp/partner_module/ui/member/member_bloc.dart';
import 'package:conecapp/partner_module/ui/member/search_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

enum TYPE_UPDATE { ACCOUNT, NAME, PHONE, EMAIL }

class UpdateMemberPage extends StatefulWidget {
  static const ROUTE_NAME = '/update-member';

  @override
  _UpdateMemberPageState createState() => _UpdateMemberPageState();
}

class _UpdateMemberPageState extends State<UpdateMemberPage> {
  MemberBloc _memberBloc = MemberBloc();
  final picker = ImagePicker();
  bool _isCallApi;
  var _paymentDate;
  //var _joinDate;
  int _selectedType;
  bool _isLoading = false;
  String _type = "";
  File _image;
  Group _group;
  Member _member = Member();
  TextEditingController _joiningFreeController;
  TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _isCallApi = true;
  }

  ImageProvider avatarImage(File local, String url) {
    if (local != null) return FileImage(local);
    if (url != null) return NetworkImage(url);
    return AssetImage("assets/images/avatar.png");
  }

  String group(){
    if(_group != null) return _group.name;
    return _member.groupName ?? "Chưa phân nhóm";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isCallApi) {
      final routeArgs = ModalRoute.of(context).settings.arguments;
      _member = routeArgs;
      setState(() {
        _joiningFreeController =
            TextEditingController(text: _member.amount.toString());
        _noteController = TextEditingController(text: _member.notes);
        getSelectedType(_member.joiningFeePeriod);
        _paymentDate = DateTime(
            int.parse(_member.paymentDate.substring(6)),
            int.parse(_member.paymentDate.substring(3, 5)),
            int.parse(_member.paymentDate.substring(0, 2)));
        // if (_member.joinedDate != null) {
        //   _joinDate = DateTime(
        //       int.parse(_member.joinedDate.substring(6)),
        //       int.parse(_member.joinedDate.substring(3, 5)),
        //       int.parse(_member.joinedDate.substring(0, 2)));
        // }
      });
      _isCallApi = false;
    }
  }

  getSelectedType(String type) {
    switch (type) {
      case "Giờ":
        _selectedType = 0;
        break;
      case "Ngày":
        _selectedType = 1;
        break;
      case "Tháng":
        _selectedType = 2;
        break;
      case "Năm":
        _selectedType = 3;
        break;
    }
  }

  Future getImageAvatar(bool isCamera) async {
    final pickedFile = await picker.getImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text("Chỉnh sửa")),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 100,
                              child: infoCard(
                                  _member.userName ?? "Tên tài khoản",
                                  TYPE_UPDATE.ACCOUNT),
                            ),
                            InkWell(
                              onTap: _member.memberId == null
                                  ? null
                                  : () {
                                      final act = CupertinoActionSheet(
                                          actions: <Widget>[
                                            CupertinoActionSheetAction(
                                              child: Text('Chụp ảnh',
                                                  style: TextStyle(
                                                      color: Colors.blue)),
                                              onPressed: () =>
                                                  getImageAvatar(true),
                                            ),
                                            CupertinoActionSheetAction(
                                              child: Text('Chọn từ thư viện',
                                                  style: TextStyle(
                                                      color: Colors.blue)),
                                              onPressed: () =>
                                                  getImageAvatar(false),
                                            )
                                          ],
                                          cancelButton:
                                              CupertinoActionSheetAction(
                                            child: Text('Hủy'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ));
                                      showCupertinoModalPopup(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              act);
                                    },
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey,
                                    backgroundImage:
                                        avatarImage(_image, _member.avatar),
                                  ),
                                  _member.memberId == null
                                      ? Text(
                                          "Thay đổi",
                                          style: TextStyle(color: Colors.blue),
                                        )
                                      : Container()
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 8),
                        infoCard(_member.name ?? "Họ tên", TYPE_UPDATE.NAME),
                        SizedBox(height: 8),
                        infoCard(
                            _member.phoneNumber ?? "Số điện thoại", TYPE_UPDATE.PHONE),
                        SizedBox(height: 8),
                        infoCard(_member.email ?? "Email", TYPE_UPDATE.EMAIL),
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
                                group(),
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
                  // SizedBox(height: 8),
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
        id: _member.id,
        amount: _joiningFreeController.text.length > 0
            ? int.parse(_joiningFreeController.text, onError: (source) => null)
            : null,
        //joinedDate: myEncode(_joinDate),
        paymentDate: myEncode(_paymentDate),
        joiningFeePeriod: _type,
        avatarSource: _image != null
            ? {
                "fileName": _image.path.split("/").last,
                "base64": base64Encode(_image.readAsBytesSync())
              }
            : null,
        userName: _member.userName,
        name: _member.name,
        email: _member.email,
        phoneNumber: _member.phoneNumber,
        userGroupId: _group != null ? _group.userGroupId : null,
        notes: _noteController.text);
    //
    print("update_member_request: " + jsonEncode(_memberRequest.toJson()));
    _memberBloc.requestUpdateMember(jsonEncode(_memberRequest.toJson()));
    _memberBloc.updateMemberStream.listen((event) {
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
          }, "Lưu thành công");
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
    if (
        _paymentDate == null ||
        _joiningFreeController.text.length == 0) {
      return false;
    }
    return true;
  }

  onCardPress(TYPE_UPDATE type) {
    switch (type) {
      case TYPE_UPDATE.ACCOUNT:
        break;
      case TYPE_UPDATE.NAME:
        break;
      case TYPE_UPDATE.PHONE:
        break;
      case TYPE_UPDATE.EMAIL:
        break;
    }
  }

  Icon iconByType(TYPE_UPDATE type) {
    switch (type) {
      case TYPE_UPDATE.ACCOUNT:
        return Icon(Icons.info);
      case TYPE_UPDATE.NAME:
        return Icon(Icons.perm_identity_rounded);
      case TYPE_UPDATE.PHONE:
        return Icon(Icons.phone_android);
      case TYPE_UPDATE.EMAIL:
        return Icon(Icons.email);
      default:
        return Icon(Icons.email);
    }
  }

  setMemberValue(TYPE_UPDATE type, String value) {
    switch (type) {
      case TYPE_UPDATE.ACCOUNT:
        setState(() {
          _member.userName = value;
        });
        break;
      case TYPE_UPDATE.NAME:
        setState(() {
          _member.name = value;
        });
        break;
      case TYPE_UPDATE.PHONE:
        setState(() {
          _member.phoneNumber = value;
        });
        break;
      case TYPE_UPDATE.EMAIL:
        setState(() {
          _member.email = value;
        });
        break;
      default:
        return;
    }
  }

  Widget infoCard(String info, TYPE_UPDATE type) {
    return InkWell(
      onTap: () => onCardPress(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: <Widget>[
            iconByType(type),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: info,
                maxLines: 1,
                style: TextStyle(fontSize: 18),
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  setMemberValue(type, value);
                },
              ),
            )
            // Text(
            //   info,
            //   textAlign: TextAlign.left,
            //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            // )
          ],
        ),
      ),
    );
  }
}
