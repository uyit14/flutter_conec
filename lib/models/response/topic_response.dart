import 'topic.dart';

class TopicResponse {
  List<Topic> topics;

  TopicResponse(this.topics);

  TopicResponse.fromJson(Map<String, dynamic> json) {
    if (json['topics'] != null) {
      topics = new List<Topic>();
      json['topics'].forEach((v) {
        topics.add(new Topic.fromJson(v));
      });
    }
  }

}