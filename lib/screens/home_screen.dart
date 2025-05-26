import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbs/controllers/MenuController.dart';
import 'package:smartbs/models/customer_model.dart';
import 'package:smartbs/models/mobile_number_data.dart';
import 'package:smartbs/models/user_model.dart';
import 'package:smartbs/screens/components/sidebar_telecaller.dart';
import 'package:smartbs/screens/customer_info_screen.dart';
import 'package:smartbs/screens/users_screen.dart';
import 'package:smartbs/signin/signin.dart';
import 'package:smartbs/utils/appDimens.dart';
import 'package:smartbs/utils/app_strings.dart';
import 'package:smartbs/utils/firebase_utility.dart';
import 'package:smartbs/utils/util.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../main.dart';
import '../responsive.dart';
import 'components/sidebar.dart';
import 'dashboard/dashboard_screen.dart';
import 'load_csv_screen.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  StreamSubscription<ConnectivityResult> subscription;
  final TextStyle whiteText = TextStyle(color: Colors.white);
  // GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  UserModel user;
  SharedPreferences sharedPreferences;
  AppDimens appDimens;
  bool isAdmin = false;
  List<CustomerModel> customerList = [];
  TextEditingController editingController = TextEditingController();
  bool _enabled = false;
  int _value;
  int isBlocked;
  int timer = 0;
  int callsaccepted = 0;
  int callsNotAns = 0;
  int callsCallBack = 0;
  int callsNotIntreseted = 0;
  int numbersPulled = 0;
  String currentMobileNumber = "";
  String callBackDateValue = "";

  List<String> callbackNumbers = [];

  bool startDay = true;
  bool endDay = false;
  bool takeBreak = false;
  bool backToWork = false;
  bool callBackDate = false;

  List<String> mobileNumberData = [];

  String _customerCallOption;

  bool timerCall = false;
  bool customerAnswer = false;
  bool customerDataForm = false;

  final _isHours = true;

  CustomerModel customerData = CustomerModel();
  String service;

  AutovalidateMode _autoValidateMode = AutovalidateMode.always;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Timer _timer;
  double _progress;

  // void controlMenu() {
  //   if (!scaffoldKey.currentState.isDrawerOpen) {
  //     scaffoldKey.currentState.openDrawer();
  //   }
  // }

  void setService(DateTime dob) {
    setState(() {
      service =
          ((DateTime.now().difference(dob).inDays) / 365).toStringAsFixed(0);
      customerData.service = service;
    });
  }

  void _removenumber(String number) async {
    mobileNumberData.remove(number);
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove("numberdata");
    sharedPreferences.setStringList("numberdata", mobileNumberData);
  }

  void updateCallsAccepted() async {
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt(getDate() + "callsaccepted", callsaccepted);
  }

  void updateNumbersPulled() async {
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt(getDate() + "numbersPulled", numbersPulled);
  }

  void updateCallsNotAns() async {
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt(getDate() + "callsNotAns", callsNotAns);
  }

  void updateCallsCallBack() async {
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt(getDate() + "callsCallBack", callsCallBack);
  }

  void updateCallsNotIntreseted() async {
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt(
        getDate() + "callsNotIntreseted", callsNotIntreseted);
  }

  void _updateCallBackNumber(String date) async {
    sharedPreferences = await SharedPreferences.getInstance();
    FirebaseUtility().updateCallBackNumbers(currentMobileNumber, date);
    if (sharedPreferences.getStringList(date + "callbacknumbers") != null)
      callbackNumbers =
          sharedPreferences.getStringList(date + "callbacknumbers");
    callbackNumbers.add(currentMobileNumber);
    await sharedPreferences.setStringList(
        date + "callbacknumbers", callbackNumbers);
  }

  void _updateCallsNotAns() async {
    sharedPreferences = await SharedPreferences.getInstance();
    List<String> callsNotAnsNumbers = [];
    if (sharedPreferences.getStringList("callsNotAnsList") != null)
      callsNotAnsNumbers = sharedPreferences.getStringList("callsNotAnsList");
    callsNotAnsNumbers.add(currentMobileNumber);
    await sharedPreferences.setStringList(
        "callsNotAnsList", callsNotAnsNumbers);
  }

  updateCallsNotIntresetedToDB() async {
    sharedPreferences = await SharedPreferences.getInstance();
    List<String> callsNotAnsNumbers = [];
    if (sharedPreferences.getStringList("callsNotAnsList") != null) {
      callsNotAnsNumbers = sharedPreferences.getStringList("callsNotAnsList");
      if (callsNotAnsNumbers.length > 0)
        FirebaseUtility().updateNotAnsweredData(callsNotAnsNumbers);
      VxToast.show(context,
          msg: "Not Answered Numbers Uploaded", bgColor: Colors.green);
      sharedPreferences.remove("callsNotAnsList");
    }
    mobileNumberData = sharedPreferences.getStringList("numberdata");

    if (mobileNumberData != null &&
        mobileNumberData != null &&
        mobileNumberData.length > 0) {
      FirebaseUtility().updateNumberData(mobileNumberData, user.location);
      VxToast.show(context,
          msg: "Remaining numbers uploaded back", bgColor: Colors.green);
      sharedPreferences.remove("numberdata");
      mobileNumberData = [];
      setState(() {});
    }
  }

  void _handleSubmitted() async {
    EasyLoading.show(status: 'loading...', maskType: EasyLoadingMaskType.black);
    final form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidateMode =
          AutovalidateMode.always; // Start validating on every change.

    } else {
      print(customerData.toJson());
      FirebaseUtility().saveCustomerData(customerData);
      //form.save();
      setState(() {
        customerDataForm = false;
      });
      //Get.back();
    }
    EasyLoading.dismiss();
  }

  String _emailValidator(String value) {
    if (value == null || value.isEmpty)
      return "Email Required";
    // else if (RegExp(
    //         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
    //     .hasMatch(value))
    //   return "Enter valid email";
    else
      return null;
  }

  String _validateName(String value) {
    if (value == null || value.isEmpty) {
      return "Required Field";
    }
    final nameExp = RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value)) {
      return "Only Alphanumeric charecters";
    }
    return null;
  }

  String _validateSalary(String value) {
    final phoneExp = RegExp(r'^\(\d\d\d\) \d\d\d\-\d\d\d\d$');
    if (value == null || value.isEmpty)
      return "Required field";
    // else if (!phoneExp.hasMatch(value)) {
    //   return "Enter India Phone Number";
    // }
    else
      return null;
  }

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    //presetMillisecond: timer,
    // onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    // onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
  );

  @override
  void initState() {
    if (!kIsWeb)
      try {
        versionCheck(context);
      } catch (e) {
        print(e);
      }
    super.initState();
    EasyLoading.addStatusCallback((status) {
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
    EasyLoading.show(status: 'loading...', maskType: EasyLoadingMaskType.black);
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      print("internet" + result.toString());
      if (result == ConnectivityResult.none) alertDialog(context);
    });

    getPref();
    //_stopWatchTimer.onExecute.add(StopWatchExecute.reset);
    _stopWatchTimer.secondTime.listen((value) => setTimer(value));
    // _stopWatchTimer.rawTime.listen((value) =>
    //     print('rawTime $value ${StopWatchTimer.getDisplayTime(value)}'));
    // _stopWatchTimer.minuteTime.listen((value) => print('minuteTime $value'));
    //_stopWatchTimer.secondTime.listen((value) => print('secondTime $value'));
    // _stopWatchTimer.records.listen((value) => print('records $value'));
  }

  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  versionCheck(context) async {
    print("Entered");
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    double currentVersion =
        double.parse(info.version.trim().replaceAll(".", ""));

    //Get Latest version info from firebase config
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));
      await remoteConfig.fetchAndActivate();
      remoteConfig.getString('force_update_current_version');
      double newVersion = double.parse(remoteConfig
          .getString('force_update_current_version')
          .trim()
          .replaceAll(".", ""));
      if (newVersion > currentVersion) {
        _showVersionDialog(context);
      }
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
  }

  setTimer(int value) async {
    if (value != 0) {
      timer = value;
      sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setInt(getDate(), value);
      //print("Entered" + sharedPreferences.getInt(getDate()).toString());
    }
  }

  String getDate() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  getPref() async {
    //customerList = await FirebaseUtility().getCustomerList();
    sharedPreferences = await SharedPreferences.getInstance();
    if (mounted)
      setState(() {
        user = UserModel.fromJson(
            jsonDecode(sharedPreferences.getString(AppStrings.USER_PREF_KEY)));

        if (user != null &&
            user.email != null &&
            (user.email == "smartbsflutter@gmail.com" ||
                user.email == "smartbusinesssolutions8088@gmail.com")) {
          isAdmin = true;
        }
      });
    user = await FirebaseUtility().getsingleUser(user == null ? "0" : user.uid);
    context.read<MenuController>().changeUser(user);
    sharedPreferences.remove("uid");
    //print(sharedPreferences.getInt(getDate()));
    if (!isAdmin) {
      sharedPreferences.setString("uid", user.uid);
      if (sharedPreferences.getInt(getDate()) != null)
        _stopWatchTimer
            .setPresetSecondTime(sharedPreferences.getInt(getDate()));
      if (sharedPreferences.getInt(getDate() + "callsaccepted") != null)
        callsaccepted = sharedPreferences.getInt(getDate() + "callsaccepted");
      if (sharedPreferences.getInt(getDate() + "callsNotAns") != null)
        callsNotAns = sharedPreferences.getInt(getDate() + "callsNotAns");
      if (sharedPreferences.getInt(getDate() + "callsCallBack") != null)
        callsCallBack = sharedPreferences.getInt(getDate() + "callsCallBack");
      if (sharedPreferences.getInt(getDate() + "numbersPulled") != null)
        numbersPulled = sharedPreferences.getInt(getDate() + "numbersPulled");
      if (sharedPreferences.getInt(getDate() + "callsNotIntreseted") != null)
        callsNotIntreseted =
            sharedPreferences.getInt(getDate() + "callsNotIntreseted");
    }
    setState(() {});
    if (!isAdmin) EasyLoading.dismiss();
  }

  _startDate() async {
    EasyLoading.show(status: 'loading...', maskType: EasyLoadingMaskType.black);
    _refreshNUmberData();
    setState(() {});
    EasyLoading.dismiss();
  }

  _refreshNUmberData() async {
    EasyLoading.show(status: 'loading...', maskType: EasyLoadingMaskType.black);
    sharedPreferences = await SharedPreferences.getInstance();
    print(mobileNumberData);
    if (sharedPreferences.getStringList("numberdata") == null) {
      mobileNumberData =
          await FirebaseUtility().getMobileNumbers(user.uid, user.location);
      sharedPreferences.setStringList("numberdata", mobileNumberData);
      if (mobileNumberData != null && mobileNumberData.length == 0) {
        numbersPulled = numbersPulled + mobileNumberData.length;
        updateNumbersPulled();
      }
    } else
      mobileNumberData = sharedPreferences.getStringList("numberdata");
    if (mobileNumberData != null && mobileNumberData.length == 0) {
      sharedPreferences.remove("numberdata");
      mobileNumberData =
          await FirebaseUtility().getMobileNumbers(user.uid, user.location);
      sharedPreferences.setStringList("numberdata", mobileNumberData);
      if (mobileNumberData != null) {
        numbersPulled = numbersPulled + mobileNumberData.length;
        updateNumbersPulled();
      }
      if (mobileNumberData.length == 0)
        VxToast.show(context,
            msg: "Ask admin to upload data",
            bgColor: Colors.red,
            showTime: 10000);
    } else {
      VxToast.show(context,
          msg: "Number Data already available", bgColor: Colors.red);
    }
    setState(() {});
    EasyLoading.dismiss();
  }

  _callNumber(String phoneNumber) async {
    String number = phoneNumber;
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  void filterSearchResults(String query) {
    List<CustomerModel> customerModeldummy = [];
    //dummySearchList.addAll(duplicateItems);
    if (query.isNotEmpty) {
      //List<String> dummyListData = List<String>();
      customerList.forEach((item) {
        if (item.customerName.toLowerCase().contains(query.toLowerCase())) {
          customerModeldummy.add(item);
        }
      });
      setState(() {
        customerList = customerModeldummy;
      });
      return;
    } else {
      setState(() {
        getPref();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isAdmin)
      return Scaffold(
        appBar: Responsive.isMobile(context)
            ? AppBar(
                title: Text("Dashboard"),
              )
            : null,
        key: context.read<MenuController>().scaffoldKey,
        drawer: SideBar().getDrawer(context, user),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideBar().getDrawer(context, user),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: DashboardScreen(),
            ),
          ],
        ),
      );
    else
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseUtility().getUser(user == null ? "0" : user.uid),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          // print(snapshot.hasData);
          // print("colll" +
          //     (snapshot.hasData && snapshot.data.get("isBlocked") == 1)
          //         .toString());
          //snapshot.hasData ? setUserData(snapshot.data.get("isBlocked")) : null;
          // if (snapshot != null && snapshot.hasData)
          //   print("snapshot.data.get(location)");
          return (snapshot.hasData && snapshot.data.get("isBlocked") == 0) ||
                  isAdmin
              ? Scaffold(
                  appBar: Responsive.isMobile(context)
                      ? AppBar(
                          title: Text("Welcome"),
                        )
                      : null,
                  floatingActionButton: isAdmin
                      ? SpeedDial(
                          marginEnd: 18,
                          marginBottom: 20,
                          icon: Icons.arrow_upward,
                          activeIcon: Icons.remove,
                          buttonSize: 56.0,
                          visible: true,
                          closeManually: false,
                          renderOverlay: false,
                          curve: Curves.bounceIn,
                          overlayColor: Colors.black,
                          overlayOpacity: 0.5,
                          // onOpen: () => print('OPENING DIAL'),
                          // onClose: () => print('DIAL CLOSED'),
                          tooltip: 'Actions',
                          heroTag: 'speed-dial-hero-tag',
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.black,
                          elevation: 8.0,
                          shape: CircleBorder(),
                          children: [
                            SpeedDialChild(
                              child: Icon(Icons.upload_file),
                              backgroundColor: Colors.green,
                              label: 'Upload Data',
                              labelStyle: TextStyle(fontSize: 18.0),
                              onTap: () => Get.to(LoadCSVScreen()),
                              onLongPress: () =>
                                  print('FIRST CHILD LONG PRESS'),
                            ),
                            SpeedDialChild(
                              child: Icon(Icons.verified_user),
                              backgroundColor: Colors.orange,
                              label: 'User Access',
                              labelStyle: TextStyle(fontSize: 18.0),
                              onTap: () => Get.to(UsersScreen()),
                              onLongPress: () =>
                                  print('SECOND CHILD LONG PRESS'),
                            ),
                          ],
                        )
                      : SpeedDial(
                          marginEnd: 18,
                          marginBottom: 20,
                          icon: Icons.arrow_upward,
                          activeIcon: Icons.remove,
                          buttonSize: 56.0,
                          visible: true,
                          closeManually: false,
                          renderOverlay: false,
                          curve: Curves.bounceIn,
                          overlayColor: Colors.black,
                          overlayOpacity: 0.5,
                          // onOpen: () => print('OPENING DIAL'),
                          // onClose: () => print('DIAL CLOSED'),
                          tooltip: 'Actions',
                          heroTag: 'speed-dial-hero-tag',
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.black,
                          elevation: 8.0,
                          shape: CircleBorder(),
                          children: [
                            SpeedDialChild(
                              child: Icon(Icons.refresh),
                              backgroundColor: Colors.orange,
                              label: 'Refresh Data',
                              labelStyle: TextStyle(fontSize: 18.0),
                              onTap: () => {_refreshNUmberData()},
                              onLongPress: () =>
                                  print('SECOND CHILD LONG PRESS'),
                            ),
                          ],
                        ),
                  backgroundColor: Colors.white,
                  key: context.read<MenuController>().scaffoldKey,
                  drawer: SideBarTeleCaller().getDrawer(context, user),
                  body: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // We want this side menu only for large screen
                      if (Responsive.isDesktop(context))
                        Expanded(
                          // default flex = 1
                          // and it takes 1/6 part of the screen
                          child: SideBarTeleCaller().getDrawer(context, user),
                        ),
                      Expanded(
                        // It takes 5/6 part of the screen
                        flex: 5,
                        child: _buildBody(context),
                      ),
                    ],
                  ),
                  // bottomNavigationBar: isAdmin ? _buildBottomBar() : null,
                )
              : noaccessmethod(context);
        },
      );
  }

  Scaffold noaccessmethod(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //LoaderTwo(),
              Text(
                "Please contact admin for access",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              SizedBox(
                height: 10.0,
              ),
              MaterialButton(
                onPressed: () {
                  signOutGoogle();
                  VxToast.show(context,
                      msg: "Logout Sucessfully", bgColor: Colors.red);
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) {
                    return MyApp(null);
                  }), ModalRoute.withName('/'));
                },
                color: Colors.deepPurple,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
              ),
              SizedBox(
                height: 10.0,
              ),
              MaterialButton(
                onPressed: () {
                  //getPref();
                },
                color: Colors.green,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Refresh',
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  tab1Services() {
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              MaterialButton(
                onPressed: () {
                  Get.to(CustomerInfo());
                },
                color: Colors.deepPurple,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Add Customer Data',
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
              ),
              Spacer(),
              MaterialButton(
                onPressed: () {
                  Get.to(CustomerInfo());
                },
                color: Colors.deepPurple,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Add Tele caller data',
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  tab3() {
    getPref();
    return Container(
      child: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              filterSearchResults(value);
            },
            controller: editingController,
            decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)))),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: customerList.length,
            itemBuilder: (context, index) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListTile(
                    onTap: () async {
                      Get.bottomSheet(Container(
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Give Access to User',
                              ),
                              SwitchListTile(
                                activeColor: Colors.purple,
                                contentPadding: const EdgeInsets.all(0),
                                value: _enabled,
                                title: Text("Activate"),
                                onChanged: (val) {
                                  setState(() {
                                    _enabled = val;
                                  });
                                  print(_enabled);
                                },
                              ),
                              DropdownButtonFormField(
                                  value: _value,
                                  items: [
                                    DropdownMenuItem(
                                      child: Text("Tele Caller"),
                                      value: 1,
                                    ),
                                    DropdownMenuItem(
                                      child: Text("Data Entry"),
                                      value: 2,
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _value = value;
                                    });
                                    print(_value);
                                  }),
                            ],
                          ),
                        ),
                        color: Colors.white,
                      ));
                    },
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    leading: CircleAvatar(
                      child: Text("U"),
                    ),
                    title: Text(customerList[index].customerName),
                    subtitle: Text(customerList[index].phoneNumber +
                        '  ' +
                        customerList[index].location),
                    isThreeLine: true,
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  tab2Users() {
    if (user != null && user.uid != null)
      return SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                        image: NetworkImage(user.photoURL), fit: BoxFit.cover)),
                margin: EdgeInsets.only(left: 16.0),
              ),
              Column(
                children: <Widget>[
                  ListTile(
                    title: Text("User information"),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Name"),
                    subtitle:
                        Text(user.displayName != null ? user.displayName : ""),
                    leading: Icon(Icons.person_rounded),
                  ),
                  ListTile(
                    title: Text("Email"),
                    subtitle: Text(user.email != null ? user.email : ""),
                    leading: Icon(Icons.email),
                  ),
                  ListTile(
                    title: Text("Phone"),
                    subtitle:
                        Text(user.phoneNumber != null ? user.phoneNumber : ""),
                    leading: Icon(Icons.phone),
                  ),
                  ListTile(
                    title: Text("About"),
                    subtitle: Text(
                        "Lorem ipsum, dolor sit amet consectetur adipisicing elit. Nulla, illo repellendus quas beatae reprehenderit nemo, debitis explicabo officiis sit aut obcaecati iusto porro? Exercitationem illum consequuntur magnam eveniet delectus ab."),
                    leading: Icon(Icons.info),
                  ),
                  ListTile(
                    title: Text("Joined Date"),
                    subtitle: Text(Utils.dateFormatToShow(
                        DateTime.parse(user.memberSince))),
                    leading: Icon(Icons.calendar_view_day),
                  ),
                  if (isAdmin)
                    ListTile(
                      tileColor: Colors.green,
                      title: Text("Users Access"),
                      leading: Icon(Icons.accessible),
                      onTap: () {
                        Get.to(UsersScreen());
                      },
                    ),
                ],
              ),
              SizedBox(height: 40),
              MaterialButton(
                onPressed: () {
                  signOutGoogle();

                  VxToast.show(context,
                      msg: "Logout Sucessfully", bgColor: Colors.red);
                  Get.offAll(LoginPage(title: 'Smart Business Solutions'));
                  // Get.bottomSheet(Container(
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(30.0),
                  //     child: Center(
                  //       child: Text("Logout Sucessful"),
                  //     ),
                  //   ),
                  //   color: Colors.white,
                  // ));
                },
                color: Colors.deepPurple,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.grey.shade800,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (i) {
        print(i);
        if (i == 1) Get.to(LoadCSVScreen());
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_chart),
          label: "Upload Data",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: "History",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          // _userStream(),
          //_buildHeader(),
          Text(
            "${DateFormat(DateFormat.YEAR_MONTH_DAY).format(DateTime.now()).toString()}   Location: ${user.location}",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.0,
          ),
          Card(
            elevation: 4.0,
            color: Colors.white,
            margin: const EdgeInsets.all(5.0),
            child: Column(
              children: <Widget>[
                if (mobileNumberData != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      "Available Numbers: ${mobileNumberData.length}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.blue),
                    ),
                  ),
                if (mobileNumberData.length == 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      "Please refresh data to get new numbers",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.red),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    "Total Numbers Dailed: ${callsaccepted + callsCallBack + callsNotAns + callsNotIntreseted}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.blueGrey),
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Leads:$callsaccepted",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.green),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Call Back:$callsCallBack",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.orange),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          "No Ans:$callsNotAns",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.cyan),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          "NI:$callsNotIntreseted",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.red),
                        ),
                      ),
                    ]),
              ],
            ),
          ),
          Card(
            elevation: 4.0,
            color: Colors.white,
            margin: const EdgeInsets.all(5.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: StreamBuilder<int>(
                    stream: _stopWatchTimer.rawTime,
                    initialData: _stopWatchTimer.rawTime.value,
                    builder: (context, snap) {
                      final value = snap.data;
                      final displayTime =
                          StopWatchTimer.getDisplayTime(value, hours: _isHours);
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              "Time Logging",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.blue),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              displayTime,
                              style: const TextStyle(
                                  fontSize: 40,
                                  fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Card(
            elevation: 4.0,
            color: Colors.white,
            margin: const EdgeInsets.all(5.0),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (startDay)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: MaterialButton(
                        padding: const EdgeInsets.all(4),
                        color: Colors.lightBlue,
                        shape: const StadiumBorder(),
                        onPressed: () async {
                          _startDate();
                          setState(() {
                            takeBreak = true;
                            endDay = false;
                            startDay = false;
                            backToWork = false;
                            timerCall = true;
                          });
                          _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                        },
                        child: const Text(
                          'Start Day',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  if (backToWork)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: MaterialButton(
                        padding: const EdgeInsets.all(4),
                        color: Colors.lightBlue,
                        shape: const StadiumBorder(),
                        onPressed: () async {
                          setState(() {
                            takeBreak = true;
                            endDay = false;
                            startDay = false;
                            backToWork = false;
                            timerCall = true;
                          });
                          _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                        },
                        child: const Text(
                          'Back to work',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  if (takeBreak)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: MaterialButton(
                        padding: const EdgeInsets.all(4),
                        color: Colors.green,
                        shape: const StadiumBorder(),
                        onPressed: () async {
                          setState(() {
                            takeBreak = false;
                            endDay = true;
                            startDay = false;
                            backToWork = true;
                            timerCall = false;
                            callBackDate = false;
                            customerAnswer = false;
                          });
                          sharedPreferences.setInt(
                              "currentTimer", _stopWatchTimer.secondTime.value);
                          _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                        },
                        child: const Text(
                          'Take break',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  if (endDay)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: MaterialButton(
                        padding: const EdgeInsets.all(4),
                        color: Colors.red,
                        shape: const StadiumBorder(),
                        onPressed: () async {
                          EasyLoading.show(
                              status: 'loading...',
                              maskType: EasyLoadingMaskType.black);
                          print(numbersPulled);
                          if (mobileNumberData != null)
                            numbersPulled =
                                numbersPulled - mobileNumberData.length;
                          print(numbersPulled);
                          updateNumbersPulled();
                          FirebaseUtility().timeLogging(
                              user.uid,
                              timer,
                              callsaccepted,
                              callsCallBack,
                              callsNotAns,
                              numbersPulled,
                              callsNotIntreseted);
                          setState(() {
                            takeBreak = false;
                            endDay = false;
                            startDay = true;
                            backToWork = false;
                            customerAnswer = false;
                            timerCall = false;
                            customerDataForm = false;
                          });
                          _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                          getPref();
                          updateCallsNotIntresetedToDB();
                          EasyLoading.dismiss();
                        },
                        child: const Text(
                          'End Day',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!Responsive.isDesktop(context) &&
              mobileNumberData != null &&
              mobileNumberData.length > 0)
            if (timerCall)
              Card(
                elevation: 4.0,
                color: Colors.white,
                margin: const EdgeInsets.all(5.0),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Form(
                      autovalidateMode: AutovalidateMode.always,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Next call in",
                            style: whiteText.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Colors.black),
                          ),
                          CircularCountDownTimer(
                            duration: 5,
                            initialDuration: 0,
                            controller: CountDownController(),
                            width: MediaQuery.of(context).size.width / 6,
                            height: MediaQuery.of(context).size.height / 6,
                            ringColor: Colors.grey[300],
                            ringGradient: null,
                            fillColor: Colors.purpleAccent[100],
                            fillGradient: null,
                            backgroundColor: Colors.purple[500],
                            backgroundGradient: null,
                            strokeWidth: 5.0,
                            strokeCap: StrokeCap.round,
                            textStyle: TextStyle(
                                fontSize: 25.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textFormat: CountdownTextFormat.S,
                            isReverse: false,
                            isReverseAnimation: false,
                            isTimerTextShown: true,
                            autoStart: true,
                            onStart: () {},
                            onComplete: () {
                              setState(() {
                                customerAnswer = true;
                                timerCall = false;
                              });
                              _callNumber(mobileNumberData.first);
                              currentMobileNumber = mobileNumberData.first;
                              customerData.phoneNumber = currentMobileNumber;
                              _removenumber(mobileNumberData.first);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          if (!Responsive.isDesktop(context) && customerAnswer)
            Form(
              key: _formKey,
              autovalidateMode: _autoValidateMode,
              child: Card(
                elevation: 4.0,
                color: Colors.white,
                margin: const EdgeInsets.all(5.0),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        if (customerAnswer)
                          DropdownButtonFormField(
                            //value: customerData.bank,
                            items: [
                              DropdownMenuItem(
                                child: Text("Yes"),
                                value: "Yes",
                              ),
                              DropdownMenuItem(
                                child: Text("No Ans"),
                                value: "No Ans",
                              ),
                              DropdownMenuItem(
                                child: Text("Call Back"),
                                value: "Call Back",
                              ),
                              DropdownMenuItem(
                                child: Text("NI"),
                                value: "NI",
                              ),
                            ],
                            onChanged: (value) {
                              //print(value);
                              setState(() {
                                _customerCallOption = value;
                              });
                              if (value == 'No Ans')
                                setState(() {
                                  callBackDate = false;
                                  customerDataForm = false;
                                });
                              else if (value == 'Yes') {
                                setState(() {
                                  customerDataForm = true;
                                  callBackDate = false;
                                });
                              } else if (value == 'NI')
                                setState(() {
                                  callBackDate = false;
                                  customerDataForm = false;
                                });
                              else if (value == 'Call Back') {
                                callBackDate = true;
                                customerDataForm = false;
                              }
                            },
                            decoration: InputDecoration(
                              filled: true,
                              icon: const Icon(Icons.question_answer),
                              hintText: "Did Customer answered call?",
                              labelText: "Did Customer answered call? *",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return "Required *";
                              else
                                return null;
                            },
                          ),
                        SizedBox(height: 10.0),
                        if (callBackDate)
                          DateTimeFormField(
                            validator: (value) {
                              if (value == null || value.toString().isEmpty)
                                return "Required *";
                              else
                                return null;
                            },
                            firstDate: DateTime.now(),
                            //errorText: "Required",
                            mode: DateTimeFieldPickerMode.date,
                            decoration: InputDecoration(
                              filled: true,
                              icon: const Icon(Icons.date_range),
                              hintText: "Call Back Date",
                              labelText: "Call Back Date",
                            ),
                            //label: "Date of birth",
                            initialDatePickerMode: DatePickerMode.day,
                            onDateSelected: (DateTime value) {
                              setState(() {
                                callBackDateValue =
                                    DateFormat('dd-MM-yyyy').format(value);
                              });
                            },
                          ),
                        if (customerDataForm)
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                sizedBoxSpace,
                                DropdownButtonFormField(
                                  //value: customerData.bank,
                                  items: ['HDFC', 'ICICI', 'Other']
                                      .map((String item) =>
                                          DropdownMenuItem<String>(
                                              child: Text(item), value: item))
                                      .toList(),
                                  onChanged: (value) {
                                    //print(value);
                                    //customerData.bank = value.toString();
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    icon: const Icon(Icons.merge_type),
                                    hintText: "Bank",
                                    labelText: "Bank *",
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return "Bank is required";
                                    else
                                      return null;
                                  },
                                ),
                                sizedBoxSpace,
                                TextFormField(
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    filled: true,
                                    icon: const Icon(Icons.person),
                                    hintText: "What do people call you?",
                                    labelText: "Customer Name *",
                                  ),
                                  onChanged: (value) {
                                    customerData.customerName = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return "Enter customer name";
                                    else
                                      return null;
                                  },
                                ),
                                sizedBoxSpace,
                                DateTimeFormField(
                                  validator: (value) {
                                    if (value == null ||
                                        value.toString().isEmpty)
                                      return "Required *";
                                    else
                                      return null;
                                  },
                                  firstDate: DateTime.now(),
                                  //errorText: "Required",
                                  mode: DateTimeFieldPickerMode.date,
                                  decoration: InputDecoration(
                                    filled: true,
                                    icon: const Icon(Icons.date_range),
                                    hintText: "Call Back Date",
                                    labelText: "Call Back Date",
                                  ),
                                  //label: "Date of birth",
                                  initialDatePickerMode: DatePickerMode.day,
                                  onDateSelected: (DateTime value) {
                                    setState(() {
                                      customerData.callBackDate =
                                          DateFormat('dd-MM-yyyy')
                                              .format(value);
                                    });
                                  },
                                ),
                                sizedBoxSpace,
                                TextFormField(
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    filled: true,
                                    icon: const Icon(Icons.location_city),
                                    hintText: "What do you live?",
                                    labelText: "Location *",
                                  ),
                                  onChanged: (value) {
                                    customerData.location = value;
                                  },
                                  // validator: (value) {
                                  //   if (value == null || value.isEmpty)
                                  //     return "Enter customer location";
                                  //   else
                                  //     return null;
                                  // },
                                ),
                                sizedBoxSpace,
                                TextFormField(
                                  readOnly: true,
                                  initialValue: currentMobileNumber,
                                  decoration: InputDecoration(
                                    filled: true,
                                    icon: const Icon(Icons.phone),
                                    hintText: "Where we can reach you?",
                                    labelText: "Phone Number",
                                    prefixText: '+91 ',
                                  ),
                                  keyboardType: TextInputType.phone,
                                  onChanged: (value) {
                                    customerData.phoneNumber = value;
                                  },
                                  maxLength: 10,
                                  maxLengthEnforced: false,
                                  validator: (value) {
                                    //print(value.length);
                                    if (value == null)
                                      return "Enter customer phone number";
                                    else if (value.length == 10)
                                      return null;
                                    else
                                      return "Enter valid phone number";
                                  },
                                  // TextInputFormatters are applied in sequence.
                                ),
                                sizedBoxSpace,
                                TextFormField(
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: true, decimal: true),
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: "Gross Salary",
                                    suffixText: "₹",
                                  ),
                                  maxLines: 1,
                                  onChanged: (value) {
                                    customerData.grossSalary = value;
                                  },
                                  //validator: _validateSalary,
                                ),
                                sizedBoxSpace,
                                TextFormField(
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: true, decimal: true),
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: "Net Salary",
                                    suffixText: "₹",
                                  ),
                                  maxLines: 1,
                                  onChanged: (value) {
                                    customerData.netSalary = value;
                                  },
                                  // validator: _validateSalary,
                                ),
                                sizedBoxSpace,
                                TextFormField(
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: true, decimal: true),
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: "Required amount",
                                    suffixText: "₹",
                                  ),
                                  maxLines: 1,
                                  onChanged: (value) {
                                    customerData.appliedAmount = value;
                                  },
                                  //validator: _validateSalary,
                                ),
                                sizedBoxSpace,
                                TextFormField(
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: true, decimal: true),
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: "Approved amount",
                                    suffixText: "₹",
                                  ),
                                  maxLines: 1,
                                  onChanged: (value) {
                                    customerData.approvedAmount = value;
                                  },
                                  //validator: _validateSalary,
                                ),
                                sizedBoxSpace,
                                TextFormField(
                                  readOnly: true,
                                  initialValue: user.displayName,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    filled: true,
                                    icon: const Icon(Icons.perm_identity_sharp),
                                    hintText: "Who reached customer?",
                                    labelText: "Caller Name",
                                  ),
                                  onChanged: (value) {
                                    customerData.caller = user.displayName;
                                  },
                                  validator: _validateName,
                                ),
                                sizedBoxSpace,
                                TextFormField(
                                  maxLines: 5,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    filled: true,
                                    icon: const Icon(Icons.perm_identity_sharp),
                                    hintText:
                                        "When documents will be provided?",
                                    labelText: "Comments!!",
                                  ),
                                  onChanged: (value) {
                                    customerData.comments = value;
                                  },
                                  //validator: _validateName,
                                ),
                              ]),
                        sizedBoxSpace,
                        Center(
                          child: MaterialButton(
                            onPressed: () {
                              _updateCallsNotAns();
                              if (_customerCallOption == 'No Ans') {
                                setState(() {
                                  callsNotAns = callsNotAns + 1;

                                  timerCall = true;
                                  customerAnswer = false;
                                  callBackDate = false;
                                  customerDataForm = false;
                                });
                                updateCallsNotAns();
                              } else if (_customerCallOption == 'Yes') {
                                setState(() {
                                  callsaccepted = callsaccepted + 1;

                                  callBackDate = false;
                                  customerDataForm = false;
                                  timerCall = true;
                                  customerAnswer = false;
                                });
                                updateCallsAccepted();
                                customerData.uid = user.uid;
                                customerData.createdDate = getDate();
                                customerData.caller = user.displayName;
                                _handleSubmitted();
                              } else if (_customerCallOption == 'NI') {
                                setState(() {
                                  callsNotIntreseted = callsNotIntreseted + 1;
                                  timerCall = true;
                                  customerAnswer = false;
                                  callBackDate = false;
                                  customerDataForm = false;
                                });
                                updateCallsNotIntreseted();
                              } else if (_customerCallOption == 'Call Back') {
                                _updateCallBackNumber(callBackDateValue);
                                setState(() {
                                  timerCall = true;
                                  customerAnswer = false;
                                  callBackDate = false;
                                  callsCallBack = callsCallBack + 1;
                                  customerDataForm = false;
                                });
                                updateCallsCallBack();
                              }
                            },
                            color: Colors.deepPurple,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
                              ),
                            ),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                          ),
                        ),
                        sizedBoxSpace,
                        Text(
                          "* Required fields",
                          style: Theme.of(context).textTheme.caption,
                        ),
                        sizedBoxSpace,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Container _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 50.0, 0, 32.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
        color: Colors.blue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(
              user != null && user.displayName != null
                  ? "Welcome  ${user.displayName}"
                  : "",
              style: whiteText.copyWith(
                  fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            trailing: IconButton(
              iconSize: 32.0,
              icon: const Icon(Icons.logout),
              tooltip: "Logout",
              onPressed: () {
                signOutGoogle();
                VxToast.show(context,
                    msg: "Logout Sucessfully", bgColor: Colors.red);
                Get.offAll(LoginPage(title: 'Smart Business Solutions'));
              },
            ),
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              user != null && user.email != null ? user.email : "",
              style: whiteText.copyWith(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 5.0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              user != null && user.userRole != null ? user.userRole : "",
              style: whiteText,
            ),
          ),
          const SizedBox(height: 5.0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              "${DateFormat(DateFormat.YEAR_MONTH_DAY).format(DateTime.now()).toString()}",
              style: whiteText.copyWith(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildTile(
      {Color color, IconData icon, String title, String data}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 150.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Icon(
            icon,
            color: Colors.white,
          ),
          Text(
            title,
            style: whiteText.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            data,
            style:
                whiteText.copyWith(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
        ],
      ),
    );
  }
}

_showVersionDialog(context) async {
  await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      String title = "New Update Available";
      String message =
          "There is a newer version of app available please update it now.";
      String btnLabel = "Update Now";
      String btnLabelCancel = "Later";
      return Platform.isIOS
          ? new CupertinoAlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                MaterialButton(
                  child: Text(btnLabel),
                  onPressed: () => _launchURL("APP_STORE_URL"),
                ),
                MaterialButton(
                  child: Text(btnLabelCancel),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            )
          : WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: new AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  MaterialButton(
                    child: Text(btnLabel),
                    onPressed: () => _launchURL(
                        "https://appdistribution.firebase.dev/i/3732d17391e6b3ca"),
                  ),
                ],
              ),
            );
    },
  );
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void alertDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          title: Text("No Internet connection !!!"),
        ),
      );
    },
  );
}
