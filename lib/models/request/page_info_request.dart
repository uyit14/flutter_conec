class PageInfoRequest{
  String about;
  List<Map> images;
  String videoLink;

  PageInfoRequest({this.about, this.images, this.videoLink});

  Map<String, dynamic> toJson() => {
    if(about!=null) 'about': about,
    if(videoLink!=null) 'videoLink': videoLink,
    if(images!=null) 'images': images,
  };
}