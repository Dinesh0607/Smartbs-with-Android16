import 'package:smartbs/utils/firebase_utility.dart';

class CustomerModel {
  String serialNumber;
  String customerName;
  String phoneNumber;
  String location;
  String email;
  String grossSalary;
  String netSalary;
  String applicationStatus;
  String approvedAmount;
  String appliedAmount;
  String caller;
  String comments;
  String bank;
  String service;
  DateTime appointmentDate;
  String createdDate;
  String callBackDate;
  DateTime dob;
  String uid;

  CustomerModel(
      {this.serialNumber,
      this.customerName,
      this.phoneNumber,
      this.location,
      this.email,
      this.grossSalary,
      this.netSalary,
      this.applicationStatus,
      this.approvedAmount,
      this.appliedAmount,
      this.caller,
      this.service,
      this.appointmentDate,
      this.dob,
      this.comments,
      this.createdDate,
      this.bank,
      this.callBackDate,
      this.uid});

  CustomerModel.fromJson(Map<String, dynamic> json) {
    serialNumber = json['serialNumber'];
    customerName = json['customerName'];
    phoneNumber = json['phoneNumber'];
    location = json['location'];
    createdDate = json['createdDate'];
    callBackDate = json['callBackDate'];
    email = json['email'];
    grossSalary = json['grossSalary'];
    comments = json['comments'];
    netSalary = json['netSalary'];
    applicationStatus = json['applicationStatus'];
    approvedAmount = json['approvedAmount'];
    appliedAmount = json['appliedAmount'];
    caller = json['caller'];
    appointmentDate = json['appointmentDate'] == null
        ? null
        : DateTime.parse(json['appointmentDate'] as String);
    dob = json['dob'] == null ? null : DateTime.parse(json['dob'] as String);
    bank = json['bank'];
    service = json['service'];
    uid = json['uid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['serialNumber'] = this.serialNumber;
    data['customerName'] = this.customerName;
    data['phoneNumber'] = this.phoneNumber;
    data['location'] = this.location;
    data['grossSalary'] = this.grossSalary;
    data['email'] = this.email;
    data['netSalary'] = this.netSalary;
    data['applicationStatus'] = this.applicationStatus;
    data['approvedAmount'] = this.approvedAmount;
    data['appliedAmount'] = this.appliedAmount;
    data['caller'] = this.caller;
    data['appointmentDate'] = this.appointmentDate;
    data['bank'] = this.bank;
    data['service'] = this.service;
    data['dob'] = this.dob;
    data['createdDate'] = this.createdDate;
    data['uid'] = this.uid;
    data['comments'] = this.comments;
    data['callBackDate'] = this.callBackDate;
    return data;
  }
}
