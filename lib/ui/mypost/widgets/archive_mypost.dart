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
  @override
  void initState() {
    super.initState();
    _myPostBloc = MyPostBloc();
    _myPostBloc.requestGetArchive(0);
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
                  List<MyPost> archivedList = snapshot.data.data;
                  if(archivedList.length > 0){
                    return ListView.builder(
                        itemCount: archivedList.length,
                        itemBuilder: (context, index) {
                          return ItemMyPost(
                            myPost: archivedList[index],
                            key: ValueKey("archive"),
                            index: index,
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
                  }
                  return Container(child: Center(child: Text("Không có dữ liệu")));
                case Status.ERROR:
                  return UIError(errorMessage: snapshot.data.message);
              }
            }
            return Container(child: Center(child: Text("Không có dữ liệu"),),);
          }),
    );
  }
}
