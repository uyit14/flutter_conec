import 'package:conecapp/ui/mypost/widgets/item_mypost.dart';

class Category {
  final int id;
  final String title;
  final String image;

  Category({this.id, this.title, this.image});
}

class Item {
  final int id;
  final String title;
  final String content;

  Item({this.id, this.title, this.content});
}

class MyPost {
  final String image;
  final MyPostStatus status;

  MyPost({this.image, this.status});
}

class Notify {
  final String title;
  final String content;
  final String date;
  final bool isRead;

  Notify({this.title, this.content, this.date, this.isRead = true});
}
