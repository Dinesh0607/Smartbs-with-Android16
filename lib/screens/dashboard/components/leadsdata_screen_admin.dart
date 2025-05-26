import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbs/models/customer_model.dart';
import 'package:smartbs/models/user_model.dart';
import 'package:smartbs/screens/components/user_table_data_customer.dart';
import 'package:smartbs/utils/firebase_utility.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:velocity_x/velocity_x.dart";

import '../../../constants.dart';

class LeadsDataScreenAdmin extends StatefulWidget {
  @override
  _LeadsDataScreenAdminState createState() => _LeadsDataScreenAdminState();
}

class _LeadsDataScreenAdminState extends State<LeadsDataScreenAdmin>
    with TickerProviderStateMixin {
  SharedPreferences sharedPreferences;
  List<CustomerModel> customerModelList = [];
  String datefilter;
  List<UsersList> userList = [];
  String callerName;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    getFilterData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getFilterData() async {
    userList = await FirebaseUtility().getUsersVerifiedList();
    final preferences = await StreamingSharedPreferences.instance;
    preferences.setString(
        'filterDateForLeads', DateFormat('dd-MM-yyyy').format(DateTime.now()));
    preferences.remove('filterDateForLeadsBefore');
    Preference<String> counter = preferences.getString('filterDateForLeads',
        defaultValue: DateFormat('dd-MM-yyyy').format(DateTime.now()));
    Preference<String> counterForCaller =
        preferences.getString('filterLeadsByCaller', defaultValue: null);
    Preference<String> counterFilterbwDates =
        preferences.getString('filterDateForLeadsBefore', defaultValue: null);
    counter.listen((value) {
      if (value != null && value.isNotBlank) {
        callerName = '';
        datefilter = DateFormat(DateFormat.YEAR_MONTH_DAY)
            .format(DateFormat("dd-MM-yyyy").parse(value));
        getPerf(value, null, null);
      } else
        datefilter = "";
    });
    counterForCaller.listen((value) {
      if (value != null && value.isNotBlank) {
        callerName =
            userList.where((element) => element.uid == value).first.displayName;
        getPerf(null, value, null);
      } else
        callerName = '';
    });

    counterFilterbwDates.listen((value) async {
      if (value != null && value.isNotBlank) {
        sharedPreferences = await SharedPreferences.getInstance();
        getDaysInBeteween(
            DateFormat("dd-MM-yyyy").parse(value),
            DateFormat("dd-MM-yyyy")
                .parse(sharedPreferences.getString("filterDateForLeadsAfter")));
      } else
        callerName = '';
    });
  }

  Future<void> getPerf(String date, String uid, List<String> dates) async {
    customerModelList = [];
    if (dates == null)
      customerModelList = await FirebaseUtility().getCustomerList(date, uid);
    else if (dates.length > 0)
      for (var d in dates) {
        customerModelList
            .addAll(await FirebaseUtility().getCustomerList(d, uid));
      }
    setState(() {});
    EasyLoading.dismiss();
  }

  _onRefresh() {
    getPerf(null, null, null);
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
    EasyLoading.dismiss();
    VxToast.show(context, msg: "Report downloaded", bgColor: Colors.green);
  }

  getDaysInBeteween(DateTime startDate, DateTime endDate) {
    List<String> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(
          DateFormat('dd-MM-yyyy').format(startDate.add(Duration(days: i))));
    }
    getPerf(null, null, days);
  }

  List<List<String>> getReportStringList() {
    List<List<String>> data = [];
    data.add([
      "Customer Name",
      callerName != null && callerName.isNotBlank ? "Caller" : "Date",
      "Phone Number",
      "Comments",
    ]);
    for (var customerModel in customerModelList) {
      data.add([
        customerModel.customerName,
        callerName != null && callerName.isNotBlank
            ? customerModel.caller
            : DateFormat(DateFormat.YEAR_MONTH_DAY).format(
                DateFormat("dd-MM-yyyy").parse(customerModel.createdDate)),
        customerModel.phoneNumber,
        customerModel.comments
      ]);
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "fab",
        backgroundColor: Colors.pink[500],
        elevation: 3,
        child: Icon(
          Icons.filter_alt,
          color: Colors.white,
        ),
        onPressed: () {
          showSheet(context, userList);
        },
      ),
      appBar: AppBar(
        title: Center(child: Text("Leads Data          ")),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              if (callerName != null && callerName.isNotBlank)
                callerName.text.black.bold.widest.size(20.0).make(),
              if (callerName == null || callerName.isEmpty)
                (datefilter != null
                        ? datefilter.toString()
                        : "${DateFormat(DateFormat.YEAR_MONTH_DAY).format(DateTime.now()).toString()}")
                    .text
                    .black
                    .bold
                    .widest
                    .size(20.0)
                    .make(),
              Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: UserTableDataCustomer(
                      customerModelList: customerModelList,
                      createdDate: callerName != null && callerName.isNotBlank
                          ? true
                          : false,
                    ),
                  )
                ],
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
                    EasyLoading.show(
                        status: 'loading...',
                        maskType: EasyLoadingMaskType.black);
                    _generateRepot();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void showSheet(context, List<UsersList> userList) {
  TextStyle(color: Colors.white, height: 1.4, fontSize: 16);
  String filterDateForLeads = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String filterDateForLeadsBefore =
      DateFormat('dd-MM-yyyy').format(DateTime.now());
  String filterDateForLeadsAfter =
      DateFormat('dd-MM-yyyy').format(DateTime.now());
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
                    Container(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: DateTimeField(
                        selectedDate: DateFormat("dd-MM-yyyy")
                            .parse(filterDateForLeadsBefore),
                        firstDate: DateTime(2020, 1, 1),
                        //errorText: "Required",
                        mode: DateTimeFieldPickerMode.date,
                        decoration: InputDecoration(
                          filled: true,
                          icon: const Icon(Icons.date_range),
                          hintText: "Filter Date Before",
                          labelText: "Filter Date Before",
                        ),
                        //label: "Date of birth",
                        initialDatePickerMode: DatePickerMode.day,
                        onDateSelected: (DateTime value) {
                          filterDateForLeadsBefore =
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
                      child: DateTimeField(
                        selectedDate: DateFormat("dd-MM-yyyy")
                            .parse(filterDateForLeadsAfter),
                        firstDate: DateTime(2020, 1, 1),
                        //errorText: "Required",
                        mode: DateTimeFieldPickerMode.date,
                        decoration: InputDecoration(
                          filled: true,
                          icon: const Icon(Icons.date_range),
                          hintText: "Filter Date After",
                          labelText: "Filter Date After",
                        ),
                        //label: "Date of birth",
                        initialDatePickerMode: DatePickerMode.day,
                        onDateSelected: (DateTime value) {
                          filterDateForLeadsAfter =
                              DateFormat('dd-MM-yyyy').format(value);
                          mystate(() {});
                        },
                      ),
                    ),
                    Container(
                      height: 20,
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
                              EasyLoading.show(
                                  status: 'loading...',
                                  maskType: EasyLoadingMaskType.black);
                              final preferences =
                                  await StreamingSharedPreferences.instance;
                              if (filterLeadsByCaller != null &&
                                  filterLeadsByCaller.isNotEmpty) {
                                preferences.setString('filterDateForLeads', "");
                                preferences.setString(
                                    'filterLeadsByCaller', filterLeadsByCaller);
                              } else if (filterDateForLeadsBefore !=
                                  filterDateForLeadsAfter) {
                                preferences.setString(
                                    'filterLeadsByCaller', "");
                                preferences.setString(
                                    'filterDateForLeadsBefore',
                                    filterDateForLeadsBefore);
                                preferences.setString('filterDateForLeadsAfter',
                                    filterDateForLeadsAfter);
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
