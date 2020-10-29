import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/mypost_response.dart';
import 'package:conecapp/ui/mypost/blocs/mypost_bloc.dart';
import 'package:flutter/material.dart';

import 'item_mypost.dart';

class ArchiveMyPost extends StatefulWidget {
  @override
  _ArchiveMyPostState createState() => _ArchiveMyPostState();
}

class _ArchiveMyPostState extends State<ArchiveMyPost> {
  MyPostBloc _myPostBloc;
  ScrollController _scrollController;

  //
  int _currentPage = 0;
  bool _shouldLoadMore = true;
  List<MyPost> archivedList = [];

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController()..addListener(_scrollListener);
    _myPostBloc = MyPostBloc();
    _myPostBloc.requestGetArchive(0);
    _currentPage = 1;
  }

  void _scrollListener() {
    print(_scrollController.position.extentAfter);
    if (_scrollController.position.extentAfter < 300) {
      if (_shouldLoadMore) {
        _shouldLoadMore = false;
        _myPostBloc.requestGetArchive(_currentPage);
        setState(() {
          _currentPage++;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _myPostBloc.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: StreamBuilder<ApiResponse<List<MyPost>>>(
          stream: _myPostBloc.archiveStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return UILoading(loadingMessage: snapshot.data.message);
                case Status.COMPLETED:
                  if (snapshot.data.data.length > 0) {
                    print("at UI: " + snapshot.data.data.length.toString());
                    archivedList.addAll(snapshot.data.data);
                    _shouldLoadMore = true;
                  } else {
                    _shouldLoadMore = false;
                  }
                  if (archivedList.length > 0) {
                    return ListView.builder(
                        itemCount: archivedList.length,
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          return ItemMyPost(
                            myPost: archivedList[index],
                            key: ValueKey("archive"),
                            index: index,
                            status: MyPostStatus.Archive,
                            callback: (id) {
                              archivedList.removeWhere(
                                  (element) => element.postId == id);
                              setState(() {});
                            },
                            refresh: (value) {
                              if (value != null && value) {
                                archivedList.clear();
                                _myPostBloc.requestGetArchive(0);
                                _currentPage = 1;
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
