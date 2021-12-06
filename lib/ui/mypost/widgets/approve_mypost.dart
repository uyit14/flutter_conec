import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/mypost_response.dart';
import 'package:conecapp/ui/mypost/blocs/mypost_bloc.dart';
import 'package:flutter/material.dart';

import 'item_mypost.dart';

class ApproveMyPost extends StatefulWidget {
  @override
  _ApproveMyPostState createState() => _ApproveMyPostState();
}

class _ApproveMyPostState extends State<ApproveMyPost> {
  MyPostBloc _myPostBloc;
  List<MyPost> myPosts = List();
  ScrollController _scrollController;
  bool _shouldLoadMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _myPostBloc = MyPostBloc();
    _scrollController = new ScrollController()..addListener(_scrollListener);
    _myPostBloc.requestApprove(1);
    _currentPage = 2;
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 250) {
      if (_shouldLoadMore) {
        _shouldLoadMore = false;
        _myPostBloc.requestApprove(_currentPage);
        setState(() {
          _currentPage++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: StreamBuilder<ApiResponse<List<MyPost>>>(
          stream: _myPostBloc.approveStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return UILoading(loadingMessage: snapshot.data.message);
                case Status.COMPLETED:
                  if (snapshot.data.data.length > 0) {
                    print("at UI: " + snapshot.data.data.length.toString());
                    myPosts.addAll(snapshot.data.data);
                    _shouldLoadMore = true;
                  } else {
                    _shouldLoadMore = false;
                  }
                  if (myPosts.length > 0) {
                    return ListView.builder(
                        itemCount: myPosts.length,
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          return ItemMyPost(
                            myPost: myPosts[index],
                            key: ValueKey("approve"),
                            index: index,
                            status: MyPostStatus.Approve,
                            callback: (id) {
                              myPosts.removeWhere(
                                  (element) => element.postId == id);
                              setState(() {});
                            },
                            refresh: (value) {
                              if (value != null && value) {
                                _currentPage = 1;
                                myPosts.clear();
                                _myPostBloc.requestApprove(1);
                                _currentPage = 2;
                              }
                            },
                          );
                        });
                  }
                  return Container(
                      child: Center(child: Text("Không có dữ liệu")));
                case Status.ERROR:
                  return UIError(errorMessage: snapshot.data.message);
              }
            }
            return Container(
              child: Center(
                child: Text("Không có dữ liệu"),
              ),
            );
          }),
    );
  }
}
