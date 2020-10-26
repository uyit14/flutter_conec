import 'package:conecapp/common/helper.dart';
import 'package:conecapp/ui/home/blocs/report_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReportPage extends StatefulWidget {
  static const ROUTE_NAME = '/report-page';
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String selectedReason = Helper.reportList[0];
  String postId;
  ReportBloc _reportBloc = ReportBloc();
  TextEditingController _controller = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs =
    ModalRoute.of(context).settings.arguments as Map<String, Object>;
    postId = routeArgs['postId'];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Báo cáo vi phạm")),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 16, right: 8),
                  child: ListView.builder(
                      itemCount: Helper.reportList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index){
                        // return Row(
                        //   children: [
                        //     Radio(
                        //       value: Helper.reportList[index],
                        //       groupValue: selectedIndex,
                        //       activeColor:
                        //       Color.fromRGBO(220, 65, 50, 1),
                        //       onChanged: (value) {
                        //         print(value);
                        //       },
                        //     ),
                        //     Text(Helper.reportList[index])
                        //   ],
                        // );
                        return ListTile(
                          title: Text(Helper.reportList[index],
                              style: TextStyle(fontSize: 18)),
                          trailing: Radio(
                            value: Helper.reportList[index],
                            groupValue: selectedReason,
                            activeColor:
                            Color.fromRGBO(220, 65, 50, 1),
                            onChanged: (value) {
                              setState(() {
                                selectedReason = value;
                              });
                            },
                          ),
                          contentPadding: EdgeInsets.all(0),
                        );
                      }
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    maxLines: 7,
                    controller: _controller,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.red, width: 1)),
                        focusedBorder: const OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.green, width: 1)),
                        contentPadding: EdgeInsets.all(8),
                        border: const OutlineInputBorder()),
                  ),
                ),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FlatButton.icon(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.red,
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(8)),
                        onPressed: () {
                          _reportBloc.requestReport(postId, selectedReason, _controller.text ?? "");
                          Fluttertoast.showToast(msg: "Gửi báo cáo thành công", textColor: Colors.black87, gravity: ToastGravity.CENTER);
                          Navigator.of(context).pop();
                        },
                        textColor: Colors.red,
                        icon: Icon(Icons.report),
                        label: Text("Gửi báo cáo",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))),
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
