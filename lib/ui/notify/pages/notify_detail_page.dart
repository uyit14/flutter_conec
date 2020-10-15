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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context).settings.arguments;
    _notify = routeArgs;
    if (_notify != null) {
      _notifyBloc.requestDeleteOrRead(_notify.id, "MarkAsRead");
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
                Icons.restore_from_trash,
                color: Colors.grey,
              ),
              onPressed: () {
                _notifyBloc.requestDeleteOrRead(_notify.id, "Remove");
              },
            ),
            SizedBox(
              width: 12,
            )
          ],
        ),
        body: Container(
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}
