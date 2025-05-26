import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbs/models/numbers_uploaded.dart';
import 'package:smartbs/models/customer_model.dart';
import 'package:smartbs/models/mobile_number_data.dart';
import 'package:smartbs/models/numbers_available.dart';
import 'package:smartbs/models/time_card.dart';
import 'package:smartbs/models/user_model.dart';

class FirebaseUtility {
  SharedPreferences sharedPreferences;

  static String USERS_COLLECTION = "users";

  static String USERS_VERIFIED_COLLECTION = "userverified";

  static String NUMBER_DATA = "numberdata";

  static String CUSTOMER_COLLECTION = "customerdata";

  static String USER_TIME_LOGGING_COLLECTION = "usertimelogging";

  static String NUMBERS_AVAILABLE_LOG = "numbersavailablelog";

  static String NUMBERS_UPLOADED = "numbersuploaded";

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection(USERS_COLLECTION);

  final CollectionReference numbersAvailableLog =
      FirebaseFirestore.instance.collection(NUMBERS_AVAILABLE_LOG);

  final CollectionReference userTimeLogging =
      FirebaseFirestore.instance.collection(USER_TIME_LOGGING_COLLECTION);

  final CollectionReference userVerifiedCollection =
      FirebaseFirestore.instance.collection(USERS_VERIFIED_COLLECTION);

  final CollectionReference numberDataCollection =
      FirebaseFirestore.instance.collection(NUMBER_DATA);

  final CollectionReference customerData =
      FirebaseFirestore.instance.collection(CUSTOMER_COLLECTION);

  final CollectionReference numbersUploadedData =
      FirebaseFirestore.instance.collection(NUMBERS_UPLOADED);

  Stream<DocumentSnapshot> getUser(String document) {
    return userCollection.doc(document).snapshots();
  }

  Future<UserModel> getsingleUser(String document) async {
    DocumentSnapshot snapshot = await userCollection.doc(document).get();
    return UserModel.fromJson(snapshot.data());
  }

  Future<void> setUserVerifed(
      String document, bool verified, String displayName) async {
    if (displayName == null)
      return userVerifiedCollection
          .doc(document)
          .update(json.decode('{"userVerified":$verified}'));
    UsersVerified userVerifiedList = new UsersVerified();
    List<UsersList> usersList = [];
    bool foundMatch = false;
    usersList = await getUsersVerifiedList();
    UsersList user = new UsersList(
        displayName: displayName, uid: document, userVerified: verified);
    print(usersList.contains(user).toString() + usersList.length.toString());
    for (UsersList u in usersList) {
      if (u.uid == user.uid) {
        print("Found");
        foundMatch = true;
        return;
      }
    }
    if (foundMatch) return;
    usersList.add(user);
    userVerifiedList.usersList = usersList;
    return userVerifiedCollection
        .doc("usersList")
        .set(userVerifiedList.toJson(), SetOptions(merge: true));
  }

  Future<void> timeLogging(
      String userId,
      int time,
      int callsaccepted,
      int callsCallBack,
      int callsNotAns,
      int numbersPulled,
      int callsNotIntreseted) async {
    DocumentSnapshot snapshot = await userTimeLogging.doc(userId).get();
    TimeCard timeCard = new TimeCard();
    if (snapshot.data() != null) {
      timeCard = TimeCard.fromJson(snapshot.data());
      userTimeLogging.doc(userId).set(
          getUserTimeCard(userId, time, callsaccepted, timeCard, callsCallBack,
                  callsNotAns, numbersPulled, callsNotIntreseted)
              .toJson(),
          SetOptions(merge: true));
    } else {
      userTimeLogging.doc(userId).set(
          getUserTimeCard(userId, time, callsaccepted, timeCard, callsCallBack,
                  callsNotAns, numbersPulled, callsNotIntreseted)
              .toJson(),
          SetOptions(merge: true));
    }
    //timeCard.timeLogging.singleWhere((element) => false)
  }

  Future<bool> getUserVerifed(String document) async {
    DocumentSnapshot snapshot =
        await userVerifiedCollection.doc(document).get();
    bool verified = (snapshot.data() as Map)['userVerified'];
    return verified;
  }

  Future<List<UsersList>> getUsersVerifiedList() async {
    UsersVerified userVerifiedList = new UsersVerified();
    DocumentSnapshot snapshot =
        await userVerifiedCollection.doc("usersList").get();
    userVerifiedList = UsersVerified.fromJson(snapshot.data());
    return userVerifiedList.usersList != null ? userVerifiedList.usersList : [];
  }

  Future<void> updateUserLocation(UsersList usersList) async {
    UsersVerified userVerifiedList = new UsersVerified();
    DocumentSnapshot snapshot =
        await userVerifiedCollection.doc("usersList").get();
    userVerifiedList = UsersVerified.fromJson(snapshot.data());
    userVerifiedList.usersList
        .removeWhere((element) => element.uid == usersList.uid);
    userVerifiedList.usersList.add(usersList);
    userVerifiedCollection
        .doc("usersList")
        .set(userVerifiedList.toJson(), SetOptions(merge: true));
    if (usersList.location != null)
      userCollection
          .doc(usersList.uid)
          .update({"location": usersList.location});
  }

  Future<void> updateUserAccess(UsersList usersList) async {
    UsersVerified userVerifiedList = new UsersVerified();
    DocumentSnapshot snapshot =
        await userVerifiedCollection.doc("usersList").get();
    userVerifiedList = UsersVerified.fromJson(snapshot.data());
    userVerifiedList.usersList
        .removeWhere((element) => element.uid == usersList.uid);
    userVerifiedList.usersList.add(usersList);
    userVerifiedCollection
        .doc("usersList")
        .set(userVerifiedList.toJson(), SetOptions(merge: true));
    if (usersList.userVerified)
      userCollection.doc(usersList.uid).update({"isBlocked": 0});
    else if (!usersList.userVerified)
      userCollection.doc(usersList.uid).update({"isBlocked": 1});
  }

  Future<void> deleteUser(UsersList usersList) async {
    UsersVerified userVerifiedList = new UsersVerified();
    DocumentSnapshot snapshot =
        await userVerifiedCollection.doc("usersList").get();
    userVerifiedList = UsersVerified.fromJson(snapshot.data());
    userVerifiedList.usersList
        .removeWhere((element) => element.uid == usersList.uid);
    userVerifiedCollection
        .doc("usersList")
        .set(userVerifiedList.toJson(), SetOptions(merge: true));
    userCollection.doc(usersList.uid).delete();
  }

  Future<List<TimeCard>> getUsersLoggingList() async {
    List<TimeCard> timeCardList = [];
    QuerySnapshot snapshot = await userTimeLogging.get();
    snapshot.docs.forEach((element) {
      timeCardList.add(new TimeCard.fromJson(element.data()));
    });
    return timeCardList;
  }

  Future<TimeCard> getUserLogging(String uid) async {
    DocumentSnapshot snapshot = await userTimeLogging.doc(uid).get();
    TimeCard timeCard = new TimeCard.fromJson(snapshot.data());
    return timeCard;
  }

  //get customer data
  Future<List<CustomerModel>> getCustomerList(String date, String uid) async {
    List<CustomerModel> customerList = [];
    QuerySnapshot snapshot;
    if (uid == null)
      snapshot = await customerData.where("createdDate", isEqualTo: date).get();
    else if (date == null)
      snapshot = await customerData.where("uid", isEqualTo: uid).get();
    snapshot.docs.forEach((element) {
      customerList.add(new CustomerModel.fromJson(element.data()));
    });
    return customerList;
  }

  //get customer data by uid
  Future<List<CustomerModel>> getCustomerListByUser(
      String uid, String date) async {
    List<CustomerModel> customerList = [];
    QuerySnapshot snapshot;
    if (date == null)
      snapshot = await customerData.where("uid", isEqualTo: uid).get();
    else
      snapshot = await customerData
          .where("uid", isEqualTo: uid)
          .where("callBackDate", isEqualTo: date)
          .get();
    snapshot.docs.forEach((element) {
      customerList.add(new CustomerModel.fromJson(element.data()));
    });
    return customerList;
  }

  Future<void> setUserData(String document, Map<String, dynamic> data) async {
    var doc = await userCollection.doc(document).get();
    if (!doc.exists)
      return userCollection.doc(document).set(data, SetOptions(merge: true));
    else
      return null;
  }

  Future<void> setUserRole(List<UsersList> users) async {
    UsersVerified userVerifiedList = new UsersVerified();
    userVerifiedList.usersList = users;
    userVerifiedCollection
        .doc("usersList")
        .set(userVerifiedList.toJson(), SetOptions(merge: true));
    for (var user in users) {}
  }

  Future<void> updateNumberData(
      List<String> numberData, String location) async {
    NumbersUploaded numbersUploaded = new NumbersUploaded(numbersUploaded: 0);
    var doc = await numbersUploadedData.doc(getDate()).get();
    if (doc.exists) {
      numbersUploaded = NumbersUploaded.fromJson(doc.data());
      numbersUploadedData.doc(getDate()).update({
        "numbersUploaded": numberData.length + numbersUploaded.numbersUploaded
      });
    } else {
      numbersUploaded = new NumbersUploaded(numbersUploaded: numberData.length);
      numbersUploadedData
          .doc(getDate())
          .set(numbersUploaded.toJson(), SetOptions(merge: true));
    }
    MobileNumberData mobileNumberData = new MobileNumberData();
    mobileNumberData.mobileNumbers = numberData;
    mobileNumberData.status = 0;
    mobileNumberData.location = location;
    mobileNumberData.createdDate = getDate();
    numberDataCollection.add(mobileNumberData.toJson());
  }

  Future<void> removeNumberDataByDate(String date) async {
    var snapshot = await numberDataCollection
        .where("createdDate", isEqualTo: date)
        .where("status", isEqualTo: 0)
        .get();
    snapshot.docs.forEach((element) {
      print(element.id);
      numberDataCollection.doc(element.id).delete();
    });
  }

  Future<void> removeNumberDataByLocation(String location) async {
    var snapshot = await numberDataCollection
        .where("location", isEqualTo: location)
        .where("status", isEqualTo: 0)
        .get();
    snapshot.docs.forEach((element) {
      print(element.id);
      numberDataCollection.doc(element.id).delete();
    });
  }

  Future<List<String>> getNotAnsData() async {
    List<String> notAns = [];
    var snapshot = await numberDataCollection
        .where("notAnswerd", isEqualTo: 0)
        .where("status", isEqualTo: 1)
        .get();
    snapshot.docs.forEach((element) {
      notAns.addAll(MobileNumberData.fromJson(element.data()).mobileNumbers);
      numberDataCollection.doc(element.id).delete();
    });
    return notAns;
  }

  Future<void> makeNotAnsDataActive() async {
    var snapshot =
        await numberDataCollection.where("status", isEqualTo: 0).get();
    snapshot.docs.forEach((element) {
      print(element.id);
      element.reference.update({"status": 0});
    });
  }

  Future<void> updateCallBackNumbers(String number, String date) async {
    MobileNumberData mobileNumberData = new MobileNumberData();
    String id;
    var snapshot = await numberDataCollection
        .where("callBackDate", isEqualTo: date)
        .limit(1)
        .get();
    snapshot.docs.forEach((element) {
      id = element.id;
      mobileNumberData = MobileNumberData.fromJson(element.data());
    });
    if (id != null) {
      mobileNumberData.mobileNumbers.add(number);
      numberDataCollection
          .doc(id)
          .set(mobileNumberData.toJson(), SetOptions(merge: true));
    } else {
      List<String> numbers = [];
      numbers.add(number);
      mobileNumberData.mobileNumbers = numbers;
      mobileNumberData.status = 1;
      mobileNumberData.createdDate = getDate();
      mobileNumberData.notAnswerd = 1;
      mobileNumberData.callBack = 0;
      mobileNumberData.callBackDate = date;
      numberDataCollection.add(mobileNumberData.toJson());
    }
  }

  Future<void> updateNotAnsweredData(List<String> numberData) async {
    MobileNumberData mobileNumberData = new MobileNumberData();
    mobileNumberData.mobileNumbers = numberData;
    mobileNumberData.status = 1;
    mobileNumberData.notAnswerd = 0;
    numberDataCollection.add(mobileNumberData.toJson());
  }

  Future<List<String>> getMobileNumbers(String userId, String location) async {
    if (location == null) location = 'Others';
    String id = "";
    MobileNumberData mobileNumberData = new MobileNumberData();
    var snapshot = await numberDataCollection
        .where("status", isEqualTo: 0)
        .where("location", isEqualTo: location)
        .limit(1)
        .get();
    if (snapshot.docs.length == 0) {
      snapshot = await numberDataCollection
          .where("status", isEqualTo: 0)
          .where("location", isEqualTo: "Others")
          .limit(1)
          .get();
    }
    snapshot.docs.forEach((element) {
      id = element.id;
      mobileNumberData = MobileNumberData.fromJson(element.data());
    });
    mobileNumberData.userId = userId;
    mobileNumberData.status = 1;
    if (id.isNotEmpty) numberDataCollection.doc(id).delete();
    return mobileNumberData.mobileNumbers;
  }

  Future<void> updateCallBackNumberData(List<String> numberData) async {
    MobileNumberData mobileNumberData = new MobileNumberData();
    mobileNumberData.mobileNumbers = numberData;
    mobileNumberData.status = 1;
    mobileNumberData.notAnswerd = 1;
    mobileNumberData.callBackDate = getDate();
    numberDataCollection.add(mobileNumberData.toJson());
  }

  Future<void> saveCustomerData(CustomerModel data) async {
    var doc =
        await customerData.doc(data.customerName + data.phoneNumber).get();
    print("object");
    if (!doc.exists)
      return customerData
          .doc(data.customerName + data.phoneNumber)
          .set(data.toJson(), SetOptions(merge: true));
    else
      return null;
  }

  Future<NumbersAvailable> getAvailableNumberCount() async {
    NumbersAvailable numbersAvailable =
        new NumbersAvailable(numbersAvailable: 0, notAnsweredNumbers: 0);
    var snapshot =
        await numberDataCollection.where("status", isEqualTo: 0).get();
    var snapshotNotAns =
        await numberDataCollection.where("notAnswerd", isEqualTo: 0).get();
    MobileNumberData mobileNumberData;
    snapshotNotAns.docs.forEach((element) {
      mobileNumberData = MobileNumberData.fromJson(element.data());
      numbersAvailable.notAnsweredNumbers =
          numbersAvailable.notAnsweredNumbers +
              mobileNumberData.mobileNumbers.length;
    });
    snapshot.docs.forEach((element) {
      mobileNumberData = MobileNumberData.fromJson(element.data());
      numbersAvailable.numbersAvailable = numbersAvailable.numbersAvailable +
          mobileNumberData.mobileNumbers.length;
    });
    numbersAvailableLog
        .doc("numberslog")
        .set(numbersAvailable.toJson(), SetOptions(merge: true));
    return numbersAvailable;
  }

  Future<int> getAvailableNumberCountByLocation(String location) async {
    int count = 0;
    var snapshot = await numberDataCollection
        .where("status", isEqualTo: 0)
        .where("location", isEqualTo: location)
        .get();
    MobileNumberData mobileNumberData;
    snapshot.docs.forEach((element) {
      mobileNumberData = MobileNumberData.fromJson(element.data());
      count = count + mobileNumberData.mobileNumbers.length;
    });
    return count;
  }

  void setNumbersAvailableLog(int count, bool minus) async {
    NumbersAvailable numbersAvailable =
        new NumbersAvailable(numbersAvailable: 0);
    DocumentSnapshot numbersSnapshot =
        await numbersAvailableLog.doc("numberslog").get();

    var snapshot =
        await numberDataCollection.where("status", isEqualTo: 0).get();

    var snapshotNotAns =
        await numberDataCollection.where("notAnswred", isEqualTo: 0).get();
    MobileNumberData mobileNumberData;
    snapshotNotAns.docs.forEach((element) {
      mobileNumberData = MobileNumberData.fromJson(element.data());
      numbersAvailable.notAnsweredNumbers = numbersAvailable.numbersAvailable +
          mobileNumberData.mobileNumbers.length;
    });

    snapshot.docs.forEach((element) {
      mobileNumberData = MobileNumberData.fromJson(element.data());
      numbersAvailable.numbersAvailable = numbersAvailable.numbersAvailable +
          mobileNumberData.mobileNumbers.length;
    });

    if (false) {
      numbersAvailable = NumbersAvailable.fromJson(numbersSnapshot.data());
      if (numbersAvailable != null &&
          numbersAvailable.numbersAvailable != null &&
          numbersAvailable.numbersAvailable > 0) {
        if (!minus)
          numbersAvailable.numbersAvailable =
              numbersAvailable.numbersAvailable + count;
        else
          numbersAvailable.numbersAvailable =
              numbersAvailable.numbersAvailable - count;
      }
    }
    // else
    //   numbersAvailable.numbersAvailable = count;
    numbersAvailableLog
        .doc("numberslog")
        .set(numbersAvailable.toJson(), SetOptions(merge: true));
  }

  TimeCard getUserTimeCard(
      String userId,
      int time,
      int callsaccepted,
      TimeCard timeCardinput,
      int callsCallBack,
      int callsNotAns,
      int numbersPulled,
      int callsNotIntreseted) {
    TimeCard timeCard = new TimeCard();
    timeCard = timeCardinput;
    TimeLogging timeLogging = new TimeLogging();
    List<TimeLogging> timeLoggingList = [];
    timeLogging.date = getDate();
    timeLogging.time = time;
    timeLogging.callsaccepted = callsaccepted;
    timeLogging.callsCallBack = callsCallBack;
    timeLogging.callsNotAns = callsNotAns;
    timeLogging.callsNotIntreseted = callsNotIntreseted;
    timeLogging.numbersPulled = numbersPulled;
    if (timeCard.timeLogging != null &&
        timeCard.timeLogging.map((e) => e.date.contains(getDate())) != null) {
      timeLoggingList = timeCard.timeLogging;
      print(timeLoggingList.length);
      timeLoggingList
          .removeWhere((element) => element.date.contains(timeLogging.date));
      print(timeLoggingList.length);
      timeLoggingList.add(timeLogging);
    } else {
      if (timeCard.timeLogging != null) timeLoggingList = timeCard.timeLogging;
      timeLoggingList.add(timeLogging);
    }
    timeCard.timeLogging = timeLoggingList;
    timeCard.uid = userId;
    return timeCard;
  }

  String getDate() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }
}
