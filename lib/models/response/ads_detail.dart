import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/image.dart';

class AdsDetailsResponse {
  AdsDetail adsDetail;

  AdsDetailsResponse({this.adsDetail});

  AdsDetailsResponse.fromJson(Map<String, dynamic> json) {
    adsDetail =
        json['ads'] != null ? new AdsDetail.fromJson(json['ads']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.adsDetail != null) {
      data['ads'] = this.adsDetail.toJson();
    }
    return data;
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
  String getAddress;
  double lat;
  double long;
  int joiningFee;
  String uses;
  int price;
  String generalCondition;
  String phoneNumber;

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
        this.getAddress,
        this.lat,
        this.long,
      this.joiningFee,
      this.uses,
      this.price,
      this.generalCondition,
      this.phoneNumber});

  AdsDetail.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    title = json['title'];
    description = json['description'];
    content = json['content'];
    approvedDate = Helper.formatData(json['approvedDate']);
    owner = json['owner'];
    ownerAvatar = json['ownerAvatar'] !=null ? "http://149.28.140.240:8088" + json['ownerAvatar'] : null;
    ownerId = json['ownerId'] ?? null;
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
    getAddress = json['getAddress'];
    lat = double.parse(json['lat']);
    long = double.parse(json['lng']);
    joiningFee = json['joiningFee'];
    uses = json['uses'];
    price = json['price'];
    generalCondition = json['generalCondition'];
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postId'] = this.postId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['content'] = this.content;
    data['approvedDate'] = this.approvedDate;
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
    data['joiningFee'] = this.joiningFee;
    data['uses'] = this.uses;
    data['price'] = this.price;
    data['generalCondition'] = this.generalCondition;
    data['phoneNumber'] = this.phoneNumber;
    return data;
  }
}
