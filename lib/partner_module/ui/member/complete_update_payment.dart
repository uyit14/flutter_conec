import 'dart:convert';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_loading_opacity.dart';
import 'package:conecapp/partner_module/models/members_response.dart';
import 'package:conecapp/partner_module/models/payment_request.dart';
import 'package:conecapp/partner_module/ui/member/member_bloc.dart';
import 'package:conecapp/partner_module/ui/member/member_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CompleteUpdatePayment extends StatefulWidget {
  static const ROUTE_NAME = '/complete-update';

  @override
  _CompleteUpdatePaymentState createState() => _CompleteUpdatePaymentState();
}

class _CompleteUpdatePaymentState extends State<CompleteUpdatePayment> {
  MemberBloc _memberBloc = MemberBloc();
  bool _isCallApi;
  PAYMENT_TYPE _paymentType;
  Payment _payment;
  TextEditingController _noteController;
  TextEditingController _freeController;
  var _paymentDate;
  bool _disableView = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isCallApi = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isCallApi) {
      final routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, Object>;
      _paymentType = routeArgs['type'];
      if (_paymentType == PAYMENT_TYPE.UPDATE) {
        setState(() {
          _disableView = false;
        });
      } else {
        _disableView = true;
      }
      if (routeArgs['payment'] != null) {
        _payment = routeArgs['payment'];
        _freeController =
            TextEditingController(text: _payment.amount.toString());
        _noteController = TextEditingController(text: _payment.notes);
        //
        if (_payment.created != null) {
          _paymentDate = DateTime(
              int.parse(_payment.created.substring(6)),
              int.parse(_payment.created.substring(3, 5)),
              int.parse(_payment.created.substring(0, 2)));
        }
      }
      _isCallApi = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text(_disableView ? "Thánh toán" : "Chỉnh sửa")),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ngày đóng"),
                Card(
                  child: InkWell(
                    onTap: () => _disableView
                        ? null
                        : DatePicker.showDatePicker(context,
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
                            locale: LocaleType.vi),
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
                                style: AppTheme.changeTextStyle(!_disableView))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text("Số tiền"),
                SizedBox(height: 4),
                TextFormField(
                  maxLines: 1,
                  controller: _freeController,
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
                          borderSide: BorderSide(color: Colors.grey, width: 1)),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1)),
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
                          doHandle();
                        }
                      },
                      color: Colors.green,
                      textColor: Colors.white,
                      icon: Icon(Icons.check),
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 5),
                      label: Text(_disableView ? "Thanh toán" : "Lưu lại",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500))),
                )
              ],
            ),
          ),
          _isLoading ? UILoadingOpacity() : Container()
        ],
      ),
    ));
  }

  //
  bool _isPostButtonEnable() {
    // if (_paymentDate == null || _freeController.text.length == 0) {
    //   return false;
    // }
    return true;
  }

  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }

  void doHandle() async {
    setState(() {
      _isLoading = true;
    });
    var _paymentRequest;
    if (_disableView) {
      _paymentRequest = CompletePaymentRequest(
          id: _payment.id,
          paymentAmount: _freeController.text.length > 0
              ? int.parse(_freeController.text, onError: (source) => null)
              : null,
          paymentDate: myEncode(_paymentDate),
          notes: _noteController.text);
    } else {
      _paymentRequest = UpdatePaymentRequest(
          id: _payment.id,
          paymentAmount: _freeController.text.length > 0
              ? int.parse(_freeController.text, onError: (source) => null)
              : null,
          paymentDate: myEncode(_paymentDate),
          notes: _noteController.text);
    }

    print("${_paymentType.toString()}_payment_request: " +
        jsonEncode(_paymentRequest.toJson()));
    bool isComplete = await _memberBloc.requestCompletePayment(
        jsonEncode(_paymentRequest.toJson()), _paymentType);
    if (isComplete) {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop(1);
      Fluttertoast.showToast(msg: "Thành công", textColor: Colors.black87);
    } else {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "Vui lòng thử lại", textColor: Colors.black87);
    }
  }
}
