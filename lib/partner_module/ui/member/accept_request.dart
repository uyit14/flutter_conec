import 'dart:convert';
import 'dart:io';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/common/ui/ui_loading_opacity.dart';
import 'package:conecapp/models/response/chat/conversations_response.dart';
import 'package:conecapp/partner_module/models/group_response.dart';
import 'package:conecapp/partner_module/models/member_info_response.dart';
import 'package:conecapp/partner_module/models/member_request.dart';
import 'package:conecapp/partner_module/models/requestsmember_response.dart';
import 'package:conecapp/partner_module/models/search_m_response.dart';
import 'package:conecapp/partner_module/ui/member/member_bloc.dart';
import 'package:conecapp/partner_module/ui/member/search_group.dart';
import 'package:conecapp/partner_module/ui/member/search_member_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'add_custom_member.dart';

enum TYPE { ACCOUNT, NAME, PHONE, EMAIL }

class AcceptRequestPage extends StatefulWidget {
  static const ROUTE_NAME = '/accept-request';

  @override
  _AcceptRequestPageState createState() => _AcceptRequestPageState();
}

class _AcceptRequestPageState extends State<AcceptRequestPage> {
  MemberBloc _memberBloc = MemberBloc();
  MemberInfo _member = MemberInfo();
  var _paymentDate;
  File _image;
  final picker = ImagePicker();
  bool apiCall = true;

  //var _joinDate;
  int _selectedType;
  bool _isLoading = false;
  Group _group;
  String _type = "";
  Request _request = Request();
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
    _request = routeArgs;
    if (apiCall) {
      _memberBloc.requestGetMemberInfo(_request.id);
      apiCall = false;
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
      appBar: AppBar(title: Text("Xác nhận thành viên")),
      body: StreamBuilder<ApiResponse<MemberInfo>>(
          stream: _memberBloc.memberInfoStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return UILoading(loadingMessage: snapshot.data.message);
                case Status.ERROR:
                  return UIError(errorMessage: snapshot.data.message);
                case Status.COMPLETED:
                  _member = snapshot.data.data;
                  return Stack(
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
                                        infoCard(_member.userName ?? "",
                                            TYPE.ACCOUNT),
                                        InkWell(
                                          onTap: () {
                                            final act = CupertinoActionSheet(
                                                actions: <Widget>[
                                                  CupertinoActionSheetAction(
                                                    child: Text('Chụp ảnh',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.blue)),
                                                    onPressed: () =>
                                                        getImageAvatar(true),
                                                  ),
                                                  CupertinoActionSheetAction(
                                                    child: Text(
                                                        'Chọn từ thư viện',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.blue)),
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
                                                builder:
                                                    (BuildContext context) =>
                                                        act);
                                          },
                                          child: CircleAvatar(
                                            radius: 22,
                                            backgroundColor: Colors.grey,
                                            backgroundImage: avatarImage(
                                                _image, _member.avatar),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    infoCard(_member.name ?? "", TYPE.NAME),
                                    SizedBox(height: 8),
                                    infoCard(
                                        _request.phoneNumber ?? "", TYPE.PHONE),
                                    SizedBox(height: 8),
                                    infoCard(_request.email ?? "", TYPE.EMAIL),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(Icons.group),
                                          SizedBox(width: 16),
                                          Text(
                                            _group != null
                                                ? _group.name
                                                : "Chọn nhóm / lớp",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Spacer(),
                                          Text("Thay đổi",
                                              style: AppTheme.changeTextStyle(
                                                  true))
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
                                                fontSize: 16)),
                                        onChanged: (date) {
                                      setState(() {
                                        _paymentDate =
                                            date != null ? date : null;
                                      });
                                    }, onConfirm: (date) {
                                      setState(() {
                                        _paymentDate =
                                            date != null ? date : null;
                                      });
                                    },
                                        currentTime: _paymentDate
                                                .toString()
                                                .contains("0001")
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(Icons.monetization_on),
                                          SizedBox(width: 16),
                                          Text(
                                            _paymentDate != null
                                                ? DateFormat('dd-MM-yyyy')
                                                    .format(_paymentDate ??
                                                        DateTime(2000, 6, 16))
                                                : "Chọn ngày",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Spacer(),
                                          Text("Thay đổi",
                                              style: AppTheme.changeTextStyle(
                                                  true))
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
                                            borderSide: BorderSide(
                                                color: Colors.green, width: 1)),
                                        contentPadding:
                                            EdgeInsets.only(left: 8),
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
                                                borderRadius:
                                                    BorderRadius.circular(50)),
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
                                                    fontWeight:
                                                        FontWeight.bold))),
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
                                                borderRadius:
                                                    BorderRadius.circular(50)),
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
                                                    fontWeight:
                                                        FontWeight.bold))),
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
                                                borderRadius:
                                                    BorderRadius.circular(50)),
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
                                                    fontWeight:
                                                        FontWeight.bold))),
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
                                                borderRadius:
                                                    BorderRadius.circular(50)),
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
                                                    fontWeight:
                                                        FontWeight.bold))),
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
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1)),
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1)),
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
                                        horizontal:
                                            MediaQuery.of(context).size.width /
                                                5),
                                    label: Text("Lưu lại",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500))),
                              )
                            ],
                          ),
                        ),
                      ),
                      _isLoading ? UILoadingOpacity() : Container()
                    ],
                  );
              }
            }
            return Center(child: CircularProgressIndicator());
          }),
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
        id: _request.id,
        memberId: _request.memberId != null ? _member.memberId : null,
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
    print("accept_request: " + jsonEncode(_memberRequest.toJson()));
    _memberBloc.requestConfirmRequest(jsonEncode(_memberRequest.toJson()));
    _memberBloc.confirmRequestStream.listen((event) {
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
          }, "Xác nhận thành công");
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
    if (_paymentDate == null || _joiningFreeController.text.length == 0) {
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
