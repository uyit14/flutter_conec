import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/models/response/mypost_response.dart';
import 'package:conecapp/ui/mypost/blocs/mypost_bloc.dart';
import 'package:flutter/material.dart';

import 'item_mypost.dart';

class PendingMyPost extends StatefulWidget {
  @override
  _PendingMyPostState createState() => _PendingMyPostState();
}

class _PendingMyPostState extends State<PendingMyPost> {
  MyPostBloc _myPostBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _myPostBloc = MyPostBloc();
    _myPostBloc.requestGetPending(0);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: StreamBuilder<ApiResponse<List<MyPost>>>(
          stream: _myPostBloc.pendingStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return UILoading(loadingMessage: snapshot.data.message);
                case Status.COMPLETED:
                  List<MyPost> myPosts = snapshot.data.data;
                  return ListView.builder(
                      itemCount: myPosts.length,
                      itemBuilder: (context, index) {
                        return ItemMyPost(
                            myPost: myPosts[index],
                            key: ValueKey("pending"),
                            status: MyPostStatus.Pending, callback: (id){
                          myPosts.removeWhere((element) => element.postId == id);
                          setState(() {
                          });
                        }, refresh: (value){
                          if(value!=null && value){
                            _myPostBloc.requestGetPending(0);
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
