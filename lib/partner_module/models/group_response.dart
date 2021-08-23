class GroupResponse {
  bool status;
  List<Group> groups;

  GroupResponse({this.status, this.groups});

  GroupResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['groups'] != null) {
      groups = new List<Group>();
      json['groups'].forEach((v) {
        groups.add(new Group.fromJson(v));
      });
    }
  }
}

class Group {
  String userGroupId;
  String name;
  String color;
  int orderNo;
  bool active;
  String times;
  String notes;

  Group(
      {this.userGroupId,
        this.name,
        this.color,
        this.orderNo,
        this.active,
        this.times,
        this.notes});

  Group.fromJson(Map<String, dynamic> json) {
    userGroupId = json['userGroupId'];
    name = json['name'];
    color = json['color'];
    orderNo = json['orderNo'];
    active = json['active'];
    times = json['times'];
    notes = json['notes'];
  }
}