import 'package:conecapp/common/helper.dart';

class CommentResponse {
  List<Comment> comments;

  CommentResponse({this.comments});

  CommentResponse.fromJson(Map<String, dynamic> json) {
    if (json['comments'] != null) {
      comments = new List<Comment>();
      json['comments'].forEach((v) {
        comments.add(new Comment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.comments != null) {
      data['comments'] = this.comments.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PostCommentResponse {
  Comment comments;

  PostCommentResponse({this.comments});

  PostCommentResponse.fromJson(Map<String, dynamic> json) {
    comments = json['comments'] != null
        ? new Comment.fromJson(json['comments'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.comments != null) {
      data['comments'] = this.comments.toJson();
    }
    return data;
  }
}

class Comment {
  String id;
  String parent;
  String created;
  String modified;
  String content;
  List<String> attachments;
  String creator;
  String fullname;
  String profilePictureUrl;
  bool createdByAdmin;
  bool createdByCurrentUser;
  int upvoteCount;
  bool userHasUpvoted;
  bool isNew;
  String ownerId;
  Comment(
      {this.id,
      this.parent,
      this.created,
      this.modified,
      this.content,
      this.attachments,
      this.creator,
      this.fullname,
      this.profilePictureUrl,
      this.createdByAdmin,
      this.createdByCurrentUser,
      this.upvoteCount,
      this.userHasUpvoted,
      this.ownerId,
      this.isNew});

  Comment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parent = json['parent'];
    created = json['created'];
    modified = json['modified'];
    content = json['content'];
    if (json['attachments'] != null) {
      attachments = new List<String>();
      json['attachments'].forEach((v) {
        attachments.add(v);
      });
    }
    creator = json['creator'];
    fullname = json['fullname'];
    profilePictureUrl = json['profile_picture_url'] !=null && !json['profile_picture_url'].contains("http") && json['profile_picture_url'].toString().length > 0 ? Helper.baseURL + json['profile_picture_url'] : json['profile_picture_url'];

    createdByAdmin = json['created_by_admin'];
    createdByCurrentUser = json['created_by_current_user'];
    upvoteCount = json['upvote_count'];
    userHasUpvoted = json['user_has_upvoted'];
    isNew = json['is_new'];
    ownerId = json['ownerId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['parent'] = this.parent;
    data['created'] = this.created;
    data['modified'] = this.modified;
    data['content'] = this.content;
    if (this.attachments != null) {
      data['attachments'] = this.attachments.map((v) => v).toList();
    }
    data['creator'] = this.creator;
    data['fullname'] = this.fullname;
    data['profile_picture_url'] = this.profilePictureUrl;
    data['created_by_admin'] = this.createdByAdmin;
    data['created_by_current_user'] = this.createdByCurrentUser;
    data['upvote_count'] = this.upvoteCount;
    data['user_has_upvoted'] = this.userHasUpvoted;
    data['is_new'] = this.isNew;
    return data;
  }
}
