class NumbersAvailable {
  int numbersAvailable;
  int notAnsweredNumbers;

  NumbersAvailable({this.numbersAvailable, this.notAnsweredNumbers});

  NumbersAvailable.fromJson(Map<String, dynamic> json) {
    numbersAvailable = json['numbersAvailable'];
    notAnsweredNumbers = json['notAnsweredNumbers'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['numbersAvailable'] = this.numbersAvailable;
    data['notAnsweredNumbers'] = this.notAnsweredNumbers;
    return data;
  }
}
