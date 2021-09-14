import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/latest_item.dart';
import 'package:conecapp/models/response/location/city_response.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/ui/address/district_page.dart';
import 'package:conecapp/ui/address/province_page.dart';
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:conecapp/ui/home/blocs/items_by_category_bloc.dart';
import 'package:conecapp/ui/home/pages/item_detail_page.dart';
import 'package:conecapp/ui/mypost/pages/category_page.dart';
import 'package:conecapp/ui/mypost/pages/sub_category_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart';

class ItemByCategory extends StatefulWidget {
  static const ROUTE_NAME = '/items-category';

  @override
  _ItemByCategoryState createState() => _ItemByCategoryState();
}

class _ItemByCategoryState extends State<ItemByCategory> {
  ScrollController _scrollController;
  final _controller = TextEditingController();
  ItemsByCategoryBloc _itemsByCategoryBloc = ItemsByCategoryBloc();

  //var selectedCategory;
  bool _needAddUI = true;
  HomeBloc _homeBloc = HomeBloc();

  List<Topic> _listTopic = List<Topic>();
  List<LatestItem> totalItemList = List<LatestItem>();
  var routeArgs;

  //String categoryTitle;
  //var categoryId;
  bool _firstTime;
  int _currentPage = 1;
  bool _shouldLoadMore = true;
  List<Topic> _topics = List();
  Topic topic;

  //
  Province provinceData;
  Province districtData;
  String _keyword;

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController()..addListener(_scrollListener);
    _itemsByCategoryBloc = ItemsByCategoryBloc();
    _firstTime = true;
    _homeBloc.requestGetTopic();
    _homeBloc.topicStream.listen((event) {
      switch (event.status) {
        case Status.COMPLETED:
          _listTopic.addAll(event.data);
          break;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint("didChangeDependencies");
    if (_firstTime) {
      routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, Object>;
      if (routeArgs['id'] != null && routeArgs['title'] != null) {
        topic = Topic(
            id: routeArgs['id'] as String, title: routeArgs['title'] as String);
      }

      _itemsByCategoryBloc.requestGetAllItem(_currentPage, "",
          topic: topic != null ? topic.title : "");
      _currentPage = 2;
    }
  }

  String getTopicsString() {
    String topicsString = "";
    for (int i = 0; i < _topics.length; i++) {
      if (i == 0) {
        topicsString = _topics[0].id;
      } else {
        topicsString = topicsString + ';${_topics[i].id}';
      }
    }
    return topicsString;
  }

  void _scrollListener() {
    print(_scrollController.position.extentAfter);
    if (_scrollController.position.extentAfter < 500) {
      setState(() {
        _needAddUI = true;
      });
      if (_shouldLoadMore) {
        _shouldLoadMore = false;
        _itemsByCategoryBloc.requestGetAllItem(_currentPage, getTopicsString(),
            province: provinceData != null ? provinceData.name : "",
            district: districtData != null ? districtData.name : "",
            topic: topic != null ? topic.title : "",
            club: "",
            keyword: _keyword);
        setState(() {
          _currentPage++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: AppTheme.appBarSize,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(context),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black12,
                  ),
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 35,
                  child: TextFormField(
                    maxLines: 1,
                    onChanged: (value) {
                      setState(() {
                        _keyword = value;
                      });
                      // setState(() {
                      //   _needAddUI = true;
                      // });
                      // if(value.length == 0){
                      //   print("goto here");
                      //   totalItemList.clear();
                      //   _itemsByCategoryBloc.clearSearch();
                      //   _controller.clear();
                      // }else{
                      //   totalItemList.clear();
                      //   _itemsByCategoryBloc.searchAction(value);
                      // }
                    },
                    onFieldSubmitted: (value) {
                      setState(() {
                        _needAddUI = true;
                      });
                      _currentPage = 1;
                      totalItemList.clear();
                      _itemsByCategoryBloc.requestGetAllItem(
                          _currentPage, getTopicsString(),
                          keyword: value);
                      _currentPage = 2;
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    controller: _controller,
                    style: TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'Nhập thông tin bạn muốn tìm kiếm',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.white, width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: EdgeInsets.only(left: 8),
                    ),
                  ),
                ),
                InkWell(
                  //child: Text("Hủy", style: AppTheme.changeTextStyle(true)),
                  child: Icon(Icons.search),
                  onTap: () {
                    // setState(() {
                    //   _needAddUI = true;
                    // });
                    // totalItemList.clear();
                    // _itemsByCategoryBloc.clearSearch();
                    // _controller.clear();
                    setState(() {
                      _needAddUI = true;
                    });
                    _currentPage = 1;
                    totalItemList.clear();
                    _itemsByCategoryBloc.requestGetAllItem(
                        _currentPage, getTopicsString(),
                        province: provinceData != null
                            ? provinceData.name
                            : "",
                        district: districtData != null
                            ? districtData.name
                            : "",
                        keyword: _keyword);
                    _currentPage = 2;
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
                SizedBox(width: 16),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.symmetric(
                    vertical: BorderSide(color: Colors.grey, width: 0.5))),
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(ProvincePage.ROUTE_NAME,
                          arguments: {'province': provinceData}).then((value) {
                        if (value != null) {
                          setState(() {
                            provinceData = value;
                            _needAddUI = true;
                          });
                          _currentPage = 1;
                          totalItemList.clear();
                          _itemsByCategoryBloc.requestGetAllItem(
                              _currentPage, getTopicsString(),
                              province: provinceData.name,
                              topic: topic != null ? topic.title : "");
                          _currentPage = 2;
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.5, color: Colors.grey),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              provinceData != null
                                  ? provinceData.name
                                  : "Tỉnh/Thành phố",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down)
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Flexible(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      if (provinceData != null) {
                        Navigator.of(context).pushNamed(DistrictPage.ROUTE_NAME,
                            arguments: {
                              'district': districtData,
                              'provinceId': provinceData.id
                            }).then((value) {
                          if (value != null) {
                            setState(() {
                              districtData = value;
                              _needAddUI = true;
                            });
                            _currentPage = 1;
                            totalItemList.clear();
                            _itemsByCategoryBloc.requestGetAllItem(
                                _currentPage, getTopicsString(),
                                province: provinceData.name,
                                district: districtData.name);
                            _currentPage = 2;
                          }
                        });
                      } else {
                        Fluttertoast.showToast(
                            msg: "Vui lòng chọn tỉnh, thành");
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                      decoration: BoxDecoration(
                          color: provinceData != null
                              ? Colors.white
                              : Colors.black12,
                          border: Border.all(width: 0.5, color: Colors.grey),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              districtData != null
                                  ? districtData.name
                                  : "Quận/Huyện",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: provinceData != null
                                      ? Colors.black87
                                      : Colors.grey),
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down)
                        ],
                      ),
                    ),
                  ),
                ),
                // SizedBox(width: 4),
                // Flexible(
                //   flex: 1,
                //   child: InkWell(
                //     onTap: () {
                //       Navigator.of(context).pushNamed(CategoryPage.ROUTE_NAME,
                //           arguments: {'category': topic}).then((value) {
                //         if (value != null) {
                //           setState(() {
                //             topic = value;
                //           });
                //         }
                //       });
                //     },
                //     child: Container(
                //       padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                //       decoration: BoxDecoration(
                //           border: Border.all(width: 0.5, color: Colors.grey),
                //           borderRadius: BorderRadius.circular(8)),
                //       child: Row(
                //         children: <Widget>[
                //           Expanded(
                //             child: Text(
                //               topic != null ? topic.title : "Chuyên mục",
                //               maxLines: 1,
                //               overflow: TextOverflow.ellipsis,
                //             ),
                //           ),
                //           Icon(Icons.keyboard_arrow_down)
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          topic!=null && topic.id == "45f6d14c-3cb7-4bc9-91c1-1cc541dd8893"
              ? Container(
                  margin: EdgeInsets.only(top: 4),
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.symmetric(
                          vertical:
                              BorderSide(color: Colors.grey, width: 0.5))),
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
                                arguments: {"topicId": topic.id}).then((value) {
                              if (value != null) {
                                print(value);
                                setState(() {
                                  _needAddUI = true;
                                  _topics.addAll(value);
                                });
                                print(_topics.length);
                                //TODO - call api with province here
                                _currentPage = 1;
                                totalItemList.clear();
                                _itemsByCategoryBloc.requestGetAllItem(
                                    _currentPage, getTopicsString(),
                                    province: provinceData != null
                                        ? provinceData.name
                                        : "",
                                    district: districtData != null
                                        ? districtData.name
                                        : "",
                                    topic: topic != null ? topic.title : "",
                                    club: "",
                                    keyword: _keyword);
                                _currentPage = 2;
                              }
                            });
                          },
                          child: _topics.length > 0
                              ? Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: MediaQuery.of(context).size.width -
                                          70,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: _topics
                                            .map((e) => Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 6),
                                                  margin:
                                                      EdgeInsets.only(right: 8),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 0.5,
                                                          color: Colors.grey),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  child: Center(
                                                      child:
                                                          Text(e.title ?? "")),
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
                                          _itemsByCategoryBloc
                                              .requestGetAllItem(0, "",
                                                  topic: topic != null
                                                      ? topic.title
                                                      : "");
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
                                      border: Border.all(
                                          width: 0.5, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    children: <Widget>[
                                      Text("Chọn môn võ"),
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
                )
              : Container(),
          Expanded(
            child: StreamBuilder<ApiResponse<List<LatestItem>>>(
                stream: _itemsByCategoryBloc.allItemStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.data.status) {
                      case Status.LOADING:
                        return UILoading(loadingMessage: snapshot.data.message);
                      case Status.COMPLETED:
                        //List<LatestItem> totalItemList = snapshot.data.data;
                        print("at UI: " +
                            snapshot.data.data.length.toString() +
                            'with page $_currentPage');
                        if (snapshot.data.data.length > 0 && _needAddUI) {
                          totalItemList.addAll(snapshot.data.data);
                          _shouldLoadMore = true;
                          _needAddUI = false;
                        } else {
                          _shouldLoadMore = false;
                        }
                        if (topic != null && _firstTime) {
                          //totalItemList.clear();
                          // _itemsByCategoryBloc
                          //     .filterTopic(categoryTitle.toLowerCase());
                        }
                        _firstTime = false;
                        return ListView.builder(
                            controller: _scrollController,
                            itemCount: totalItemList.length,
                            itemBuilder: (context, index) {
                              final document =
                                  parse(totalItemList[index].description ?? "");
                              final String parsedString =
                                  parse(document.body.text)
                                      .documentElement
                                      .text;
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      ItemDetailPage.ROUTE_NAME,
                                      arguments: {
                                        'postId': totalItemList[index].postId,
                                        'title': totalItemList[index].title
                                      });
                                },
                                child: Card(
                                  margin: EdgeInsets.all(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          totalItemList[index].title,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                                flex: 4,
                                                child: Hero(
                                                  tag: totalItemList[index]
                                                      .postId,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          totalItemList[index]
                                                              .thumbnail,
                                                      placeholder: (context,
                                                              url) =>
                                                          Image.asset(
                                                              "assets/images/placeholder.png",
                                                              width: 100,
                                                              height: 120),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Image.asset(
                                                        "assets/images/error.png",
                                                        height: 100,
                                                        width: 120,
                                                      ),
                                                      fit: BoxFit.cover,
                                                      height: 100,
                                                      width: 120,
                                                    ),
                                                  ),
                                                )),
                                            SizedBox(width: 6),
                                            Flexible(
                                              flex: 6,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    parsedString ?? "",
                                                    maxLines: 3,
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    totalItemList[index]
                                                                    .joiningFee !=
                                                                null &&
                                                            totalItemList[index]
                                                                    .joiningFee !=
                                                                0
                                                        ? '${Helper.formatCurrency(totalItemList[index].joiningFee)} VND / ${totalItemList[index].joiningFeePeriod ?? ""}'
                                                        : "Liên hệ",
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                              child: Text(
                                                '${totalItemList[index].district} - ${totalItemList[index].province}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                                totalItemList[index]
                                                    .approvedDate,
                                                style: TextStyle(
                                                    fontStyle:
                                                        FontStyle.italic))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      case Status.ERROR:
                        return UIError(errorMessage: snapshot.data.message);
                    }
                  }
                  return Container(child: Center(child: Text("No data")));
                }),
          )
        ],
      )),
    );
  }

  @override
  void dispose() {
    _itemsByCategoryBloc.dispose();
    super.dispose();
    _scrollController.dispose();
  }

// void showCategoryList(int index) {
//   var controller = FixedExtentScrollController(initialItem: index);
//   showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           color: Colors.white,
//           height: 250,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               FlatButton(
//                 child: Text("Xong", style: AppTheme.changeTextStyle(true)),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   if (selectedCategory == null) {
//                     selectedCategory = _listTopic[0].title;
//                     categoryId = _listTopic[0].id;
//                   }
//                 },
//               ),
//               Expanded(
//                 child: CupertinoPicker(
//                   scrollController: controller,
//                   onSelectedItemChanged: (value) {
//                     setState(() {
//                       selectedCategory = _listTopic[value].title;
//                       categoryId = _listTopic[value].id;
//                     });
//                   },
//                   itemExtent: 32,
//                   children: _listTopic.map((e) => Text(e.title)).toList(),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).then((value) {
//     if (selectedCategory == null) {
//       selectedCategory = _listTopic[0].title;
//       categoryId = _listTopic[0].title;
//     }
//     totalItemList.clear();
//     setState(() {
//       _currentPage = 1;
//       _needAddUI = true;
//     });
//     _itemsByCategoryBloc.requestGetAllItem(_currentPage, getTopicsString(),
//         province: provinceData != null ? provinceData.name : "",
//         district: districtData != null ? districtData.name : "",
//         topic: selectedCategory ?? "",
//         club: "");
//     _currentPage = 1;
//   });
// }
}
