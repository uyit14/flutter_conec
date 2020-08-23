class PostActionRequest {
  String postId;
  String title;
  String content;
  dynamic thumbnail;
  String topicId;
  List<Map> images;
  String province;
  String district;
  String ward;
  String address;
  int joiningFee;
  String phoneNumber;
  String status;

  PostActionRequest.create(
      {this.title,
      this.content,
      this.thumbnail,
      this.topicId,
      this.images,
      this.province,
      this.district,
      this.ward,
      this.address,
      this.joiningFee,
      this.phoneNumber,
      this.status});

  PostActionRequest.update(
      {this.postId, this.title,
        this.content,
        this.thumbnail,
        this.topicId,
        this.images,
        this.province,
        this.district,
        this.ward,
        this.address,
        this.joiningFee,
        this.phoneNumber,
        this.status});

  Map<String, dynamic> toUpdateJson() => {
    'postId':postId,
    'title': title,
    'content': content,
    'thumbnail': thumbnail,
    'topicId': topicId,
    'province': province,
    'images': images,
    'status': status,
    'district': district,
    'ward': ward,
    'address': address,
    'joiningFee': joiningFee,
    'phoneNumber': phoneNumber,
  };

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'thumbnail': thumbnail,
        'topicId': topicId,
        'province': province,
        'images': images,
        'status': status,
        'district': district,
        'ward': ward,
        'address': address,
        'joiningFee': joiningFee,
        'phoneNumber': phoneNumber,
      };
}
