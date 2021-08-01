import 'dart:convert';

import 'package:chips_choice/chips_choice.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_loading_opacity.dart';
import 'package:conecapp/partner_module/models/p_notify_request.dart';
import 'package:conecapp/partner_module/ui/notify/p_notify_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zefyr/zefyr.dart';

class AddNotifyPage extends StatefulWidget {
  static const ROUTE_NAME = '/add-notify';

  @override
  _AddNotifyPageState createState() => _AddNotifyPageState();
}

class _AddNotifyPageState extends State<AddNotifyPage> {
  PNotifyBloc _notifyBloc = PNotifyBloc();
  bool _isLoading = false;
  String _title;
  int _orderNo = 1;
  ZefyrController _controller;
  FocusNode _focusNode = FocusNode();
  String _postId;

  int tag = 0;
  List<String> options = [
    'Đỏ',
    'Xanh lá',
    'Xanh đậm',
    'Xanh nhạt',
    'Vàng',
    'Xám'
  ];

  List<String> params = [
    'alert alert-danger',
    'alert alert-success',
    'alert alert-primary',
    'alert alert-info',
    'alert alert-warning',
    'alert alert-secondary'
  ];

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
    if (_title == null || _controller.document.toPlainText().length <= 0) {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _controller = ZefyrController(NotusDocument());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context).settings.arguments;
    _postId = routeArgs;
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
                      style: TextStyle(fontSize: 18),
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        setState(() {
                          _title = value;
                        });
                      }),
                  SizedBox(height: 12),
                  Text("Thứ tự"),
                  TextFormField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 18),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _orderNo = int.parse(value);
                        });
                      }),
                  SizedBox(height: 12),
                  Text("Màu sắc"),
                  ChipsChoice<int>.single(
                    value: tag,
                    wrapped: true,
                    onChanged: (val) => setState(() => tag = val),
                    choiceItems: C2Choice.listFrom<int, String>(
                      source: options,
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

  void doAddAction() async {
    PNotifyRequest _pNotifyRequest = PNotifyRequest(
        postId: _postId,
        title: _title,
        color: params[tag],
        content: _controller.document
            .toPlainText()
            .toString()
            .replaceAll("\n", "<br>"),
        orderNo: _orderNo);
    //
    print("add_p_notify_request: " + jsonEncode(_pNotifyRequest.toJson()));
    _notifyBloc.requestAddPNotify(jsonEncode(_pNotifyRequest.toJson()));
    _notifyBloc.addPNotifyStream.listen((event) {
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
          }, "Thêm thông báo thành công");
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
