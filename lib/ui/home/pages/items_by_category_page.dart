import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/app_theme.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/dummy/dummy_data.dart';
import 'package:conecapp/models/response/latest_item.dart';
import 'package:conecapp/ui/home/blocs/items_by_category_bloc.dart';
import 'package:conecapp/ui/home/pages/item_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemByCategory extends StatefulWidget {
  static const ROUTE_NAME = '/items-category';

  @override
  _ItemByCategoryState createState() => _ItemByCategoryState();
}

class _ItemByCategoryState extends State<ItemByCategory> {
  final _scrollController = ScrollController();
  final _controller = TextEditingController();
  final _scrollThreshold = 250.0;
  bool _firstTime;
  ItemsByCategoryBloc _itemsByCategoryBloc;
  var routeArgs;
  String categoryTitle;
  var categoryId;

  @override
  void initState() {
    super.initState();
    _firstTime = true;
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint("didChangeDependencies");
    routeArgs = ModalRoute.of(context).settings.arguments as Map<String, Object>;
    categoryTitle = routeArgs['title'] as String;
    categoryId = routeArgs['id'] as String;
    _itemsByCategoryBloc = Provider.of<ItemsByCategoryBloc>(context);
    if (_firstTime) {
        _itemsByCategoryBloc.requestGetAllItem();
      _firstTime = false;
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
                    onChanged: (value){
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
                        ? DummyData.categories.indexOf(DummyData.categories
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
                        List<LatestItem> items = snapshot.data.data;
                        if(categoryTitle!=null){
                          _itemsByCategoryBloc.filterByCategory(categoryTitle.toLowerCase());
                        }
                        return ListView.builder(
                            controller: _scrollController,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      ItemDetailPage.ROUTE_NAME,
                                      arguments: {
                                        'postId': items[index].postId,
                                        'title': items[index].title
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
                                          items[index].title,
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
                                                  tag: items[index].postId,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    child: CachedNetworkImage(
                                                      imageUrl: items[index]
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
                                                    items[index].description ?? "",
                                                    maxLines: 3,
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    items[index].joiningFee !=
                                                            null
                                                        ? '${Helper.formatCurrency(items[index].joiningFee)} VND'
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
                                            Text("Thủ Đức, Hồ Chí Minh"),
                                            Text(items[index].publishedDate,
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

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      //TODO - do load more later
      // _itemsByCategoryBloc.requestLoadList(true);
    }
  }

  //bottom sheet
  var selectedCity;
  var selectedDistrict;
  var selectedCategory;

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
                  selectedCategory = DummyData.categories[value].title;
                });
              },
              itemExtent: 32,
              children: DummyData.categories.map((e) => Text(e.title)).toList(),
            ),
          );
        }).then((value) => debugPrint(selectedCategory));
  }
}
