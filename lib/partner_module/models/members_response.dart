import 'package:conecapp/common/helper.dart';

class MembersResponse {
  List<Member> members;

  MembersResponse({this.members});

  MembersResponse.fromJson(Map<String, dynamic> json) {
    if (json['members'] != null) {
      members = new List<Member>();
      json['members'].forEach((v) {
        members.add(new Member.fromJson(v));
      });
    }
  }
}

class MemberDetailResponse {
  bool status;
  Member member;

  MemberDetailResponse({this.status, this.member});

  MemberDetailResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    member =
    json['member'] != null ? new Member.fromJson(json['member']) : null;
  }
}

class Member {
  String id;
  String memberId;
  String userName;
  String name;
  String phoneNumber;
  String avatar;
  String email;
  String paymentDate;
  String joinedDate;
  String joiningFeePeriod;
  int amount;
  String modifiedDate;
  String notes;
  String groupName;
  List<Payment> payments;

  Member(
      {this.id,
      this.memberId,
      this.userName,
      this.name,
      this.phoneNumber,
      this.avatar,
      this.email,
      this.paymentDate,
      this.joinedDate,
      this.joiningFeePeriod,
      this.amount,
      this.modifiedDate,
      this.notes,
        this.groupName,
      this.payments});

  Member.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    memberId = json['memberId'];
    userName = json['userName'];
    name = json['name'];
    phoneNumber = json['phoneNumber'];
    email = json['email'];
    paymentDate = json['paymentDate'] == null ? null : Helper.formatDob(json['paymentDate']);
    joiningFeePeriod = json['joiningFeePeriod'];
    joinedDate = json['joinedDate'] == null ? null : Helper.formatDob(json['joinedDate']);
    amount = json['amount'];
    modifiedDate = json['modifiedDate'] == null ? null : Helper.formatDob(json['modifiedDate']);
    notes = json['notes'];
    groupName = json['group'];
    if (json['payments'] != null) {
      payments = new List<Payment>();
      json['payments'].forEach((v) {
        payments.add(new Payment.fromJson(v));
      });
    }
    avatar =
    json['avatar'] != null && !json['avatar'].contains("http")
        ? Helper.baseURL + json['avatar']
        : json['avatar'];
  }
}

class Payment {
  String id;
  String userMemberId;
  int amount;
  int paymentAmount;
  String paymentDate;
  String paymentBy;
  String created;
  String createdBy;
  String joiningFeePeriod;
  String notes;

  Payment(
      {this.id,
        this.userMemberId,
        this.amount,
        this.paymentAmount,
        this.paymentDate,
        this.paymentBy,
        this.created,
        this.createdBy,
        this.joiningFeePeriod,
        this.notes});

  Payment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userMemberId = json['userMemberId'];
    amount = json['amount'];
    paymentAmount = json['paymentAmount'];
    paymentDate = json['paymentDate'] == null ? null : Helper.formatDob(json['paymentDate']);
    paymentBy = json['paymentBy'];
    created = json['created'] == null ? null : Helper.formatDob(json['created']);
    createdBy = json['createdBy'];
    joiningFeePeriod = json['joiningFeePeriod'];
    notes = json['notes'];
  }
}