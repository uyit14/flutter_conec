import 'package:conecapp/repositories/home/home_remote_repository.dart';

class ReportBloc {
  HomeRemoteRepository _repository;
  ReportBloc() {
    _repository = HomeRemoteRepository();
  }

  void requestReport(String postId, String content, String reason)async{
    final result = await _repository.reportPost(postId, content, reason);
    if(result){
      print("report success");
    }else{
      print("report fail");
    }
  }
}