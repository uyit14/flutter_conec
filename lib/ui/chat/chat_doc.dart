import 'package:conecapp/common/helper.dart';

class ChatDoc {
  String userName;
  String text;
  String userImage;
  bool userId;
  String docId;

  ChatDoc(this.userName, this.text, this.userImage, this.userId, this.docId);

  static String avatar = Helper.tempAvatar;

}
