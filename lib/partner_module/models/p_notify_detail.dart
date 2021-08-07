import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/topic.dart';

class PNotifyDetailResponse {
  bool status;
  PNotifyFull notifyFull;

  PNotifyDetailResponse({this.status, this.notifyFull});

  PNotifyDetailResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    notifyFull = json['post'] != null ? new PNotifyFull.fromJson(json['post']) : null;
  }
}

class PNotifyFull {
  String postId;
  String title;
  String description;
  String content;
  String approvedDate;
  String owner;
  String ownerId;
  String ownerAvatar;
  int ratingCount;
  int ratingAvg;
  bool isRating;
  int viewCount;
  int commentCount;
  int userViewPostCount;
  int likeCount;
  bool likeOwner;
  bool isLikeOwner;
  String thumbnail;
  String topicId;
  String topic;
  List<Images> images;
  String province;
  String district;
  String ward;
  String address;
  String getAddress;
  double lat;
  double lng;
  int joiningFee;
  String joiningFeePeriod;
  String uses;
  double price;
  String generalCondition;
  String phoneNumber;
  String status;
  bool hidden;
  String shareLink;
  List<SubTopics> subTopics;
  List<Topic> topics;
  List<NotificationInDetail> notificationsInDetail;

  PNotifyFull(
      {this.postId,
        this.title,
        this.description,
        this.content,
        this.approvedDate,
        this.owner,
        this.ownerId,
        this.ownerAvatar,
        this.ratingCount,
        this.ratingAvg,
        this.isRating,
        this.viewCount,
        this.commentCount,
        this.userViewPostCount,
        this.likeCount,
        this.likeOwner,
        this.isLikeOwner,
        this.thumbnail,
        this.topicId,
        this.topic,
        this.images,
        this.province,
        this.district,
        this.ward,
        this.address,
        this.getAddress,
        this.lat,
        this.lng,
        this.joiningFee,
        this.joiningFeePeriod,
        this.uses,
        this.price,
        this.generalCondition,
        this.phoneNumber,
        this.status,
        this.hidden,
        this.shareLink,
        this.subTopics,
        this.topics,
        this.notificationsInDetail});

  PNotifyFull.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    title = json['title'];
    description = json['description'];
    content = json['content'];
    approvedDate = Helper.formatNotifyDate(json['approvedDate']);
    owner = json['owner'];
    ownerId = json['ownerId'];
    ownerAvatar = json['ownerAvatar'];
    ratingCount = json['ratingCount'];
    ratingAvg = json['ratingAvg'];
    isRating = json['isRating'];
    viewCount = json['viewCount'];
    commentCount = json['commentCount'];
    userViewPostCount = json['userViewPostCount'];
    likeCount = json['likeCount'];
    likeOwner = json['likeOwner'];
    isLikeOwner = json['isLikeOwner'];
    thumbnail = json['thumbnail'];
    topicId = json['topicId'];
    topic = json['topic'];
    if (json['images'] != null) {
      images = new List<Images>();
      json['images'].forEach((v) {
        images.add(new Images.fromJson(v));
      });
    }
    province = json['province'];
    district = json['district'];
    ward = json['ward'];
    address = json['address'];
    getAddress = json['getAddress'];
    lat = json['lat'];
    lng = json['lng'];
    joiningFee = json['joiningFee'];
    joiningFeePeriod = json['joiningFeePeriod'];
    uses = json['uses'];
    price = json['price'];
    generalCondition = json['generalCondition'];
    phoneNumber = json['phoneNumber'];
    status = json['status'];
    hidden = json['hidden'];
    shareLink = json['shareLink'];
    if (json['subTopics'] != null) {
      subTopics = new List<SubTopics>();
      json['subTopics'].forEach((v) {
        subTopics.add(new SubTopics.fromJson(v));
      });
    }
    if (json['topics'] != null) {
      topics = new List<Topic>();
      json['topics'].forEach((v) {
        topics.add(new Topic.fromJson(v));
      });
    }
    if (json['notifications'] != null) {
      notificationsInDetail = new List<NotificationInDetail>();
      json['notifications'].forEach((v) {
        notificationsInDetail.add(new NotificationInDetail.fromJson(v));
      });
    }
  }
}

class Images {
  String id;
  String fileName;
  String created;

  Images({this.id, this.fileName, this.created});

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fileName = json['fileName'];
    created = json['created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['fileName'] = this.fileName;
    data['created'] = this.created;
    return data;
  }
}

class SubTopics {
  String id;
  String title;
  String desciption;
  int orderNo;
  String thumbnail;

  SubTopics(
      {this.id, this.title, this.desciption, this.orderNo, this.thumbnail});

  SubTopics.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    desciption = json['desciption'];
    orderNo = json['orderNo'];
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['desciption'] = this.desciption;
    data['orderNo'] = this.orderNo;
    data['thumbnail'] = this.thumbnail;
    return data;
  }
}

class NotificationInDetail {
  String id;
  int orderNo;
  String title;
  String content;
  String color;
  String postId;
  String created;
  bool active;

  NotificationInDetail(
      {this.id,
        this.orderNo,
        this.title,
        this.content,
        this.color,
        this.postId,
        this.created, this.active});

  NotificationInDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderNo = json['orderNo'];
    title = json['title'];
    content = json['content'];
    color = json['color'];
    postId = json['postId'];
    created = json['created'];
    active = json['active'];
  }
}