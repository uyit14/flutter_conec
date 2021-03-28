class OneSignalResponse {
  Payload payload;
  int displayType;
  bool shown;
  bool appInFocus;
  Null silent;

  OneSignalResponse(
      {this.payload,
        this.displayType,
        this.shown,
        this.appInFocus,
        this.silent});

  OneSignalResponse.fromJson(Map<String, dynamic> json) {
    payload =
    json['payload'] != null ? new Payload.fromJson(json['payload']) : null;
    displayType = json['displayType'];
    shown = json['shown'];
    appInFocus = json['appInFocus'];
    silent = json['silent'];
  }

}

class Payload {
  String googleDeliveredPriority;
  int googleSentTime;
  int googleTtl;
  String googleOriginalPriority;
  Custom custom;
  String pri;
  String from;
  String alert;
  String title;
  String googleMessageId;
  String googleCSenderId;
  int androidNotificationId;

  Payload(
      {this.googleDeliveredPriority,
        this.googleSentTime,
        this.googleTtl,
        this.googleOriginalPriority,
        this.custom,
        this.pri,
        this.from,
        this.alert,
        this.title,
        this.googleMessageId,
        this.googleCSenderId,
        this.androidNotificationId});

  Payload.fromJson(Map<String, dynamic> json) {
    googleDeliveredPriority = json['google.delivered_priority'];
    googleSentTime = json['google.sent_time'];
    googleTtl = json['google.ttl'];
    googleOriginalPriority = json['google.original_priority'];
    custom =
    json['custom'] != null ? new Custom.fromJson(json['custom']) : null;
    pri = json['pri'];
    from = json['from'];
    alert = json['alert'];
    title = json['title'];
    googleMessageId = json['google.message_id'];
    googleCSenderId = json['google.c.sender.id'];
    androidNotificationId = json['androidNotificationId'];
  }
}

class Custom {
  Data data;
  String u;
  String i;

  Custom({this.data, this.u, this.i});

  Custom.fromJson(Map<String, dynamic> json) {
    data = json['a'] != null ? new Data.fromJson(json['a']) : null;
    u = json['u'];
    i = json['i'];
  }
}

class Data {
  String postId;

  Data({this.postId});

  Data.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
  }
}