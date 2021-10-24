import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/sport.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/ui/mypost/pages/sub_category_page.dart';
import 'package:conecapp/ui/news/blocs/news_bloc.dart';
import 'package:conecapp/ui/news/pages/sell_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SellWidget extends StatefulWidget {
  static const ROUTE_NAME = '/sell-page';
  @override
  _SellWidgetState createState() => _SellWidgetState();
}

class _SellWidgetState extends State<SellWidget> {
  NewsBloc _newsBloc = NewsBloc();
  TextEditingController _searchController = TextEditingController();
  List<Sport> totalItemList = List<Sport>();
  ScrollController _scrollController;
  String _keyword;
  List<Topic> _topics = List();

  //
  int _currentPage = 1;
  bool _shouldLoadMore = true;
  bool _needAddUI = true;

  @override
  void initState() {
    super.initState();
    print("goto initState");
    _scrollController = new ScrollController()..addListener(_scrollListener);
    _newsBloc.requestGetAllAds(_currentPage);
    _currentPage = 2;
  }

  @override
  void dispose() {
    super.dispose();
    _newsBloc.dispose();
  }

  void _scrollListener() {
    print(_scrollController.position.extentAfter);
    if (_scrollController.position.extentAfter < 300) {
      setState(() {
        _needAddUI = true;
      });
      if (_shouldLoadMore) {
        print("goto _scrollListener");
        _shouldLoadMore = false;
        _newsBloc.requestGetAllAds(_currentPage,
            club: "", keyword: _keyword, topics: getTopicsString());
        setState(() {
          _currentPage++;
        });
      }
    }
  }

  String getTopicsString() {
    String topicsString;
    for (int i = 0; i < _topics.length; i++) {
      if (i == 0) {
        topicsString = _topics[0].id;
      } else {
        topicsString = topicsString + ';${_topics[i].id}';
      }
    }
    return topicsString;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      margin: EdgeInsets.only(top: 12),
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
                      onChanged: (value) {
                        setState(() {
                          _keyword = value;
                        });
//                        setState(() {
//                          _needAddUI = true;
//                        });
//                        if(value.length == 0){
//                          print("goto here");
//                          totalItemList.clear();
//                          _newsBloc.clearSportSearch();
//                          _searchController.clear();
//                        }else{
//                          print("goto herere");
//                          totalItemList.clear();
//                          _newsBloc.searchSportAction(value);
//                        }
                      },
                      onFieldSubmitted: (value) {
                        setState(() {
                          _needAddUI = true;
                        });
                        _currentPage = 1;
                        totalItemList.clear();
                        _newsBloc.requestGetAllAds(_currentPage,
                            keyword: value);
                        _currentPage = 2;
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      style: TextStyle(fontSize: 18),
                      controller: _searchController,
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
                  //child: Text("Hủy", style: AppTheme.changeTextStyle(true)),
                  child: Icon(Icons.search),
                  onTap: () {
//                    setState(() {
//                      _needAddUI = true;
//                    });
//                    totalItemList.clear();
//                    _newsBloc.clearSportSearch();
//                    _searchController.clear();
                    setState(() {
                      _needAddUI = true;
                    });
                    _currentPage = 1;
                    totalItemList.clear();
                    _newsBloc.requestGetAllAds(_currentPage, keyword: _keyword);
                    _currentPage = 2;
                    FocusScope.of(context).requestFocus(FocusNode());
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
                    onTap: () {
                      Navigator.of(context).pushNamed(
                          SubCategoryPage.ROUTE_NAME,
                          arguments: {"topicId": ""}).then((value) {
                        if (value != null) {
                          setState(() {
                            _needAddUI = true;
                            _topics.addAll(value);
                          });
                          print(_topics.length);
                          //TODO - call api with province here
                          _currentPage = 1;
                          totalItemList.clear();
                          _newsBloc.requestGetAllAds(_currentPage,
                              topics: getTopicsString());
                          _currentPage = 2;
                        }
                      });
                    },
                    child: _topics.length > 0
                        ? Row(
                      children: [
                        Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width - 70,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: _topics
                                .map((e) => Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 6),
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.5,
                                      color: Colors.grey),
                                  borderRadius:
                                  BorderRadius.circular(8)),
                              child: Center(
                                  child: Text(e.title ?? "")),
                            ))
                                .toList(),
                          ),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.black,
                              size: 28,
                            ),
                            onPressed: () {
                              _newsBloc.requestGetAllAds(0);
                              setState(() {
                                _topics.clear();
                              });
                            })
                      ],
                    )
                        : Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 4, horizontal: 6),
                      decoration: BoxDecoration(
                          border:
                          Border.all(width: 0.5, color: Colors.grey),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: <Widget>[
                          Text("Chọn danh mục"),
                          Icon(Icons.keyboard_arrow_down)
                        ],
                      ),
                    ),
                  ),
//                  SizedBox(width: 4),
//                  InkWell(
//                    onTap: () {
//                      if (provinceData != null) {
//                        Navigator.of(context).pushNamed(DistrictPage.ROUTE_NAME,
//                            arguments: {
//                              'district': districtData,
//                              'provinceId': provinceData.id
//                            }).then((value) {
//                          if (value != null) {
//                            setState(() {
//                              districtData = value;
//                              _needAddUI = true;
//                            });
//                            //TODO - call api with district here
//                            _currentPage = 1;
//                            totalItemList.clear();
//                            _newsBloc.requestGetAllAds(_currentPage,
//                                province: provinceData.name,
//                                district: districtData.name);
//                            _currentPage = 2;
//                          }
//                        });
//                      } else {
//                        Fluttertoast.showToast(
//                            msg: "Vui lòng chọn tỉnh, thành");
//                      }
//                    },
//                    child: Container(
//                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
//                      decoration: BoxDecoration(
//                          color: provinceData != null
//                              ? Colors.white
//                              : Colors.black12,
//                          border: Border.all(width: 0.5, color: Colors.grey),
//                          borderRadius: BorderRadius.circular(8)),
//                      child: Row(
//                        children: <Widget>[
//                          Text(
//                              districtData != null
//                                  ? districtData.name
//                                  : "Quận/Huyện",
//                              style: TextStyle(
//                                  color: provinceData != null
//                                      ? Colors.black87
//                                      : Colors.grey)),
//                          Icon(Icons.keyboard_arrow_down)
//                        ],
//                      ),
//                    ),
//                  ),
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
                      //List<Sport> sports = snapshot.data.data;
                        if (snapshot.data.data.length > 0 && _needAddUI) {
                          print(
                              "at UI: " + snapshot.data.data.length.toString());
                          totalItemList.addAll(snapshot.data.data);
                          _shouldLoadMore = true;
                          _needAddUI = false;
                        } else {
                          _shouldLoadMore = false;
                        }
                        return ListView.builder(
                            shrinkWrap: true,
                            controller: _scrollController,
                            itemCount: totalItemList.length,
                            itemBuilder: (context, index) {
                              return ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: 130, maxHeight: 170),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        SellDetailPage.ROUTE_NAME,
                                        arguments: {
                                          'postId': totalItemList[index].postId,
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
                                              tag: totalItemList[index].postId,
                                              child: CachedNetworkImage(
                                                imageUrl: totalItemList[index]
                                                    .thumbnail,
                                                placeholder: (context, url) =>
                                                    Image.asset(
                                                        "assets/images/placeholder.png",
                                                        width: 100,
                                                        height: 100),
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
                                                      totalItemList[index].title,
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
                                                      totalItemList[index].price !=
                                                          null &&
                                                          totalItemList[index]
                                                              .price !=
                                                              0
                                                          ? '${Helper.formatCurrency(totalItemList[index].price)} VND'
                                                          : "Liên hệ",
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
                                                      '${totalItemList[index].district ?? ""}' ?? "",
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
                                                      totalItemList[index]
                                                          .approvedDate,
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
                                          SizedBox(width: 2),
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
                            onRetryPressed: () => _newsBloc.requestGetAllAds(0,
                                topics: getTopicsString()));
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
}
