class UserModel {
  String displayName;
  String email;
  bool emailVerified;
  String phoneNumber;
  String photoURL;
  String uid;
  String memberSince;
  String location;
  bool verified;
  int isBlocked;
  String userRole;

  UserModel(
      {this.displayName,
      this.email,
      this.emailVerified,
      this.phoneNumber,
      this.photoURL,
      this.uid,
      this.memberSince,
      this.location,
      this.verified,
      this.isBlocked,
      this.userRole});

  UserModel.fromJson(Map<String, dynamic> json) {
    displayName = json['displayName'];
    email = json['email'];
    emailVerified = json['emailVerified'];
    phoneNumber = json['phoneNumber'];
    photoURL = json['photoURL'];
    uid = json['uid'];
    location = json['location'];
    memberSince = json['memberSince'];
    verified = json['verified'];
    isBlocked = json['isBlocked'];
    userRole = json['userRole'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['displayName'] = this.displayName;
    data['email'] = this.email;
    data['emailVerified'] = this.emailVerified;
    data['phoneNumber'] = this.phoneNumber;
    data['photoURL'] = this.photoURL;
    data['uid'] = this.uid;
    data['memberSince'] = this.memberSince;
    data['verified'] = this.verified;
    data['location'] = this.location;
    data['isBlocked'] = this.isBlocked;
    data['userRole'] = this.userRole;
    return data;
  }
}

class UsersVerified {
  List<UsersList> usersList;

  UsersVerified({this.usersList});

  UsersVerified.fromJson(Map<String, dynamic> json) {
    if (json['usersList'] != null) {
      usersList = new List<UsersList>();
      json['usersList'].forEach((v) {
        usersList.add(new UsersList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.usersList != null) {
      data['usersList'] = this.usersList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UsersList {
  bool userVerified;
  String displayName;
  String location;
  String uid;
  String userRole;

  UsersList({this.userVerified, this.displayName, this.uid, this.userRole});

  UsersList.fromJson(Map<String, dynamic> json) {
    userVerified = json['userVerified'];
    displayName = json['displayName'];
    uid = json['uid'];
    location = json['location'];
    userRole = json['userRole'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userVerified'] = this.userVerified;
    data['displayName'] = this.displayName;
    data['uid'] = this.uid;
    data['location'] = this.location;
    data['userRole'] = this.userRole;
    return data;
  }
}
