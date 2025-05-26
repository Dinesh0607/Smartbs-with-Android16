import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbs/base/img.dart';
import 'package:smartbs/base/my_text.dart';
import 'package:smartbs/models/time_card.dart';
import 'package:smartbs/models/user_model.dart';
import 'package:smartbs/screens/components/my_colors.dart';
import 'package:smartbs/utils/app_strings.dart';
import 'package:smartbs/utils/firebase_utility.dart';

class ProfilePolygonRoute extends StatefulWidget {
  ProfilePolygonRoute();

  @override
  ProfilePolygonRouteState createState() => new ProfilePolygonRouteState();
}

class ProfilePolygonRouteState extends State<ProfilePolygonRoute> {
  SharedPreferences sharedPreferences;
  UserModel user;
  TimeCard timecard;
  int totalNumbers = 0;
  int totalCallBack = 0;
  int totalLeads = 0;
  int totalNI = 0;
  int totalNotAns = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPerf();
  }

  getPerf() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (mounted)
      user = UserModel.fromJson(
          jsonDecode(sharedPreferences.getString(AppStrings.USER_PREF_KEY)));
    timecard = await FirebaseUtility().getUserLogging(user.uid);
    for (var timeLogging in timecard.timeLogging) {
      totalCallBack = totalCallBack + timeLogging.callsCallBack;
      totalLeads = totalLeads + timeLogging.callsaccepted;
      totalNI = totalNI + timeLogging.callsNotIntreseted;
      totalNotAns = totalNotAns + timeLogging.callsNotAns;
      totalNumbers = totalNumbers +
          timeLogging.callsCallBack +
          timeLogging.callsNotIntreseted +
          timeLogging.callsaccepted +
          timeLogging.callsNotAns;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: user != null
          ? NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.asset(Img.get('bg_polygon.png'),
                          fit: BoxFit.cover),
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(50),
                      child: Container(
                        transform: Matrix4.translationValues(0, 50, 0),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          child: CircleAvatar(
                            radius: 48,
                            backgroundImage: NetworkImage(user.photoURL),
                          ),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      Container(height: 70),
                      Text(user.displayName,
                          style: MyText.headline(context).copyWith(
                              color: Colors.grey[900],
                              fontWeight: FontWeight.bold)),
                      Container(height: 15),
                      Text(user.email,
                          textAlign: TextAlign.center,
                          style: MyText.subhead(context)
                              .copyWith(color: Colors.grey[900])),
                      Container(height: 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            primary: MyColors.accent),
                        child: Text("Logout",
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {},
                      ),
                      Container(height: 35),
                      Divider(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: <Widget>[
                                Text(totalLeads.toString(),
                                    style: MyText.title(context).copyWith(
                                        color: Colors.grey[900],
                                        fontWeight: FontWeight.bold)),
                                Container(height: 5),
                                Text("Leads",
                                    style: MyText.subhead(context)
                                        .copyWith(color: Colors.grey[600]))
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: <Widget>[
                                Text(totalCallBack.toString(),
                                    style: MyText.title(context).copyWith(
                                        color: Colors.grey[900],
                                        fontWeight: FontWeight.bold)),
                                Container(height: 5),
                                Text("Call Backs",
                                    style: MyText.subhead(context)
                                        .copyWith(color: Colors.grey[600]))
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: <Widget>[
                                Text(totalNumbers.toString(),
                                    style: MyText.title(context).copyWith(
                                        color: Colors.grey[900],
                                        fontWeight: FontWeight.bold)),
                                Container(height: 5),
                                Text("Total Calls",
                                    style: MyText.subhead(context)
                                        .copyWith(color: Colors.grey[600]))
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(height: 35),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: <Widget>[
                                Text(totalNI.toString(),
                                    style: MyText.title(context).copyWith(
                                        color: Colors.grey[900],
                                        fontWeight: FontWeight.bold)),
                                Container(height: 5),
                                Text("NI",
                                    style: MyText.subhead(context)
                                        .copyWith(color: Colors.grey[600]))
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: <Widget>[
                                Text(totalNotAns.toString(),
                                    style: MyText.title(context).copyWith(
                                        color: Colors.grey[900],
                                        fontWeight: FontWeight.bold)),
                                Container(height: 5),
                                Text("Not Answered",
                                    style: MyText.subhead(context)
                                        .copyWith(color: Colors.grey[600]))
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(height: 35),
                    ],
                  ),
                ),
              ),
            )
          : Container(
              height: 0.0,
            ),
    );
  }
}
