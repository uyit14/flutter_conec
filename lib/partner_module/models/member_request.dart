class MemberRequest {
  String memberId;
  String id;
  dynamic paymentDate;
  String joiningFeePeriod;
  String notes;
  dynamic joinedDate;
  int amount;
  Map avatarSource;
  String userName;
  String name;
  String email;
  String phoneNumber;
  String userGroupId;

  MemberRequest(
      {this.memberId,
      this.id,
      this.paymentDate,
      this.joiningFeePeriod,
      this.notes,
      this.joinedDate,
      this.amount,
      this.avatarSource,
      this.userName,
      this.name,
      this.email,
      this.phoneNumber,
      this.userGroupId});

  Map<String, dynamic> toJson() => {
        if (memberId != null) 'memberId': memberId,
        if (id != null) 'id': id,
        if (paymentDate != null) 'paymentDate': paymentDate,
        if (joinedDate != null) 'joinedDate': joinedDate,
        if (notes != null) 'notes': notes,
        if (joiningFeePeriod != null) 'joiningFeePeriod': joiningFeePeriod,
        if (amount != null) 'amount': amount,
        if (avatarSource != null) 'avatar': avatarSource,
        if (userName != null) 'userName': userName,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (userGroupId != null) 'userGroupId': userGroupId,
      };
}
