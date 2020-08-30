import 'package:conecapp/common/helper.dart';
import 'package:conecapp/models/response/image.dart';

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
  String topicId;
  String topic;
  List<Image> images;
  String province;
  String district;
  String ward;
  String address;
  int joiningFee;
  String uses;
  String price;
  String generalCondition;
  String phoneNumber;
  String status;

  ItemDetail(
      {this.postId,
        this.description,
        this.content,
        this.approvedDate,
        this.owner,
        this.ownerAvatar,
        this.ratingCount,
        this.ratingAvg,
        this.isRating,
        this.viewCount,
        this.commentCount,
        this.likeCount,
        this.title,
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
        this.joiningFee,
        this.uses,
        this.price,
        this.generalCondition,
        this.phoneNumber,
        this.status
      });

  ItemDetail.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    title = json['title'];
    description = json['description'];
    content = json['content'];
    approvedDate = Helper.formatData(json['approvedDate']);
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
    joiningFee = json['joiningFee'];
    uses = json['uses'];
    price = json['price'];
    generalCondition = json['generalCondition'];
    phoneNumber = json['phoneNumber'];
    status = json['status'];
  }
}

//

