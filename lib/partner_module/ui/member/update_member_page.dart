import 'dart:convert';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_loading_opacity.dart';
import 'package:conecapp/partner_module/models/member_request.dart';
import 'package:conecapp/partner_module/models/members_response.dart';
import 'package:conecapp/partner_module/ui/member/member_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

enum TYPE { ACCOUNT, NAME, PHONE, EMAIL }

class UpdateMemberPage extends StatefulWidget {
  static const ROUTE_NAME = '/update-member';

  @override
  _UpdateMemberPageState createState() => _UpdateMemberPageState();
}

class _UpdateMemberPageState extends State<UpdateMemberPage> {
  MemberBloc _memberBloc = MemberBloc();
  bool _isCallApi;
  var _paymentDate;
  var _joinDate;
  int _selectedType;
  bool _isLoading = false;
  String _type = "";
  Member _member = Member();
  TextEditingController _joiningFreeController;
  TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _isCallApi = true;
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
        if (_member.joinedDate != null) {
          _joinDate = DateTime(
              int.parse(_member.joinedDate.substring(6)),
              int.parse(_member.joinedDate.substring(3, 5)),
              int.parse(_member.joinedDate.substring(0, 2)));
        }
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
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12),
                        infoCard(
                            _member.userName ?? "Tên tài khoản", TYPE.ACCOUNT),
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
                  SizedBox(height: 8),
                  Text("Ngày tham gia"),
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
                            _joinDate = date != null ? date : null;
                          });
                        }, onConfirm: (date) {
                          setState(() {
                            _joinDate = date != null ? date : null;
                          });
                        },
                            currentTime: _joinDate.toString().contains("0001")
                                ? DateTime(2000, 6, 16)
                                : _joinDate,
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
                              Icon(Icons.date_range),
                              SizedBox(width: 16),
                              Text(
                                _joinDate != null
                                    ? DateFormat('dd-MM-yyyy').format(
                                        _joinDate ?? DateTime(2000, 6, 16))
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
        memberId: _member.memberId,
        amount: _joiningFreeController.text.length > 0
            ? int.parse(_joiningFreeController.text, onError: (source) => null)
            : null,
        joinedDate: myEncode(_joinDate),
        paymentDate: myEncode(_paymentDate),
        joiningFeePeriod: _type,
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
    if (_joinDate == null ||
        _paymentDate == null ||
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
