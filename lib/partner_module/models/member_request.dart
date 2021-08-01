class MemberRequest {
  String memberId;
  dynamic paymentDate;
  String joiningFeePeriod;
  String notes;
  dynamic joinedDate;
  int amount;

  MemberRequest(
      {this.memberId,
        this.paymentDate,
        this.joiningFeePeriod,
        this.notes,
        this.joinedDate,
        this.amount});

  Map<String, dynamic> toJson() => {
    if (memberId != null) 'memberId': memberId,
    if (paymentDate != null) 'paymentDate': paymentDate,
    if (joinedDate != null) 'joinedDate': joinedDate,
    if (notes != null) 'notes': notes,
    if (joiningFeePeriod != null) 'joiningFeePeriod': joiningFeePeriod,
    if (amount != null) 'amount': amount,
  };
}
