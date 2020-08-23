class CommentRequest{
  final String content;
  final String parentId;
  final String postId;
  CommentRequest({this.content, this.parentId, this.postId});

  Map<String, dynamic> toJson() =>
      {
        'content': content,
        'parent': parentId,
        'postId': postId,
      };
}