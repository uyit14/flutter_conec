import 'dart:convert';

import 'package:chips_choice/chips_choice.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_loading_opacity.dart';
import 'package:conecapp/partner_module/models/p_notify_detail.dart';
import 'package:conecapp/partner_module/models/p_notify_request.dart';
import 'package:conecapp/partner_module/ui/notify/p_notify_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:html/parser.dart';

class UpdateNotifyPage extends StatefulWidget {
  static const ROUTE_NAME = '/update-notify';

  @override
  _UpdateNotifyPageState createState() => _UpdateNotifyPageState();
}

class _UpdateNotifyPageState extends State<UpdateNotifyPage> {
  PNotifyBloc _notifyBloc = PNotifyBloc();
  String selectedStatus = Helper.statusList[0];
  bool _isLoading = false;
  bool _isCallApi;
  ZefyrController _controller;
  FocusNode _focusNode = FocusNode();
  String _postId;
  NotificationInDetail _notificationInDetail;
  TextEditingController _titleController;
  TextEditingController _orderNoController;

  int tag = 0;

  Color getColorByTag(int mTag) {
    switch (mTag) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.blue[300];
      case 4:
        return Colors.yellow[700];
      case 5:
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  bool _isPostButtonEnable() {
    if (_titleController.text.length == 0 ||
        _controller.document.toPlainText().length <= 0) {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _isCallApi = true;
    _controller = ZefyrController(NotusDocument());
  }

  /// Loads the document to be edited in Zefyr.
  NotusDocument _loadDocument(String data) {
    // For simplicity we hardcode a simple document with one line of text
    // saying "Zefyr Quick Start".
    // (Note that delta must always end with newline.)
    final Delta delta = Delta()..insert(data);
    return NotusDocument.fromDelta(delta);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isCallApi) {
      final routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, Object>;
      _postId = routeArgs['postId'];
      _notificationInDetail = routeArgs['notificationInDetail'];
      //init value
      if (_notificationInDetail.content != null) {
        final document = parse(
            _notificationInDetail.content.toString().replaceAll("<br>", "\n") ??
                "");
        final String parsedString =
            parse(document.body.text).documentElement.text;
        final notusDocument = _notificationInDetail.content != null
            ? _loadDocument('$parsedString\n')
            : NotusDocument();
        _controller = ZefyrController(notusDocument);
      }
      initValue();
      _isCallApi = false;
    }
  }

  void initValue() {
    setState(() {
      _titleController =
          TextEditingController(text: _notificationInDetail.title);
      _orderNoController =
          TextEditingController(text: _notificationInDetail.orderNo.toString());
      tag = Helper.params.indexOf(_notificationInDetail.color);
      selectedStatus = Helper.statusResponse(_notificationInDetail.active);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool _showFab = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Thêm thông báo"),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tiêu đề *"),
                  TextFormField(
                      maxLines: 1,
                      controller: _titleController,
                      style: TextStyle(fontSize: 18),
                      textInputAction: TextInputAction.done),
                  SizedBox(height: 12),
                  Text("Thứ tự"),
                  TextFormField(
                      maxLines: 1,
                      controller: _orderNoController,
                      style: TextStyle(fontSize: 18),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number),
                  SizedBox(height: 12),
                  Text("Màu sắc"),
                  ChipsChoice<int>.single(
                    value: tag,
                    wrapped: true,
                    onChanged: (val) => setState(() => tag = val),
                    choiceItems: C2Choice.listFrom<int, String>(
                      source: Helper.options,
                      value: (i, v) => i,
                      label: (i, v) => v,
                      style: (i, v) {
                        return C2ChoiceStyle(
                            color: getColorByTag(i),
                            showCheckmark: i == tag,
                            labelStyle: TextStyle(
                                fontWeight: i == tag
                                    ? FontWeight.bold
                                    : FontWeight.w400));
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                  Text("Trạng thái"),
                  Row(
                    children: Helper.statusList
                        .map((e) => Row(
                      children: [
                        Radio(
                          value: e,
                          groupValue: selectedStatus,
                          activeColor: Color.fromRGBO(220, 65, 50, 1),
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value;
                            });
                          },
                        ),
                        Text(e, style: TextStyle(fontSize: 18)),
                        SizedBox(width: 12)
                      ],
                    ))
                        .toList(),
                  ),
                  SizedBox(height: 12),
                  Text("Nội dung"),
                  SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8))),
                    height: 200,
                    child: ZefyrScaffold(
                      child: ZefyrEditor(
                        autofocus: false,
                        controller: _controller,
                        focusNode: _focusNode,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  //STEP 9
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
                            doUpdateAction();
                          }
                        },
                        color: Colors.orange,
                        textColor: Colors.white,
                        icon: Icon(Icons.check),
                        padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width / 5),
                        label: Text("Sửa thông báo",
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
      floatingActionButton: _showFab
          ? FloatingActionButton.extended(
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
              backgroundColor: Colors.green,
              label: Text("Xong"),
              icon: Icon(Icons.check),
            )
          : null,
    ));
  }

  void doUpdateAction() async {
    PNotifyRequest _pNotifyRequest = PNotifyRequest(
        id: _notificationInDetail.id,
        postId: _postId,
        title: _titleController.text,
        color: Helper.params[tag],
        content: _controller.document
            .toPlainText()
            .toString()
            .replaceAll("\n", "<br>"),
        orderNo: _orderNoController.text != null
            ? int.parse(_orderNoController.text)
            : null,
        active: Helper.statusRequest(selectedStatus)
    );
    //
    print("update_p_notify_request: " + jsonEncode(_pNotifyRequest.toJson()));
    _notifyBloc.requestUpdatePNotify(jsonEncode(_pNotifyRequest.toJson()));
    _notifyBloc.updatePNotifyStream.listen((event) {
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
          }, "Sửa thông báo thành công");
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

  @override
  void dispose() {
    super.dispose();
    _notifyBloc.dispose();
  }
}
