import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  static const ROUTE_NAME = '/search';

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black12,
                ),
                width: MediaQuery.of(context).size.width * 0.7,
                height: 35,
                child: TextFormField(
                  maxLines: 1,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                      hintText: 'Nhập thông tin bạn muốn tìm kiếm',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: Colors.white, width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(16)),
                      contentPadding: EdgeInsets.only(left: 8),
                      suffixIcon: Icon(
                        Icons.clear,
                        color: Colors.black,
                      )),
                ),
              ),
            ),
          ),
          body: Column(
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
              // Expanded(
              //   child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: ListView.builder(
              //       itemCount: DummyData.searchHistory.length,
              //       itemBuilder: (context, index) {
              //         return Container(
              //           margin: EdgeInsets.symmetric(vertical: 5),
              //           child: Text(DummyData.searchHistory[index], style: TextStyle(fontSize: 18)),
              //         );
              //       },
              //     ),
              //   ),
              // )
            ],
          )
      ),
    );
  }
}
