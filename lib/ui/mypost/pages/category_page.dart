import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/ui/mypost/blocs/post_action_bloc.dart';
import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  static const ROUTE_NAME = '/category';

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  Topic _category;
  PostActionBloc _postActionBloc = PostActionBloc();

  @override
  void initState() {
    super.initState();
    _postActionBloc.requestGetTopicWithHeader();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs =
    ModalRoute.of(context).settings.arguments as Map<String, Object>;
    _category = routeArgs['category'] as Topic;
  }

  @override
  void dispose() {
    super.dispose();
    _postActionBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Chọn danh mục"),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _category != null
                    ? InkWell(
                  onTap: () {
                    Navigator.of(context).pop(_category);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text("Chọn gần đây",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w400)),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Text(_category.title,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500)),
                            Spacer(),
                            Icon(Icons.check, color: Colors.green,)
                          ],
                        ),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                )
                    : Container(),
                Container(
                  color: Colors.black12,
                  width: double.infinity,
                  height: 1,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: StreamBuilder<ApiResponse<List<Topic>>>(
                      stream: _postActionBloc.topicStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          switch (snapshot.data.status) {
                            case Status.LOADING:
                              return UILoading();
                            case Status.COMPLETED:
                              List<Topic> topic = snapshot.data.data;
                              if(topic.length > 0 && _category!=null){
                                int index = topic.indexWhere((element) => element.title == _category.title);
                                _category = topic[index];
                              }
                              return ListView.builder(
                                  itemCount: topic.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop(topic[index]);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              topic[index].title,
                                              style: TextStyle(fontSize: 17),
                                            ),
                                            SizedBox(height: 12),
                                            Container(
                                              color: Colors.black12,
                                              width: double.infinity,
                                              height: .7,
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            case Status.ERROR:
                              return UIError(errorMessage: snapshot.data.message);
                          }
                        }
                        return Center(child: Text("Không có dữ liệu"));
                      }),
                ),
              ],
            ),
          ),
        ));
  }
}
