class UserInfoTable {
  String userName;
  int timeWorked;
  int numbersDailed;
  int leads;
  int numbersAvailable;
  int notAnsNumbersAvailable;
  int callBacks;
  int notAns;
  int numbersPulled;
  int notIns;
  String location;

  UserInfoTable(
      {this.userName,
      this.timeWorked,
      this.numbersDailed,
      this.leads,
      this.numbersAvailable,
      this.notAnsNumbersAvailable,
      this.callBacks,
      this.notAns,
      this.numbersPulled,
      this.location,
      this.notIns});

  UserInfoTable.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    timeWorked = json['timeWorked'];
    numbersDailed = json['numbersDailed'];
    leads = json['leads'];
    numbersAvailable = json['numbersAvailable'];
    callBacks = json['callBacks'];
    notAns = json['notAns'];
    numbersPulled = json['numbersPulled'];
    location = json['location'];
    notIns = json['notIns'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userName'] = this.userName;
    data['timeWorked'] = this.timeWorked;
    data['numbersDailed'] = this.numbersDailed;
    data['leads'] = this.leads;
    data['numbersAvailable'] = this.numbersAvailable;
    data['callBacks'] = this.callBacks;
    data['notAns'] = this.notAns;
    data['numbersPulled'] = this.numbersPulled;
    data['location'] = this.location;
    data['notIns'] = this.notIns;
    return data;
  }
}
