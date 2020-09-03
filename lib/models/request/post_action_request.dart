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
  int price;
  String generalCondition;
  String uses;
  String phoneNumber;
  double lat;
  double lng;
  String status;


  PostActionRequest(
  {
    this.postId,
    this.title,
    this.content,
    this.thumbnail,
    this.topicId,
    this.images,
    this.province,
    this.district,
    this.ward,
    this.address,
    this.joiningFee,
    this.price,
    this.generalCondition,
    this.uses,
    this.phoneNumber,
    this.lat,
    this.lng,
    this.status
});

  Map<String, dynamic> toJson() => {
    if(postId!=null) 'postId':postId,
    if(title!=null) 'title': title,
    if(content!=null) 'content': content,
    if(thumbnail!=null) 'thumbnail': thumbnail,
    if(topicId!=null) 'topicId': topicId,
    if(province!=null) 'province': province,
    if(images!=null) 'images': images,
    if(district!=null) 'district': district,
    if(ward!=null) 'ward': ward,
    if(address!=null) 'address': address,
    if(price!=null) 'price': price,
    if(uses!=null) 'uses': uses,
    if(joiningFee!=null) 'joiningFee': joiningFee,
    if(generalCondition!=null) 'generalCondition': generalCondition,
    if(phoneNumber!=null) 'phoneNumber': phoneNumber,
    if(lat!=null) 'lat': lat,
    if(lng!=null) 'lng': lng,
    if(status!=null) 'status': status,
  };
}
