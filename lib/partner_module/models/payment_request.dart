class PaymentRequest {
  String id;
  dynamic paymentDate;
  String notes;
  int paymentAmount;

  PaymentRequest({this.id, this.paymentDate, this.notes, this.paymentAmount});

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (paymentDate != null) 'paymentDate': paymentDate,
        if (notes != null) 'notes': notes,
        if (paymentAmount != null) 'paymentAmount': paymentAmount,
      };
}
