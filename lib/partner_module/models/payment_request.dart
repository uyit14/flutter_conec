class CompletePaymentRequest {
  String id;
  dynamic paymentDate;
  String notes;
  int paymentAmount;

  CompletePaymentRequest({this.id, this.paymentDate, this.notes, this.paymentAmount});

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (paymentDate != null) 'paymentDate': paymentDate,
    if (notes != null) 'notes': notes,
    if (paymentAmount != null) 'paymentAmount': paymentAmount,
  };
}

class UpdatePaymentRequest {
  String id;
  dynamic paymentDate;
  String notes;
  int paymentAmount;

  UpdatePaymentRequest({this.id, this.paymentDate, this.notes, this.paymentAmount});

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (paymentDate != null) 'created': paymentDate,
    if (notes != null) 'notes': notes,
    if (paymentAmount != null) 'amount': paymentAmount,
  };
}
