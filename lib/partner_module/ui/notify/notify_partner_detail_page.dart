import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/partner_module/models/p_notify_detail.dart';
import 'package:conecapp/partner_module/ui/notify/add_notify_page.dart';
import 'package:conecapp/partner_module/ui/notify/p_notify_bloc.dart';
import 'package:conecapp/partner_module/ui/notify/update_notify_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotifyPartnerDetailPage extends StatefulWidget {
  static const ROUTE_NAME = '/notify-partner-detail';

  @override
  _NotifyPartnerDetailPageState createState() =>
      _NotifyPartnerDetailPageState();
}

class _NotifyPartnerDetailPageState extends State<NotifyPartnerDetailPage> {
  PNotifyBloc _notifyBloc = PNotifyBloc();
  String _postId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context).settings.arguments;
    _postId = routeArgs;
    if (_postId != null) {
      _notifyBloc.requestGetPNotifyDetail(_postId);
    }
  }

  void sendNotify(String id) async {
    Helper.showAlertDialog(context, "Đẩy thông báo",
        "Thông báo này sẽ được gửi đến thành viên và những người theo dõi tin này",
        () async {
      String result = await _notifyBloc.requestPushNotify(id);
      Fluttertoast.showToast(msg: result.replaceAll("<b>", "").replaceAll("</b>", ""), textColor: Colors.black87);
      Navigator.of(context).pop();
    });
  }

  void onUpdateNotify(NotificationInDetail notificationInDetail) {
    Navigator.of(context).pushNamed(UpdateNotifyPage.ROUTE_NAME, arguments: {
      'postId': _postId,
      'notificationInDetail': notificationInDetail
    }).then((value) {
      if (value == 1) {
        _notifyBloc.requestGetPNotifyDetail(_postId);
      }
    });
  }

  void onDeleteNotify(String notifyId) {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(1);
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          title: Text("Thông báo"),
        ),
        body: StreamBuilder<ApiResponse<PNotifyFull>>(
            stream: _notifyBloc.notifyFullStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data.status) {
                  case Status.LOADING:
                    return UILoading(loadingMessage: snapshot.data.message);
                  case Status.ERROR:
                    return UIError(errorMessage: snapshot.data.message);
                  case Status.COMPLETED:
                    PNotifyFull _notify = snapshot.data.data;
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          Card(
                            elevation: 4,
                            margin: EdgeInsets.all(8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text("Thông tin chung",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blue)),
                                  SizedBox(height: 12),
                                  Text("Danh mục",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(_notify.topic ?? "",
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 6),
                                  Text("Phân loại môn",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  _notify.topics != null &&
                                          _notify.topics.length > 0
                                      ? Container(
                                          height: 45,
                                          child: ListView(
                                            scrollDirection: Axis.horizontal,
                                            children: _notify.topics
                                                .map((e) =>
                                                    Chip(label: Text(e.title)))
                                                .toList(),
                                          ),
                                        )
                                      : Container(),
                                  _notify.subTopics != null &&
                                          _notify.subTopics.length > 0
                                      ? Container(
                                          height: 50,
                                          child: ListView(
                                            scrollDirection: Axis.horizontal,
                                            children: _notify.subTopics
                                                .map((e) => Chip(
                                                    label: Text(e.title),
                                                    backgroundColor:
                                                        Colors.black12))
                                                .toList(),
                                          ),
                                        )
                                      : Container(),
                                  SizedBox(height: 4),
                                  Text("Tiêu đề",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(_notify.title,
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 6),
                                  Text("Phí tham gia (VNĐ)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(
                                      _notify.joiningFee != null
                                          ? '${_notify.joiningFee.toString()}  /  ${_notify.joiningFeePeriod}'
                                          : "Liên hệ",
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            margin: EdgeInsets.all(8),
                            elevation: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.all(12),
                                  child: Text("Thông báo",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blue)),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 16),
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount:
                                          _notify.notificationsInDetail.length,
                                      itemBuilder: (context, index) {
                                        ColorNotify colorN =
                                            Helper.getColorNotify(_notify
                                                .notificationsInDetail[index]
                                                .color);
                                        String status = Helper.statusResponse(
                                            _notify.notificationsInDetail[index]
                                                .active);
                                        return Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            150,
                                                    child: Text(
                                                      _notify
                                                          .notificationsInDetail[
                                                              index]
                                                          .title,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    )),
                                                Spacer(),
                                                Text(colorN.text,
                                                    style: TextStyle(
                                                        color: colorN.color,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                SizedBox(width: 16),
                                                Text(status,
                                                    style: TextStyle(
                                                        color: _notify
                                                                .notificationsInDetail[
                                                                    index]
                                                                .active
                                                            ? Colors.green
                                                            : Colors.red,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                SizedBox(width: 12),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Spacer(),
                                                IconButton(
                                                    icon: Icon(Icons.edit,
                                                        color: Colors.blue),
                                                    onPressed: () =>
                                                        onUpdateNotify(_notify
                                                                .notificationsInDetail[
                                                            index])),
                                                IconButton(
                                                    icon: Icon(
                                                        Icons
                                                            .notifications_active,
                                                        color: Colors.yellow),
                                                    onPressed: () => sendNotify(
                                                        _notify
                                                            .notificationsInDetail[
                                                                index]
                                                            .id)),
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () {
                                                      Helper.showDeleteDialog(
                                                          context,
                                                          "Xóa thông báo",
                                                          "Bạn có chắc chắn muốn xóa thông báo này?",
                                                          () {
                                                        _notifyBloc
                                                            .requestDeleteNotify(
                                                                _notify
                                                                    .notificationsInDetail[
                                                                        index]
                                                                    .id);
                                                        _notify
                                                            .notificationsInDetail
                                                            .removeAt(index);
                                                        setState(() {});
                                                        Navigator.of(context)
                                                            .pop();
                                                      });
                                                    })
                                              ],
                                            ),
                                            Container(
                                                width: double.infinity,
                                                height: 0.5,
                                                color: Colors.grey),
                                            SizedBox(height: 6),
                                          ],
                                        );
                                      }),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                }
              }
              return Center(
                  child: Text(
                "Chưa có thông báo",
                style: TextStyle(fontSize: 18),
              ));
            }),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context)
                .pushNamed(AddNotifyPage.ROUTE_NAME, arguments: _postId)
                .then((value) {
              if (value == 1) {
                _notifyBloc.requestGetPNotifyDetail(_postId);
              }
            });
          },
          label: Text('Thêm thông báo'),
          icon: Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _notifyBloc?.dispose();
  }
}
