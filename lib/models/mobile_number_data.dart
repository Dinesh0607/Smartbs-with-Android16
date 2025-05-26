class MobileNumberData {
  List<String> mobileNumbers;
  int status;
  int notAnswerd;
  String callBackDate;
  int callBack;
  String location;
  String createdDate;
  String userId;

  MobileNumberData(
      {this.mobileNumbers,
      this.status,
      this.notAnswerd,
      this.callBackDate,
      this.location,
      this.callBack,
      this.createdDate,
      this.userId});

  MobileNumberData.fromJson(Map<String, dynamic> json) {
    mobileNumbers = json['mobileNumbers'].cast<String>();
    status = json['status'];
    notAnswerd = json['notAnswerd'];
    callBackDate = json['callBackDate'];
    location = json['location'];
    callBack = json['callBack'];
    createdDate = json['createdDate'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mobileNumbers'] = this.mobileNumbers;
    data['status'] = this.status;
    data['notAnswerd'] = this.notAnswerd;
    data['callBackDate'] = this.callBackDate;
    data['location'] = this.location;
    data['callBack'] = this.callBack;
    data['createdDate'] = this.createdDate;
    data['userId'] = this.userId;
    return data;
  }
}
