import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbs/base/my_text.dart';
import 'package:smartbs/models/customer_model.dart';
import 'package:smartbs/screens/components/my_colors.dart';
import 'package:smartbs/utils/firebase_utility.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import "package:velocity_x/velocity_x.dart";

import '../../../responsive.dart';

class LeadsDataScreen extends StatefulWidget {
  @override
  _LeadsDataScreenState createState() => _LeadsDataScreenState();
}

class _LeadsDataScreenState extends State<LeadsDataScreen>
    with TickerProviderStateMixin {
  SharedPreferences sharedPreferences;
  List<CustomerModel> customerModelList = [];
  String datefilter;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    getFilterData();
  }

  getFilterData() async {
    final preferences = await StreamingSharedPreferences.instance;
    preferences.setString(
        'filterDateForLeads', DateFormat('dd-MM-yyyy').format(DateTime.now()));
    Preference<String> counter = preferences.getString('filterDateForLeads',
        defaultValue: DateFormat('dd-MM-yyyy').format(DateTime.now()));
    counter.listen((value) {
      datefilter = DateFormat(DateFormat.YEAR_MONTH_DAY)
          .format(DateFormat("dd-MM-yyyy").parse(value));
      getPerf(value);
    });
  }

  getPerf(String date) async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("uid") != null)
      customerModelList = await FirebaseUtility()
          .getCustomerListByUser(sharedPreferences.getString("uid"), date);
    setState(() {});
  }

  _onRefresh() {
    getPerf(FirebaseUtility().getDate());
    _refreshController.refreshCompleted();
  }

  _callNumber(String phoneNumber) async {
    String number = phoneNumber;
    await FlutterPhoneDirectCaller.callNumber(number);
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
          showSheet(context);
        },
      ),
      appBar: AppBar(
        title: Center(child: Text("Leads Data          ")),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            (datefilter != null
                    ? datefilter.toString()
                    : "${DateFormat(DateFormat.YEAR_MONTH_DAY).format(DateTime.now()).toString()}")
                .text
                .black
                .bold
                .widest
                .size(20.0)
                .make(),
            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(onPrimary: Colors.blue[700]),
            //   child: Text(
            //       datefilter != null
            //           ? datefilter.toString()
            //           : "${DateFormat(DateFormat.YEAR_MONTH_DAY).format(DateTime.now()).toString()}",
            //       style: TextStyle(color: Colors.white)),
            //   onPressed: () async {
            //     final date = await showDatePicker(
            //         context: context,
            //         initialDate: DateTime.now(),
            //         firstDate: DateTime(2021, 1, 1),
            //         lastDate: DateTime(2025, 1, 1),
            //         builder: (BuildContext context, Widget child) {
            //           return Theme(
            //               data: ThemeData(
            //                   primaryColor: Colors.black,
            //                   accentColor: Colors.black54,
            //                   buttonBarTheme: ButtonBarThemeData(
            //                     buttonTextTheme: ButtonTextTheme.accent,
            //                   )),
            //               child: child);
            //         });
            //     if (date != null) {
            //       var formatter = new DateFormat('dd-MM-yyyy');
            //       datefilter = DateFormat(DateFormat.YEAR_MONTH_DAY)
            //           .format(date)
            //           .toString();
            //       getPerf(formatter.format(date));
            //     }
            //   },
            // ),
            Divider(),
            Expanded(
              child: SmartRefresher(
                controller: _refreshController,
                onRefresh: () {
                  _onRefresh();
                },
                onLoading: () {
                  // _onRefresh();
                },
                enablePullDown: true,
                header: WaterDropHeader(),
                child: ListView.builder(
                  itemCount: customerModelList != null &&
                          customerModelList.length != null
                      ? customerModelList.length
                      : 0,
                  itemBuilder: (context, index) {
                    return ExpansionTile(
                      leading: Container(
                          child: InkWell(
                              onTap: () {
                                _callNumber(
                                    customerModelList[index].phoneNumber);
                              },
                              child: Icon(Icons.call, color: MyColors.primary)),
                          width: 35,
                          height: 35),
                      key: PageStorageKey<int>(index),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(customerModelList[index].customerName,
                              style: MyText.subhead(context).copyWith(
                                  color: MyColors.grey_90,
                                  fontWeight: FontWeight.bold)),
                          Container(height: 2),
                          Text(customerModelList[index].phoneNumber,
                              style: MyText.body1(context)
                                  .copyWith(color: MyColors.grey_40)),
                        ],
                      ),
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(height: 2),
                            Center(
                              child: Text(
                                  "Comments:  " +
                                      (customerModelList[index].comments != null
                                          ? customerModelList[index].comments
                                          : "No Comments"),
                                  style: MyText.body1(context).copyWith(
                                      color: MyColors.grey_40,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showSheet(context) {
  TextStyle(color: Colors.white, height: 1.4, fontSize: 16);
  String filterDateForLeads = DateFormat('dd-MM-yyyy').format(DateTime.now());
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
                              preferences.setString(
                                  'filterDateForLeads', filterDateForLeads);
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
