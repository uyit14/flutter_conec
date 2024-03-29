import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/image.dart';
import 'package:conecapp/models/response/topic.dart';

class ItemDetailResponse {
  ItemDetail itemDetail;
  bool status;

  ItemDetailResponse({this.itemDetail, this.status});

  ItemDetailResponse.fromJson(Map<String, dynamic> json) {
    itemDetail = json['post'] != null ? new ItemDetail.fromJson(json['post']) : null;
    status = json['status'] != null ? json['status'] : null;
  }
}

class ItemDetail {
  String postId;
  String title;
  String description;
  String content;
  String approvedDate;
  String owner;
  bool isOwner;
  String ownerAvatar;
  String ownerId;
  num ratingCount;
  num ratingAvg;
  bool isRating;
  int viewCount;
  int commentCount;
  int likeCount;
  bool likeOwner;
  String thumbnail;
  String topicId;
  String topic;
  List<Image> images;
  String province;
  String district;
  String ward;
  String address;
  String getAddress;
  num lat;
  num long;
  int joiningFee;
  String joiningFeePeriod;
  String uses;
  String price;
  String generalCondition;
  String phoneNumber;
  String status;
  String shareLink;
  int userViewPostCount;
  List<Topic> topics;
  List<Topic> subTopics;
  List<Notification> notifications;

  ItemDetail(
      {this.postId,
        this.description,
        this.content,
        this.approvedDate,
        this.owner,
        this.isOwner,
        this.ownerAvatar,
        this.ownerId,
        this.ratingCount,
        this.ratingAvg,
        this.isRating,
        this.viewCount,
        this.commentCount,
        this.likeCount,
        this.title,
        this.likeOwner,
        this.thumbnail,
        this.topicId,
        this.topic,
        this.images,
        this.userViewPostCount,
        this.province,
        this.district,
        this.ward,
        this.address,
        this.getAddress,
        this.lat,
        this.long,
        this.joiningFee,
        this.joiningFeePeriod,
        this.uses,
        this.price,
        this.generalCondition,
        this.phoneNumber,
        this.status,
        this.shareLink,
        this.topics,
        this.subTopics,
        this.notifications
      });

  ItemDetail.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    title = json['title'];
    description = json['description'];
    content = json['content'];
    approvedDate = Helper.formatData(json['approvedDate']);
    owner = json['owner'];
    isOwner = json['isOwner'];
    ownerAvatar = json['ownerAvatar'] !=null && !json['ownerAvatar'].contains("http") ? Helper.baseURL + json['ownerAvatar'] : json['ownerAvatar'];
    ownerId = json['ownerId'] ?? null;
    ratingCount = json['ratingCount'];
    ratingAvg = json['ratingAvg'];
    isRating = json['isRating'];
    viewCount = json['viewCount'];
    shareLink = json['shareLink'];
    commentCount = json['commentCount'];
    likeCount = json['likeCount'];
    likeOwner = json['likeOwner'];
    userViewPostCount = json['userViewPostCount'];
    thumbnail = json['thumbnail'];
    topicId = json['topicId'];
    topic = json['topic'];
    if (json['images'] != null) {
      images = new List<Image>();
      json['images'].forEach((v) {
        images.add(new Image.fromJson(v));
      });
    }
    province = json['province'];
    district = json['district'];
    ward = json['ward'];
    address = json['address'];
    getAddress = json['getAddress'];
    lat = json['lat'];
    long = json['lng'];
    joiningFee = json['joiningFee'];
    joiningFeePeriod = json['joiningFeePeriod'];
    uses = json['uses'];
    price = json['price'].toString();
    generalCondition = json['generalCondition'];
    phoneNumber = json['phoneNumber'];
    status = json['status'];
    if (json['topics'] != null) {
      topics = new List<Topic>();
      json['topics'].forEach((v) {
        topics.add(new Topic.fromJson(v));
      });
    }
    if (json['subTopics'] != null) {
      subTopics = new List<Topic>();
      json['subTopics'].forEach((v) {
        subTopics.add(new Topic.fromJson(v));
      });
    }
    if (json['notifications'] != null) {
      notifications = new List<Notification>();
      json['notifications'].forEach((v) {
        notifications.add(new Notification.fromJson(v));
      });
    }
  }
}

class Notification {
  String id;
  int orderNo;
  String title;
  String content;
  String color;
  String postId;
  String created;
  bool active;

  Notification(
      {this.id,
        this.orderNo,
        this.title,
        this.content,
        this.color,
        this.postId,
        this.created,
        this.active});

  Notification.fromJson(Map<String, dynamic> json) {
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

