class BulkSMS {
  final int? timestamp;
  final List<dynamic>? phoneNumbers;
  final String? smsDescription;

  BulkSMS({this.timestamp, this.phoneNumbers, this.smsDescription});

  Map<String, dynamic> toMap() {
    return {
      "timestamp": timestamp,
      "phoneNumbers": phoneNumbers,
      "smsDescription": smsDescription,
    };
  }
}