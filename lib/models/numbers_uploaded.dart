class NumbersUploaded {
  int numbersUploaded;

  NumbersUploaded({this.numbersUploaded});

  NumbersUploaded.fromJson(Map<String, dynamic> json) {
    numbersUploaded = json['numbersUploaded'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['numbersUploaded'] = this.numbersUploaded;
    return data;
  }
}
