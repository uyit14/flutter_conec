import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/image.dart';

class NewsDetailResponse {
  NewsDetail news;

  NewsDetailResponse(this.news);

  NewsDetailResponse.fromJson(Map<String, dynamic> json) {
    news = json['news'] != null ? new NewsDetail.fromJson(json['news']) : null;
  }
}

class NewsDetail {
  String postId;
  String title;
  String description;
  String content;
  String publishedDate;
  String owner;
  String ownerAvatar;
  int ratingCount;
  int ratingAvg;
  bool isRating;
  int viewCount;
  int commentCount;
  int likeCount;
  bool likeOwner;
  bool isLikeOwner;
  String thumbnail;
  String topic;
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
  String phoneNumber;

  NewsDetail(
      {this.postId,
        this.title,
        this.description,
        this.content,
        this.publishedDate,
        this.owner,
        this.ownerAvatar,
        this.ratingCount,
        this.ratingAvg,
        this.isRating,
        this.viewCount,
        this.commentCount,
        this.likeCount,
        this.likeOwner,
        this.isLikeOwner,
        this.thumbnail,
        this.topic,
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
        this.phoneNumber});

  NewsDetail.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    title = json['title'];
    description = json['description'];
    content = json['content'];
    publishedDate = Helper.formatData(json['publishedDate']);
    owner = json['owner'];
    ownerAvatar = json['ownerAvatar'] !=null ? "http://149.28.140.240:8088" + json['ownerAvatar'] : null;
    ratingCount = json['ratingCount'];
    ratingAvg = json['ratingAvg'];
    isRating = json['isRating'];
    viewCount = json['viewCount'];
    commentCount = json['commentCount'];
    likeCount = json['likeCount'];
    likeOwner = json['likeOwner'];
    isLikeOwner = json['isLikeOwner'];
    thumbnail = json['thumbnail'] !=null ? "http://149.28.140.240:8088" + json['thumbnail'] : null;
    topic = json['topic'];
    topicMetaLink = json['topicMetaLink'];
    metaLink = json['metaLink'];
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
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postId'] = this.postId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['content'] = this.content;
    data['publishedDate'] = this.publishedDate;
    data['owner'] = this.owner;
    data['ownerAvatar'] = this.ownerAvatar;
    data['ratingCount'] = this.ratingCount;
    data['ratingAvg'] = this.ratingAvg;
    data['isRating'] = this.isRating;
    data['viewCount'] = this.viewCount;
    data['commentCount'] = this.commentCount;
    data['likeCount'] = this.likeCount;
    data['likeOwner'] = this.likeOwner;
    data['isLikeOwner'] = this.isLikeOwner;
    data['thumbnail'] = this.thumbnail;
    data['topic'] = this.topic;
    data['topicMetaLink'] = this.topicMetaLink;
    data['metaLink'] = this.metaLink;
    data['metaTitle'] = this.metaTitle;
    data['metaDescription'] = this.metaDescription;
    data['metaKeywords'] = this.metaKeywords;
    if (this.images != null) {
      data['images'] = this.images.map((v) => v.toJson()).toList();
    }
    data['province'] = this.province;
    data['district'] = this.district;
    data['ward'] = this.ward;
    data['address'] = this.address;
    data['phoneNumber'] = this.phoneNumber;
    return data;
  }
}
