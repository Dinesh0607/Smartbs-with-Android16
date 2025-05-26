import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbs/models/user_model.dart';
import 'package:smartbs/utils/firebase_utility.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:velocity_x/velocity_x.dart";

import '../../../constants.dart';

class UserAccessScreen extends StatefulWidget {
  @override
  _UserAccessScreenState createState() => _UserAccessScreenState();
}

class _UserAccessScreenState extends State<UserAccessScreen>
    with TickerProviderStateMixin {
  SharedPreferences sharedPreferences;
  List<UsersList> userList = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    getFilterData();
  }

  getFilterData() async {
    userList = await FirebaseUtility().getUsersVerifiedList();
    final preferences = await StreamingSharedPreferences.instance;
    preferences.setString(
        'filterDateForLeads', DateFormat('dd-MM-yyyy').format(DateTime.now()));
    Preference<String> counter = preferences.getString('filterDateForLeads',
        defaultValue: DateFormat('dd-MM-yyyy').format(DateTime.now()));
    Preference<String> counterForCaller =
        preferences.getString('filterLeadsByCaller', defaultValue: null);
    counter.listen((value) {
      if (value != null && value.isNotBlank) {
        getPerf(value, null);
      } else
        null;
    });
    counterForCaller.listen((value) {
      if (value != null && value.isNotBlank) {
        getPerf(null, value);
      } else
        null;
    });
    setState(() {});
  }

  Future<void> getPerf(String date, String uid) async {
    setState(() {});
  }

  _onRefresh() {
    getPerf(null, null);
    _refreshController.refreshCompleted();
  }

  _callNumber(String phoneNumber) async {
    String number = phoneNumber;
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  _generateRepot() async {
    String csvData = ListToCsvConverter().convert(getReportStringList());
    final content = base64Encode(csvData.codeUnits);
    final url = 'data:application/csv;base64,$content';
    await launch(url);
    VxToast.show(context, msg: "Report downloaded", bgColor: Colors.green);
  }

  List<List<String>> getReportStringList() {
    List<List<String>> data = [];

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   heroTag: "fab",
      //   backgroundColor: Colors.pink[500],
      //   elevation: 3,
      //   child: Icon(
      //     Icons.filter_alt,
      //     color: Colors.white,
      //   ),
      //   onPressed: () {
      //     showSheet(context, userList);
      //   },
      // ),
      appBar: AppBar(
        title: Center(child: Text("User Access Management ")),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Users Access Management",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: DataTable2(
                          minWidth: 600,
                          columnSpacing: defaultPadding,
                          columns: [
                            DataColumn(
                              label: Text("Name"),
                            ),
                            DataColumn(
                              label: Text("Location"),
                            ),
                            DataColumn(
                              label: Text("Access"),
                            ),
                            DataColumn(
                              label: Text("Role"),
                            ),
                          ],
                          rows: List.generate(
                            userList.length,
                            (index) =>
                                recentFileDataRow(userList[index], context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (kIsWeb)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                ),
                child: Text(
                  "Generate Report",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  _generateRepot();
                },
              ),
          ],
        ),
      ),
    );
  }
}

void showSheet(context, List<UsersList> userList) {
  TextStyle(color: Colors.white, height: 1.4, fontSize: 16);
  String filterDateForLeads = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String filterLeadsByCaller;
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter mystate) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Filter",
                            style: TextStyle(
                              color: Colors.grey[700],
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: DateTimeField(
                        selectedDate:
                            DateFormat("dd-MM-yyyy").parse(filterDateForLeads),
                        firstDate: DateTime(2020, 1, 1),
                        //errorText: "Required",
                        mode: DateTimeFieldPickerMode.date,
                        decoration: InputDecoration(
                          filled: true,
                          icon: const Icon(Icons.date_range),
                          hintText: "Filter Date",
                          labelText: "Filter Date",
                        ),
                        //label: "Date of birth",
                        initialDatePickerMode: DatePickerMode.day,
                        onDateSelected: (DateTime value) {
                          filterDateForLeads =
                              DateFormat('dd-MM-yyyy').format(value);
                          mystate(() {});
                        },
                      ),
                    ),
                    Container(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: DropdownButton(
                        value: filterLeadsByCaller,
                        hint: Text("Filter By Caller"),
                        //value: customerData.bank,
                        items: userList
                            .map((UsersList item) => DropdownMenuItem<String>(
                                child: Text(item.displayName), value: item.uid))
                            .toList(),
                        onChanged: (value) {
                          filterLeadsByCaller = value;
                          mystate(() {});
                        },
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: SizedBox(
                          width: double.infinity, // match_parent
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.black,
                            ),
                            child: Text(
                              "SEARCH",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              final preferences =
                                  await StreamingSharedPreferences.instance;
                              if (filterLeadsByCaller != null &&
                                  filterLeadsByCaller.isNotEmpty) {
                                preferences.setString('filterDateForLeads', "");
                                preferences.setString(
                                    'filterLeadsByCaller', filterLeadsByCaller);
                              } else {
                                preferences.setString(
                                    'filterLeadsByCaller', "");
                                preferences.setString(
                                    'filterDateForLeads', filterDateForLeads);
                              }
                              Navigator.pop(context);
                            },
                          ),
                        )),
                    Container(
                      height: 10,
                    )
                  ],
                ),
              ),
            ),
          );
        });
      });
}

DataRow recentFileDataRow(UsersList userList, BuildContext context) {
  return DataRow(
    cells: [
      DataCell(
        Text(userList.displayName),
        onTap: () => {
          confirmationDialog(context, userList),
        },
      ),
      DataCell(
        Text(userList.location != null ? userList.location : " "),
      ),
      DataCell(
        userList.userVerified ? Icon(Icons.verified) : Icon(Icons.block),
        onTap: () => {
          userAccessDailog(context, userList),
        },
      ),
      DataCell(
        Text(userList.userRole != null ? userList.userRole : ""),
      ),
    ],
  );
}

void userAccessDailog(BuildContext context, UsersList userList) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter mystate) {
        return AlertDialog(
          title: Text(userList.userVerified
              ? userList.displayName + " access will be removed"
              : userList.displayName + " access will be activated"),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            if (!userList.userVerified)
              TextButton(
                child: const Text('Delete'),
                onPressed: () {
                  FirebaseUtility().deleteUser(userList);
                  VxToast.show(context,
                      msg: "User deleted : " + userList.displayName,
                      bgColor: Colors.red);
                  Navigator.of(context).pop();
                },
              ),
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                userList.userVerified = !userList.userVerified;
                FirebaseUtility().updateUserAccess(userList);
                VxToast.show(context,
                    msg: "User Updated : " + userList.displayName,
                    bgColor: Colors.green);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
    },
  );
}

void confirmationDialog(BuildContext context, UsersList userList) async {
  String selectedLocation = "";
  List<String> location = [
    "Nellore-1",
    "Nellore-2",
    "Nellore-3",
    "Naidupeta",
    "Tirupati-1",
    "Tirupati-2"
  ];
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter mystate) {
        return AlertDialog(
          title: Text("Select User Location: " + userList.displayName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: location
                .map((r) => RadioListTile(
                      title: Text(r),
                      groupValue: selectedLocation,
                      selected: r == selectedLocation,
                      value: r,
                      onChanged: (val) {
                        mystate(() {
                          selectedLocation = val;
                        });
                      },
                    ))
                .toList(),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                userList.location = selectedLocation;
                FirebaseUtility().updateUserLocation(userList);
                VxToast.show(context,
                    msg: "User Updated : " + userList.displayName,
                    bgColor: Colors.green);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
    },
  );
}
