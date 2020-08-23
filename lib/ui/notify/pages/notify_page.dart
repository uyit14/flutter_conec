import 'package:conecapp/dummy/dummy_data.dart';
import 'package:flutter/material.dart';

class NotifyPage extends StatelessWidget {
  static const ROUTE_NAME = '/notify';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thông báo"),
        actions: <Widget>[
          IconButton(
            onPressed: (){
              //TODO - read all, update UI
            },
            icon: Icon(Icons.done_all, size: 28, color: Colors.greenAccent),
          )
        ],
        elevation: 0,
      ),
      body: Container(
          color: Colors.black26,
          padding: EdgeInsets.all(8),
          child: ListView.builder(
              itemCount: DummyData.notifyList.length,
              itemBuilder: (context, index) {
                return Card(
                  color: DummyData.notifyList[index].isRead
                      ? Colors.white70
                      : Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 2),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(DummyData.notifyList[index].title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text(DummyData.notifyList[index].content),
                        SizedBox(height: 4),
                        Text(DummyData.notifyList[index].date,
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                );
              })),
    );
  }
}
