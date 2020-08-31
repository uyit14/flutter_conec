import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/ui/home/pages/comment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:conecapp/models/response/comment/comment_response.dart';
import 'package:provider/provider.dart';

import 'item_child_page.dart';

class ItemParentPage extends StatefulWidget {
  final String postId;
  ItemParentPage(this.postId);

  @override
  _ItemParentPageState createState() => _ItemParentPageState();
}

class _ItemParentPageState extends State<ItemParentPage> {
  CommentBloc _commentBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _commentBloc = Provider.of<CommentBloc>(context);
    _commentBloc.requestComment(widget.postId);
//    _commentBloc.parentCommentStream.listen((event) {
//        switch(event.status){
//          case Status.COMPLETED:
//            List<Comment> comments = event.data;
//            comments.forEach((element) {
//              print("parent: " + element.id);
//              _commentBloc.requestChildComment(element.id);
//            });
//            break;
//        }
//    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
       //
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        child: StreamBuilder<ApiResponse<List<Comment>>>(
          stream: _commentBloc.parentCommentStream,
          builder: (context, snapshot) {
            if(snapshot.hasData){
              switch(snapshot.data.status){
                case Status.COMPLETED:
                  List<Comment> comments = snapshot.data.data;
                  comments.forEach((element) {
                    print("parent: " + element.id);
                  });
                  return Container(
                    height: 10,
                    child: ListView.builder(
                      itemCount: comments.length,
                        itemBuilder: (context, index){
                          return ItemChildPage(comments[index].id);
                        }
                    ),
                  );
              }
            }
            return Container();
          }
        ),
      ),
    );
  }
}
