import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbs/models/numbers_available.dart';
import 'package:smartbs/models/time_card.dart';
import 'package:smartbs/models/userInfoTable.dart';
import 'package:smartbs/models/user_model.dart';
import 'package:smartbs/screens/components/dashboard_data.dart';
import 'package:smartbs/screens/components/header.dart';
import 'package:smartbs/screens/components/user_table_data.dart';
import 'package:smartbs/utils/firebase_utility.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../constants.dart';
import '../../responsive.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<UserInfoTable> tableData = [];
  List<TimeCard> timeCardList = [];
  List<UsersList> userList = [];
  String date;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  UserInfoTable userInfoTableData = UserInfoTable(
      callBacks: 0,
      leads: 0,
      notAns: 0,
      numbersAvailable: 0,
      numbersDailed: 0,
      numbersPulled: 0,
      timeWorked: 0);

  int initialLoad = 0;

  @override
  void initState() {
    super.initState();
    getChangeValues();
  }

  getChangeValues() async {
    date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    String filterByType = 'Today';
    final preferences = await StreamingSharedPreferences.instance;
    preferences.setString(
        'filterDate', DateFormat('dd-MM-yyyy').format(DateTime.now()));
    Preference<String> counter = preferences.getString('filterDate',
        defaultValue: DateFormat('dd-MM-yyyy').format(DateTime.now()));
    counter.listen((value) {
      date = value;
      initialLoad = 0;
      preferences.setString('filterByType', "Today");
      getDashboardData(date, 1);
    });
    preferences.setString('filterByType', "Today");
    Preference<String> filterByTypeCounter =
        preferences.getString('filterByType', defaultValue: "Today");
    filterByTypeCounter.listen((value) {
      filterByType = value;
      int filterValue = 1;
      switch (filterByType) {
        case "Today":
          {
            filterValue = 1;
          }
          break;

        case "Week to Date":
          {
            filterValue = 7;
          }
          break;

        case "Month to Date":
          {
            filterValue = 30;
          }
          break;
      }
      if (initialLoad == 1) getDashboardData(date, filterValue);
    });
  }

  getDashboardData(String date, int filterByType) async {
    tableData = [];
    userInfoTableData = UserInfoTable(
        callBacks: 0,
        leads: 0,
        notAns: 0,
        numbersAvailable: 0,
        numbersPulled: 0,
        numbersDailed: 0,
        timeWorked: 0);
    UserInfoTable userInfoTable = new UserInfoTable();
    timeCardList = await FirebaseUtility().getUsersLoggingList();
    userList = await FirebaseUtility().getUsersVerifiedList();
    NumbersAvailable numbersAvailable =
        await FirebaseUtility().getAvailableNumberCount();
    userInfoTableData.numbersAvailable = numbersAvailable.numbersAvailable;
    userInfoTableData.notAnsNumbersAvailable =
        numbersAvailable.notAnsweredNumbers;
    for (var timeCard in timeCardList) {
      if (timeCard.uid != null)
        for (var user in userList) {
          if (user.uid == timeCard.uid && filterByType == 1) {
            for (var logging in timeCard.timeLogging.reversed) {
              if (logging.date == date) {
                buildTableData(userInfoTable, user, logging, false);
                break;
              }
            }
          } else if (user.uid == timeCard.uid && filterByType != 1) {
            for (var logging in timeCard.timeLogging.reversed) {
              if (logging.date == date) {
                int i = 1;
                userInfoTable = UserInfoTable(
                    callBacks: 0,
                    leads: 0,
                    timeWorked: 0,
                    numbersPulled: 0,
                    notAns: 0,
                    notIns: 0);
                for (var logging in timeCard.timeLogging.reversed) {
                  if (i <= filterByType) {
                    userInfoTable.userName =
                        user.displayName != null ? user.displayName : "";
                    userInfoTable.location =
                        user.location != null ? user.location : "";
                    userInfoTable.callBacks =
                        userInfoTable.callBacks + logging.callsCallBack;
                    userInfoTable.numbersPulled =
                        userInfoTable.numbersPulled + logging.numbersPulled !=
                                null
                            ? logging.numbersPulled
                            : 0;
                    userInfoTable.leads =
                        userInfoTable.leads + logging.callsaccepted;
                    userInfoTable.timeWorked =
                        userInfoTable.timeWorked + logging.time;
                    userInfoTable.notIns =
                        userInfoTable.notIns + logging.callsNotIntreseted;
                    userInfoTable.notAns =
                        userInfoTable.notAns + logging.callsNotAns;
                    print(userInfoTable.numbersPulled);
                    i++;
                  } else {
                    break;
                  }
                }
                tableData.add(userInfoTable);
                userInfoTableData.callBacks =
                    userInfoTableData.callBacks + logging.callsCallBack;
                userInfoTableData.leads =
                    userInfoTableData.leads + logging.callsaccepted;
                userInfoTableData.numbersDailed =
                    userInfoTableData.numbersDailed +
                        logging.callsCallBack +
                        logging.callsNotAns +
                        logging.callsNotIntreseted +
                        logging.callsaccepted;
              }
            }
          }
        }
    }
    initialLoad = 1;
    setState(() {});
    EasyLoading.dismiss();
  }

  void buildTableData(UserInfoTable userInfoTable, UsersList user,
      TimeLogging logging, bool bool) {
    userInfoTable = UserInfoTable();
    if (bool && tableData != null && tableData.length > 0)
      userInfoTable = tableData[0];
    userInfoTable.userName = user.displayName != null ? user.displayName : "";
    userInfoTable.location = user.location != null ? user.location : "";
    userInfoTable.callBacks =
        userInfoTable != null && userInfoTable.callBacks != null
            ? userInfoTable.callBacks
            : 0 + logging.callsCallBack;
    userInfoTable.leads = userInfoTable != null && userInfoTable.leads != null
        ? userInfoTable.leads
        : 0 + logging.callsaccepted;
    userInfoTable.timeWorked =
        userInfoTable != null && userInfoTable.timeWorked != null
            ? userInfoTable.timeWorked
            : 0 + logging.time;
    userInfoTable.notIns = userInfoTable != null && userInfoTable.notIns != null
        ? userInfoTable.notIns
        : 0 + logging.callsNotIntreseted;
    userInfoTable.notAns = userInfoTable != null && userInfoTable.notAns != null
        ? userInfoTable.notAns
        : 0 + logging.callsNotAns;
    userInfoTable.numbersPulled =
        userInfoTable != null && userInfoTable.numbersPulled != null
            ? userInfoTable.notAns
            : 0 +
                (logging != null && logging.numbersPulled != null
                    ? logging.numbersPulled
                    : 0);
    tableData.add(userInfoTable);
    userInfoTableData.callBacks =
        userInfoTableData.callBacks + logging.callsCallBack;
    userInfoTableData.leads = userInfoTableData.leads + logging.callsaccepted;
    userInfoTableData.numbersDailed = userInfoTableData.numbersDailed +
        logging.callsCallBack +
        logging.callsNotAns +
        logging.callsNotIntreseted +
        logging.callsaccepted;
  }

  String getDate(String date) {
    return date;
  }

  _onRefresh() async {
    initialLoad = 0;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    getDashboardData(sharedPreferences.getString("filterDate"), 1);
    _refreshController.refreshCompleted();
  }

  _generateRepot() async {
    String csvData = ListToCsvConverter().convert(getReportStringList());
    final content = base64Encode(csvData.codeUnits);
    final url = 'data:application/csv;base64,$content';
    await launch(url);
    EasyLoading.dismiss();
    VxToast.show(context, msg: "Report downloaded", bgColor: Colors.green);
  }

  List<List<String>> getReportStringList() {
    List<List<String>> data = [];
    data.add([
      DateFormat(DateFormat.YEAR_MONTH_DAY)
          .format(DateFormat("dd-MM-yyyy").parse(date))
    ]);
    data.add([
      "Caller Name",
      "Call Backs",
      "Leads",
      "Not Ans",
      "Not Interested",
      "Total Calls",
      "Time Worked",
      "User Location"
    ]);
    for (var userInfoTable in tableData) {
      data.add([
        userInfoTable.userName.toString(),
        userInfoTable.callBacks.toString(),
        userInfoTable.leads.toString(),
        userInfoTable.notAns.toString(),
        userInfoTable.notIns.toString(),
        (userInfoTable.callBacks +
                userInfoTable.notIns +
                userInfoTable.notAns +
                userInfoTable.leads)
            .toString(),
        ((userInfoTable.timeWorked / 60) / 60).truncate().toString() +
            ":" +
            (((userInfoTable.timeWorked / 60).truncate()) -
                    ((((userInfoTable.timeWorked / 60) / 60).truncate() * 60)))
                .toString(),
        userInfoTable.location
      ]);
    }
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
      body: SafeArea(
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: () {
            _onRefresh();
          },
          onLoading: () {
            //_onRefresh();
          },
          enablePullDown: true,
          header: WaterDropHeader(),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                Header(),
                SizedBox(height: defaultPadding),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          DashboardData(
                            data: userInfoTableData,
                          ),
                          SizedBox(height: defaultPadding),
                          UserTableData(tableData: tableData),
                          if (Responsive.isMobile(context))
                            SizedBox(height: defaultPadding),
                          //if (Responsive.isMobile(context)) StarageDetails(),
                        ],
                      ),
                    ),

                    if (!Responsive.isMobile(context))
                      SizedBox(width: defaultPadding),
                    // On Mobile means if the screen is less than 850 we dont want to show it
                    // if (!Responsive.isMobile(context))
                    //   Expanded(
                    //     flex: 2,
                    //     child: StarageDetails(),
                    //   ),
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
                if (!kIsWeb)
                  Link(
                      uri: Uri.parse("https://smartbs.web.app/"),
                      target: LinkTarget.defaultTarget,
                      builder: (context, followLink) {
                        return ElevatedButton(
                            onPressed: followLink,
                            child: Text("Download Reports"));
                      }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
