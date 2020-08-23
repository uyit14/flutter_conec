import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/sport.dart';
import 'package:conecapp/ui/news/blocs/news_bloc.dart';
import 'package:conecapp/ui/news/pages/sell_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../dummy/dummy_data.dart';

class SellWidget extends StatefulWidget {
  @override
  _SellWidgetState createState() => _SellWidgetState();
}

class _SellWidgetState extends State<SellWidget> {
  NewsBloc _newsBloc = NewsBloc();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _newsBloc.requestGetAllAds();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(22))),
            padding: EdgeInsets.only(left: 18, right: 18, bottom: 8),
            width: double.infinity,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black12,
                    ),
                    height: 40,
                    child: TextFormField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                          hintText: 'Nhập thông tin bạn muốn tìm kiếm',
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: EdgeInsets.only(left: 8)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  child: Text("Hủy", style: AppTheme.changeTextStyle(true)),
                  onTap: () {
                    //TODO - clear seach
                  },
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 4),
            padding: EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.symmetric(
                    vertical: BorderSide(color: Colors.grey, width: 0.5))),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(width: 4),
                  InkWell(
                    onTap: () => showCityList(
                        getIndex(DummyData.cityList, selectedCity)),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.5, color: Colors.grey),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: <Widget>[
                          Text(selectedCity ?? "Tỉnh/Thành phố"),
                          Icon(Icons.keyboard_arrow_down)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  InkWell(
                    onTap: () => selectedCity != null
                        ? showDistrictList(
                            getIndex(DummyData.districtList, selectedDistrict))
                        : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                      decoration: BoxDecoration(
                          color: selectedCity != null
                              ? Colors.white
                              : Colors.black12,
                          border: Border.all(width: 0.5, color: Colors.grey),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: <Widget>[
                          Text(selectedDistrict ?? "Quận/Huyện",
                              style: TextStyle(
                                  color: selectedCity != null
                                      ? Colors.black87
                                      : Colors.grey)),
                          Icon(Icons.keyboard_arrow_down)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<ApiResponse<List<Sport>>>(
                stream: _newsBloc.allAdsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.data.status) {
                      case Status.LOADING:
                        return UILoading(loadingMessage: snapshot.data.message);
                      case Status.COMPLETED:
                        List<Sport> sports = snapshot.data.data;
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: sports.length,
                            itemBuilder: (context, index) {
                              return ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: 130, maxHeight: 130),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        SellDetailPage.ROUTE_NAME,
                                        arguments: {
                                          'postId': sports[index].postId,
                                        });
                                  },
                                  child: Card(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: <Widget>[
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: Hero(
                                              tag: sports[index].postId,
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    sports[index].thumbnail,
                                                progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Image.asset(
                                                        "assets/images/error.png"),
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                              child: Container(
                                            height: 100,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  sports[index].title,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 6),
                                                Text(
                                                  '${Helper.formatCurrency(sports[index].price ?? 0)} VND',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.red),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 6),
                                                //TODO - add address
                                                Text(
                                                  '${sports[index].address} ${sports[index].ward} ${sports[index].district} ${sports[index].province}',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Expanded(
                                                  child: Container(),
                                                ),
                                                Text(
                                                  sports[index].publishedDate,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  textAlign: TextAlign.end,
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          )),
                                          SizedBox(width: 10),
                                          Container(
                                              child: Center(
                                                  child: Icon(
                                                Icons.navigate_next,
                                                size: 30,
                                                color: Colors.red,
                                              )),
                                              height: 70)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                      case Status.ERROR:
                        return UIError(
                            errorMessage: snapshot.data.message,
                            onRetryPressed: () => _newsBloc.requestGetAllAds());
                    }
                  }
                  return Container(
                      child: Center(
                          child: Text(
                              "Không có dữ liệu, kiểm tra lại kết nối internet của bạn")));
                }),
          ),
        ],
      ),
    );
  }

  //bottom sheet
  var selectedCity;
  var selectedDistrict;
  var selectedSellType;

  int getIndex(List<String> list, String selectedItem) {
    return selectedItem != null
        ? list.indexOf(list.firstWhere((element) => element == selectedItem))
        : 0;
  }

  void showCityList(int index) {
    var controller = FixedExtentScrollController(initialItem: index);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            height: 250,
            child: CupertinoPicker(
              scrollController: controller,
              onSelectedItemChanged: (value) {
                setState(() {
                  selectedCity = DummyData.cityList[value];
                });
              },
              itemExtent: 32,
              children: DummyData.cityList.map((e) => Text(e)).toList(),
            ),
          );
        }).then((value) => debugPrint(selectedCity));
  }

  void showDistrictList(int index) {
    var controller = FixedExtentScrollController(initialItem: index);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            height: 250,
            child: CupertinoPicker(
              scrollController: controller,
              onSelectedItemChanged: (value) {
                setState(() {
                  selectedDistrict = DummyData.districtList[value];
                });
              },
              itemExtent: 32,
              children: DummyData.districtList.map((e) => Text(e)).toList(),
            ),
          );
        }).then((value) => debugPrint(selectedDistrict));
  }
}
