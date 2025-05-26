class TimeCard {
  String uid;
  List<TimeLogging> timeLogging;

  TimeCard({this.uid, this.timeLogging});

  TimeCard.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    if (json['timeLogging'] != null) {
      timeLogging = new List<TimeLogging>();
      json['timeLogging'].forEach((v) {
        timeLogging.add(new TimeLogging.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    if (this.timeLogging != null) {
      data['timeLogging'] = this.timeLogging.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TimeLogging {
  String date;
  int time;
  int callsaccepted;
  int callsNotAns;
  int callsCallBack;
  int numbersPulled;
  int callsNotIntreseted;

  TimeLogging(
      {this.date,
      this.time,
      this.callsaccepted,
      this.callsNotAns,
      this.callsCallBack,
      this.numbersPulled,
      this.callsNotIntreseted});

  TimeLogging.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    time = json['time'];
    callsaccepted = json['callsaccepted'];
    callsNotAns = json['callsNotAns'];
    callsCallBack = json['callsCallBack'];
    numbersPulled = json['numbersPulled'];
    callsNotIntreseted = json['callsNotIntreseted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['time'] = this.time;
    data['callsaccepted'] = this.callsaccepted;
    data['callsNotAns'] = this.callsNotAns;
    data['callsCallBack'] = this.callsCallBack;
    data['numbersPulled'] = this.numbersPulled;
    data['callsNotIntreseted'] = this.callsNotIntreseted;
    return data;
  }
}
