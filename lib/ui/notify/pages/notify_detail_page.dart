import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/notify/notify_response.dart';
import 'package:conecapp/ui/notify/pages/notify_bloc.dart';
import 'package:flutter/material.dart';

class NotifyDetailPage extends StatefulWidget {
  static const ROUTE_NAME = '/notify-detail';

  @override
  _NotifyDetailPageState createState() => _NotifyDetailPageState();
}

class _NotifyDetailPageState extends State<NotifyDetailPage> {
  Notify _notify;
  NotifyBloc _notifyBloc = NotifyBloc();
  bool _apiCall = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context).settings.arguments;
    _notify = routeArgs;
    if (_notify != null && !_notify.read && _apiCall) {
      _notifyBloc.requestDeleteOrRead(_notify.id, "MarkAsRead");
      _apiCall = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(1);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(1);
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          title: Text("Thông báo"),
          actions: [
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.black,
                size: 28,
              ),
              onPressed: () {
                _notifyBloc.requestDeleteOrRead(_notify.id, "Remove");
                Navigator.of(context).pop(1);
              },
            ),
            SizedBox(
              width: 12,
            )
          ],
        ),
        body: Card(
          elevation: 4,
          margin: EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(_notify.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                SizedBox(height: 4),
                Text(_notify.content),
                SizedBox(height: 4),
                Text(_notify.createdDate,
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
