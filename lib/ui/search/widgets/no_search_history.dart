import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class NoSearchHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.symmetric(
                  vertical: BorderSide(color: Colors.grey, width: 0.5))),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.grey),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        child: Text("Tỉnh/Thành phố"),
                        onTap: () {},
                      ),
                      Icon(Icons.keyboard_arrow_down)
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.grey),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        child: Text("Quận/Huyện"),
                        onTap: () {},
                      ),
                      Icon(Icons.keyboard_arrow_down)
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.grey),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        child: Text("Chuyên mục"),
                        onTap: () {},
                      ),
                      Icon(Icons.keyboard_arrow_down)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
//        Padding(
//          padding: const EdgeInsets.all(8.0),
//          child: Text("Kết quả tìm kiếm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//        ),
//        Container(
//          color: Colors.grey,
//          height: 0.5,
//          width: double.infinity,
//        ),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: ListView.builder(
//               itemCount: DummyData.searchHistory.length,
//               itemBuilder: (context, index) {
//                 return Container(
//                   margin: EdgeInsets.symmetric(vertical: 5),
//                   child: Text(DummyData.searchHistory[index], style: TextStyle(fontSize: 18)),
//                 );
//               },
//             ),
//           ),
//         )
      ],
    );
  }
}
