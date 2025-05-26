import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbs/base/my_text.dart';
import 'package:smartbs/models/user_model.dart';
import 'package:smartbs/screens/components/my_colors.dart';
import 'package:smartbs/utils/firebase_utility.dart';

import '../../responsive.dart';

class CallBackScreen extends StatefulWidget {
  @override
  _CallBackScreenState createState() => _CallBackScreenState();
}

class _CallBackScreenState extends State<CallBackScreen> {
  SharedPreferences sharedPreferences;
  List<String> callbackNumbers = [];
  UserModel user;
  String datefilter;
  @override
  void initState() {
    super.initState();
    getPerf(null);
  }

  Future<void> getPerf(String date) async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (date == null)
      callbackNumbers = sharedPreferences
          .getStringList(FirebaseUtility().getDate() + "callbacknumbers");
    else
      callbackNumbers =
          sharedPreferences.getStringList(date + "callbacknumbers");

    setState(() {});
  }

  _callNumber(String phoneNumber) async {
    String number = phoneNumber;
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Responsive.isMobile(context)
          ? AppBar(
              title: Center(child: Text("Call Backs       ")),
            )
          : null,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(onPrimary: Colors.blue[700]),
              child: Text(
                  datefilter != null
                      ? datefilter
                      : "${DateFormat(DateFormat.YEAR_MONTH_DAY).format(DateTime.now()).toString()}",
                  style: TextStyle(color: Colors.white)),
              onPressed: () async {
                final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2021, 1, 1),
                    lastDate: DateTime(2025, 1, 1),
                    builder: (BuildContext context, Widget child) {
                      return Theme(
                          data: ThemeData(
                              primaryColor: Colors.black,
                              accentColor: Colors.black54,
                              buttonBarTheme: ButtonBarThemeData(
                                buttonTextTheme: ButtonTextTheme.accent,
                              )),
                          child: child);
                    });
                if (date != null) {
                  var formatter = new DateFormat('dd-MM-yyyy');
                  datefilter = DateFormat(DateFormat.YEAR_MONTH_DAY)
                      .format(date)
                      .toString();
                  getPerf(formatter.format(date));
                }
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount:
                    callbackNumbers != null && callbackNumbers.length != null
                        ? callbackNumbers.length
                        : 0,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Container(
                        child: InkWell(
                            onTap: () {
                              _callNumber(callbackNumbers[index]);
                            },
                            child: Icon(Icons.call, color: MyColors.primary)),
                        width: 35,
                        height: 35),
                    key: PageStorageKey<int>(index),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(callbackNumbers[index],
                            style: MyText.subhead(context).copyWith(
                                color: MyColors.grey_90,
                                fontWeight: FontWeight.bold)),
                        Container(height: 2),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
