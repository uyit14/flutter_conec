import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/image.dart';
import 'package:conecapp/models/response/topic.dart';

class AdsDetailsResponse {
  AdsDetail adsDetail;

  AdsDetailsResponse({this.adsDetail});

  AdsDetailsResponse.fromJson(Map<String, dynamic> json) {
    adsDetail =
        json['ads'] != null ? new AdsDetail.fromJson(json['ads']) : null;
  }
}

class AdsDetail {
  String postId;
  String title;
  String description;
  String content;
  String approvedDate;
  String owner;
  String ownerAvatar;
  String ownerId;
  num ratingCount;
  int ratingAvg;
  bool isRating;
  int viewCount;
  int commentCount;
  int likeCount;
  bool likeOwner;
  String thumbnail;
  String topic;
  String topicId;
  String topicMetaLink;
  String metaLink;
  String metaTitle;
  String metaDescription;
  String metaKeywords;
  List<Image> images;
  String province;
  String district;
  String ward;
  String address;
  String getAddress;
  num lat;
  num long;
  int joiningFee;
  String uses;
  int price;
  String generalCondition;
  String phoneNumber;
  String status;
  String shareLink;
  List<Topic> topics;
  List<Topic> subTopics;

  AdsDetail(
      {this.postId,
      this.title,
      this.description,
      this.content,
      this.approvedDate,
      this.owner,
      this.ownerAvatar,
      this.ownerId,
      this.ratingCount,
      this.ratingAvg,
      this.isRating,
      this.viewCount,
      this.commentCount,
      this.likeCount,
      this.likeOwner,
      this.thumbnail,
      this.topic,
      this.topicId,
      this.topicMetaLink,
      this.metaLink,
      this.metaTitle,
      this.metaDescription,
      this.metaKeywords,
      this.images,
      this.province,
      this.district,
      this.ward,
      this.address,
      this.getAddress,
      this.lat,
      this.long,
      this.joiningFee,
      this.uses,
      this.price,
      this.generalCondition,
        this.status,
      this.shareLink,
      this.topics,
      this.subTopics,
      this.phoneNumber});

  AdsDetail.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    title = json['title'];
    description = json['description'];
    content = json['content'];
    approvedDate = Helper.formatData(json['approvedDate']);
    owner = json['owner'];
    ownerAvatar =
        json['ownerAvatar'] != null && !json['ownerAvatar'].contains("http")
            ? Helper.baseURL + json['ownerAvatar']
            : json['ownerAvatar'];
    ownerId = json['ownerId'] ?? null;
    ratingCount = json['ratingCount'];
    ratingAvg = json['ratingAvg'];
    isRating = json['isRating'];
    viewCount = json['viewCount'];
    commentCount = json['commentCount'];
    likeCount = json['likeCount'];
    likeOwner = json['likeOwner'];
    thumbnail = json['thumbnail'] != null && !json['thumbnail'].contains("http")
        ? Helper.baseURL + json['thumbnail']
        : json['thumbnail'];
    topic = json['topic'];
    topicId = json['topicId'];
    topicMetaLink = json['topicMetaLink'];
    metaLink = json['metaLink'];
    status = json['status'];
    metaTitle = json['metaTitle'];
    metaDescription = json['metaDescription'];
    metaKeywords = json['metaKeywords'];
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
    uses = json['uses'];
    price = json['price'];
    generalCondition = json['generalCondition'];
    phoneNumber = json['phoneNumber'];
    shareLink = json['shareLink'];
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
  }
}
