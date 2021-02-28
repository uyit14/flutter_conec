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

class SubTopicResponse {
  List<Topic> topics;

  SubTopicResponse(this.topics);

  SubTopicResponse.fromJson(Map<String, dynamic> json) {
    if (json['subTopics'] != null) {
      topics = new List<Topic>();
      json['subTopics'].forEach((v) {
        topics.add(new Topic.fromJson(v));
      });
    }
  }

}