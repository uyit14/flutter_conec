import 'package:flutter/material.dart';

class HasSearchHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Lịch sử tìm kiếm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey,
            height: 1,
            width: double.infinity,
          ),
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: DummyData.searchHistory.length,
          //     itemBuilder: (context, index) {
          //       return Container(
          //         margin: EdgeInsets.symmetric(vertical: 5),
          //         child: Text(DummyData.searchHistory[index], style: TextStyle(fontSize: 18)),
          //       );
          //     },
          //   ),
          // )
        ],
      ),
    );
  }
}
