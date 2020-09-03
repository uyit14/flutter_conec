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
  final _scrollController = ScrollController();
  int _currentPage = 0;
  bool _shouldLoadMore = true;
  //
  List<MyPost> archivedList = List<MyPost>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _myPostBloc = MyPostBloc();
    _myPostBloc.requestGetArchive(_currentPage);
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 250) {
      if(_shouldLoadMore){
        _myPostBloc.requestGetArchive(_currentPage);
      }
    }
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
                  if(snapshot.data.data.length > 0){
                    archivedList.addAll(snapshot.data.data);
                    _currentPage++;
                  }else{
                    _shouldLoadMore = false;
                  }
                  return ListView.builder(
                      controller: _scrollController,
                      itemCount: archivedList.length,
                      itemBuilder: (context, index) {
                        return ItemMyPost(
                            myPost: archivedList[index],
                            key: ValueKey("archive"),
                            status: MyPostStatus.Archive,
                        callback: (id){
                          archivedList.removeWhere((element) => element.postId == id);
                              setState(() {
                              });
                        }, refresh: (value){
                              if(value!=null && value){
                                archivedList.clear();
                                _myPostBloc.requestGetArchive(0);
                              }
                        },);
                      });
                case Status.ERROR:
                  return UIError(errorMessage: snapshot.data.message);
              }
            }
            return Container(child: Center(child: Text("Không có dữ liệu"),),);
          }),
    );
  }
}
