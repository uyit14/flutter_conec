class GroupRequest {
  String userGroupId;
  String name;
  String color;
  String notes;
  String times;
  int orderNo;
  bool active;

  GroupRequest(
      {this.userGroupId,
        this.name,
        this.color,
        this.notes,
        this.times,
        this.orderNo,
        this.active});

  Map<String, dynamic> toJson() => {
    if (userGroupId != null) 'userGroupId': userGroupId,
    if (name != null) 'name': name,
    if (times != null) 'times': times,
    if (notes != null) 'notes': notes,
    if (color != null) 'color': color,
    if (orderNo != null) 'orderNo': orderNo,
    if (active != null) 'active': active
  };
}
