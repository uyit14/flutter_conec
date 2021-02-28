import 'package:chips_choice/chips_choice.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/topic.dart';
import 'package:conecapp/ui/mypost/blocs/post_action_bloc.dart';
import 'package:flutter/material.dart';

class SubCategoryPage extends StatefulWidget {
  static const ROUTE_NAME = '/sub-category';

  @override
  _SubCategoryPageState createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  PostActionBloc _postActionBloc = PostActionBloc();
  List<Topic> tags = List();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _postActionBloc.requestGetSubTopicWithHeader(true);
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
        title: Text("Chọn danh mục môn"),
        actions: [
          FlatButton.icon(
              onPressed: () {
                Navigator.of(context).pop(tags);
              },
              icon: Icon(Icons.youtube_searched_for, color: Colors.yellow, size: 32,),
              label: Text(
                "Tiếp tục",
                style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ))
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: StreamBuilder<ApiResponse<List<Topic>>>(
                  stream: _postActionBloc.subTopicStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      switch (snapshot.data.status) {
                        case Status.LOADING:
                          return UILoading();
                        case Status.COMPLETED:
                          List<Topic> topics = snapshot.data.data;
                          return Container(
                            child: ChipsChoice<Topic>.multiple(
                              value: tags,
                              wrapped: true,
                              onChanged: (val) => setState(() => tags = val),
                              choiceItems: C2Choice.listFrom<Topic, Topic>(
                                source: topics,
                                value: (i, v) => v,
                                label: (i, v) => v.title,
                                tooltip: (i, v) => v.title,
                              ),
                            ),
                          );
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
