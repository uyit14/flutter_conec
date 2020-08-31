import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/ui/home/pages/comment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:conecapp/models/response/comment/comment_response.dart';
import 'package:provider/provider.dart';

class ItemChildPage extends StatefulWidget {
  final String parentId;
  ItemChildPage(this.parentId);

  @override
  _ItemChildPageState createState() => _ItemChildPageState();
}

class _ItemChildPageState extends State<ItemChildPage> {
  CommentBloc _commentBloc = CommentBloc();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_commentBloc = Provider.of<CommentBloc>(context);
    _commentBloc.requestChildComment(widget.parentId);
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
            stream: _commentBloc.childCommentStream,
            builder: (context, snapshot) {
              if(snapshot.hasData){
                switch(snapshot.data.status){
                  case Status.COMPLETED:
                    List<Comment> comments = snapshot.data.data;
                    comments.forEach((element) {
                      print("child: " + element.id);
                    });
                    return Container(color: Colors.red);
                }
              }
              return Container();
            }
        ),
      ),
    );
  }
}
