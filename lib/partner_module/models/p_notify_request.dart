class PNotifyRequest {
  String id;
  String postId;
  String color;
  String content;
  String title;
  int orderNo;

  PNotifyRequest(
      {this.id,
      this.postId,
      this.color,
      this.content,
      this.title,
      this.orderNo});

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (postId != null) 'postId': postId,
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (color != null) 'color': color,
        if (orderNo != null) 'orderNo': orderNo,
      };
}
