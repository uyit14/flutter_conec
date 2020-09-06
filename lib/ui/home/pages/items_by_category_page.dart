import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/latest_item.dart';
import 'package:conecapp/models/response/location/city_response.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:conecapp/ui/home/blocs/items_by_category_bloc.dart';
import 'package:conecapp/ui/home/pages/item_detail_page.dart';
import 'package:conecapp/ui/mypost/blocs/post_action_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemByCategory extends StatefulWidget {
  static const ROUTE_NAME = '/items-category';

  @override
  _ItemByCategoryState createState() => _ItemByCategoryState();
}

class _ItemByCategoryState extends State<ItemByCategory> {
  ScrollController _scrollController;
  final _controller = TextEditingController();
  final _scrollThreshold = 250.0;
  ItemsByCategoryBloc _itemsByCategoryBloc;
  PostActionBloc _postActionBloc = PostActionBloc();
  HomeBloc _homeBloc = HomeBloc();
  List<Province> _listProvinces = List<Province>();
  List<Topic> _listTopic = List<Topic>();
  List<LatestItem> totalItemList = List<LatestItem>();
  var routeArgs;
  String categoryTitle;
  var categoryId;
  bool _firstTime;
  int _currentPage = 0;
  bool _shouldLoadMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController()..addListener(_scrollListener);
    _itemsByCategoryBloc = ItemsByCategoryBloc();
    _firstTime = true;
    _postActionBloc.requestGetProvinces();
    _postActionBloc.provincesStream.listen((event) {
      switch (event.status) {
        case Status.COMPLETED:
          _listProvinces.addAll(event.data);
          break;
      }
    });
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
    routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    categoryTitle = routeArgs['title'] as String;
    categoryId = routeArgs['id'] as String;
    _itemsByCategoryBloc = Provider.of<ItemsByCategoryBloc>(context);
    if (_firstTime) {
      _itemsByCategoryBloc.requestGetAllItem(_currentPage);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 500) {
      if(_shouldLoadMore){
        _itemsByCategoryBloc.requestGetAllItem(_currentPage);
      }
    }
  }

//  void _onScroll() {
//    final maxScroll = _scrollController.position.maxScrollExtent;
//    final currentScroll = _scrollController.position.pixels;
//    if (maxScroll - currentScroll <= 250) {
//      if(_shouldLoadMore){
//        _itemsByCategoryBloc.requestGetAllItem(_currentPage);
//      }
//      // _itemsByCategoryBloc.requestLoadList(true);
//    }
//  }

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
                      totalItemList.clear();
                      _itemsByCategoryBloc.searchAction(value);
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
                  child: Text("Hủy", style: AppTheme.changeTextStyle(true)),
                  onTap: () {
                    _itemsByCategoryBloc.clearSearch();
                    _controller.clear();
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  InkWell(
                    onTap: () =>
                        showCityList(getIndex(_listProvinces, selectedCity)),
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
                            getIndex(_districtList, selectedDistrict))
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
                          Text(
                            selectedDistrict ?? "Quận/Huyện",
                            style: TextStyle(
                                color: selectedCity != null
                                    ? Colors.black87
                                    : Colors.grey),
                          ),
                          Icon(Icons.keyboard_arrow_down)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  InkWell(
                    onTap: () => showCategoryList(categoryId != null
                        ?_listTopic.indexOf(_listTopic
                            .firstWhere((element) => element.id == categoryId))
                        : 0),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.5, color: Colors.grey),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: <Widget>[
                          Text(selectedCategory ??
                              categoryTitle ??
                              "Chuyên mục"),
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
            child: StreamBuilder<ApiResponse<List<LatestItem>>>(
                stream: _itemsByCategoryBloc.allItemStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.data.status) {
                      case Status.LOADING:
                        return UILoading(loadingMessage: snapshot.data.message);
                      case Status.COMPLETED:
                        //List<LatestItem> items = snapshot.data.data;
                        if(snapshot.data.data.length > 0){
                          print("at UI: " + snapshot.data.data.length.toString());
                          totalItemList.addAll(snapshot.data.data);
                          _currentPage++;
                        }else{
                          _shouldLoadMore = false;
                        }
                        if (categoryTitle != null && _firstTime) {
                          totalItemList.clear();
                          _itemsByCategoryBloc
                              .filterTopic(categoryTitle.toLowerCase());
                        }
                        _firstTime = false;
                        return ListView.builder(
                            controller: _scrollController,
                            itemCount: totalItemList.length,
                            itemBuilder: (context, index) {
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
                                                  tag: totalItemList[index].postId,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    child: CachedNetworkImage(
                                                      imageUrl: totalItemList[index]
                                                          .thumbnail,
                                                      progressIndicatorBuilder: (context,
                                                              url,
                                                              downloadProgress) =>
                                                          CircularProgressIndicator(
                                                              value:
                                                                  downloadProgress
                                                                      .progress),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Image.asset(
                                                              "assets/images/error.png"),
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
                                                    totalItemList[index].description ??
                                                        "",
                                                    maxLines: 3,
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    totalItemList[index].joiningFee !=
                                                            null
                                                        ? '${Helper.formatCurrency(totalItemList[index].joiningFee)} VND'
                                                        : "Không tốn phí tham gia",
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
                                              width: MediaQuery.of(context).size.width/2,
                                              child: Text(
                                                '${totalItemList[index].district} - ${totalItemList[index].province}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(totalItemList[index].approvedDate,
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

  //bottom sheet
  var selectedCity;
  var selectedDistrict;
  var selectedCategory;
  String _selectCityId;
  String _selectDistrictId;
  List<Province> _districtList = List<Province>();

  //
  int getIndex(List<Province> list, String selectedItemId) {
    int index = list.indexOf(list.firstWhere(
        (element) => element.id == selectedItemId,
        orElse: () => list != null ? list[0] : null));
    if (index == -1) {
      return 0;
    }
    return selectedItemId != null ? index : 0;
  }

  void getDistrictByProvinceId(String id) {
    _postActionBloc.requestGetDistricts(id);
    _postActionBloc.districtsStream.listen((event) {
      switch (event.status) {
        case Status.COMPLETED:
          _districtList = event.data;
          break;
      }
    });
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
                  selectedCity = _listProvinces[value].name;
                  _selectCityId = _listProvinces[value].id;
                });
              },
              itemExtent: 32,
              children: _listProvinces.map((e) => Text(e.name)).toList(),
            ),
          );
        }).then((value) {
      selectedDistrict = null;
      if (selectedCity == null) {
        selectedCity = _listProvinces[0].name;
        _selectCityId = _listProvinces[0].id;
      }
      totalItemList.clear();
      _itemsByCategoryBloc.filterCity(selectedCity.toString().toLowerCase());
      getDistrictByProvinceId(
          _selectCityId ?? "8046b1ab-4479-4086-b986-3369fcb51f1a");
    });
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
                  selectedDistrict = _districtList[value].name;
                  _selectDistrictId = _districtList[value].id;
                });
              },
              itemExtent: 32,
              children: _districtList.map((e) => Text(e.name)).toList(),
            ),
          );
        }).then((value) {
      if (selectedCity == null) {
        selectedDistrict = _districtList[0].name;
        _selectDistrictId = _districtList[0].id;
      }
      print(selectedDistrict);
      totalItemList.clear();
      _itemsByCategoryBloc
          .filterDistrict(selectedDistrict.toString().toLowerCase());
    });
  }

  void showCategoryList(int index) {
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
                  selectedCategory = _listTopic[value].title;
                });
              },
              itemExtent: 32,
              children: _listTopic.map((e) => Text(e.title)).toList(),
            ),
          );
        }).then((value) {
          if(selectedCategory==null){
            selectedCategory = _listTopic[0].title;
          }
          totalItemList.clear();
          _itemsByCategoryBloc.filterTopic(selectedCategory);
    });
  }
}
