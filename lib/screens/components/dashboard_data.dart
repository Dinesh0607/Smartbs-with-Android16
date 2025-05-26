import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:smartbs/base/img.dart';
import 'package:smartbs/base/my_text.dart';
import 'package:smartbs/models/userInfoTable.dart';
import 'package:intl/intl.dart';
import 'package:smartbs/utils/firebase_utility.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import '../../../constants.dart';
import '../../responsive.dart';
import '../load_csv_screen.dart';
import 'my_colors.dart';

class DashboardData extends StatefulWidget {
  const DashboardData({Key key, @required this.data}) : super(key: key);

  final UserInfoTable data;

  @override
  _DashboardDataState createState() => _DashboardDataState();
}

class _DashboardDataState extends State<DashboardData> {
  Future<DateTime> selectedDate;
  String date;
  String filterValue;

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            showDialogPicker(context);
            setState(() {});
          },
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 45,
            color: Colors.grey[300],
            child: Text(
              "Filter by Date: " +
                  (date != null
                      ? date
                      : DateFormat('dd-MM-yyyy').format(DateTime.now())),
              style: MyText.title(context),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton(
              value: filterValue != null ? filterValue : "Today",
              items: ["Today", "Week to Date", "Month to Date"]
                  .map((String item) =>
                      DropdownMenuItem<String>(child: Text(item), value: item))
                  .toList(),
              onChanged: (value) {
                //print(value);
                //customerData.bank = value.toString();
                setFilterType(value);
                setState(() {
                  filterValue = value;
                });
                EasyLoading.show(
                    status: 'loading...', maskType: EasyLoadingMaskType.black);
              },
            ),
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical:
                      defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                ),
              ),
              onPressed: () => Get.to(LoadCSVScreen()),
              icon: Icon(Icons.upload),
              label: Text("Upload Data"),
            ),
          ],
        ),

        SizedBox(height: defaultPadding),
        Row(
          children: <Widget>[
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2)),
                color: Colors.white,
                elevation: 2,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.lightGreen[500],
                        child: Icon(
                          Icons.event_available,
                          color: Colors.white,
                        ),
                      ),
                      Container(width: 10),
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            EasyLoading.show(
                                status: 'loading...',
                                maskType: EasyLoadingMaskType.black);
                            showDialog(
                                context: context,
                                builder: (_) => NumberDataDialog());
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.data.numbersAvailable.toString(),
                                style: MyText.subhead(context).copyWith(
                                    color: MyColors.grey_60,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              Container(height: 5),
                              Text(
                                "Numbers Available",
                                overflow: TextOverflow.fade,
                                style: MyText.caption(context)
                                    .copyWith(color: MyColors.grey_40),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(width: 5),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2)),
                color: Colors.white,
                elevation: 2,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.indigo[400],
                        child: Icon(
                          Icons.leaderboard_sharp,
                          color: Colors.white,
                        ),
                      ),
                      Container(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.data.leads.toString(),
                            style: MyText.subhead(context).copyWith(
                                color: MyColors.grey_60,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Container(height: 5),
                          Text(
                            "Leads",
                            style: MyText.caption(context)
                                .copyWith(color: MyColors.grey_40),
                            textAlign: TextAlign.center,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(height: 5),
        Row(
          children: <Widget>[
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2)),
                color: Colors.white,
                elevation: 2,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.red[300],
                        child: Icon(
                          Icons.call_missed,
                          color: Colors.white,
                        ),
                      ),
                      Container(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.data.callBacks.toString(),
                            style: MyText.subhead(context).copyWith(
                                color: MyColors.grey_60,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Container(height: 5),
                          Text(
                            "Call Backs",
                            style: MyText.caption(context)
                                .copyWith(color: MyColors.grey_40),
                            textAlign: TextAlign.center,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(width: 5),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2)),
                color: Colors.white,
                elevation: 2,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.lightGreen[500],
                        child: Icon(
                          Icons.question_answer_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Container(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.data.numbersDailed.toString(),
                            style: MyText.subhead(context).copyWith(
                                color: MyColors.grey_60,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Container(height: 5),
                          Text(
                            "Total Calls",
                            style: MyText.caption(context)
                                .copyWith(color: MyColors.grey_40),
                            textAlign: TextAlign.center,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // Responsive(
        //   mobile: FileInfoCardGridView(
        //     crossAxisCount: _size.width < 650 ? 2 : 4,
        //     childAspectRatio: _size.width < 650 ? 1.3 : 1,
        //   ),
        //   tablet: FileInfoCardGridView(),
        //   desktop: FileInfoCardGridView(
        //     childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
        //   ),
        // ),
      ],
    );
  }

  void showDialogPicker(BuildContext context) {
    selectedDate = showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      },
    );
    selectedDate.then((value) {
      EasyLoading.show(
          status: 'loading...', maskType: EasyLoadingMaskType.black);
      if (value == null) return;
      date = getFormattedDateSimple(value.millisecondsSinceEpoch);
      setFilterDate(date);
    }, onError: (error) {
      print(error);
    });
  }

  String getFormattedDateSimple(int time) {
    DateFormat newFormat = new DateFormat('dd-MM-yyyy');
    return newFormat.format(new DateTime.fromMillisecondsSinceEpoch(time));
  }

  void setFilterDate(String date) {
    filterValue = 'Today';
    setData("filterDate", date);
  }

  void setFilterType(String value) {
    setData("filterByType", value);
  }

  void setData(String name, String data) async {
    final preferences = await StreamingSharedPreferences.instance;
    preferences.setString(name, data);
  }
}

class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({
    Key key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => _getCard(context),
    );
  }

  Expanded _getCard(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        color: Colors.white,
        elevation: 2,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.red[300],
                child: Icon(
                  Icons.shopping_basket,
                  color: Colors.white,
                ),
              ),
              Container(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "4000+",
                    style: MyText.subhead(context).copyWith(
                        color: MyColors.grey_60, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Container(height: 5),
                  Text(
                    "Products",
                    style: MyText.caption(context)
                        .copyWith(color: MyColors.grey_40),
                    textAlign: TextAlign.center,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NumberDataDialog extends StatefulWidget {
  NumberDataDialog({Key key}) : super(key: key);

  @override
  NumberDataDialogState createState() => new NumberDataDialogState();
}

class NumberDataDialogState extends State<NumberDataDialog> {
  int nellore1 = 0;
  int nellore2 = 0;
  int nellore3 = 0;
  int naidupeta = 0;
  int tirupathi1 = 0;
  int tirupathi2 = 0;
  int others = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getPerf();
  }

  Future<void> getPerf() async {
    nellore1 =
        await FirebaseUtility().getAvailableNumberCountByLocation("Nellore-1");
    nellore2 =
        await FirebaseUtility().getAvailableNumberCountByLocation("Nellore-2");
    nellore3 =
        await FirebaseUtility().getAvailableNumberCountByLocation("Nellore-3");
    naidupeta =
        await FirebaseUtility().getAvailableNumberCountByLocation("Naidupeta");
    tirupathi1 =
        await FirebaseUtility().getAvailableNumberCountByLocation("Tirupati-1");
    tirupathi2 =
        await FirebaseUtility().getAvailableNumberCountByLocation("Tirupati-2");
    others =
        await FirebaseUtility().getAvailableNumberCountByLocation("Others");
    setState(() {});
    EasyLoading.dismiss();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 160,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          color: Colors.white,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Wrap(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    child: Column(children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Image.asset(
                            Img.get('image_27.jpg'),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 150,
                          ),
                          Container(
                            height: 150,
                            color: Colors.purple[900].withOpacity(0.5),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 30),
                            alignment: Alignment.topCenter,
                            child: Text("Everything looks good today !",
                                style: MyText.headline(context)
                                    .copyWith(color: Colors.white)),
                          ),
                        ],
                      )
                    ]),
                  ),
                  Container(
                    alignment: Alignment.center,
                    transform: Matrix4.translationValues(0.0, 80.0, 0.0),
                    child: Image.asset(
                      Img.get('badge_ontime.png'),
                      fit: BoxFit.cover,
                      height: 120,
                      width: 120,
                    ),
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 60,
                    ),
                    Container(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text("Nellore-1 : $nellore1",
                                style: MyText.subhead(context)
                                    .copyWith(color: Colors.purple[900])),
                            nellore1 > 0
                                ? new Icon(
                                    Icons.check,
                                    color: Colors.green[900],
                                  )
                                : new Icon(
                                    Icons.cancel,
                                    color: Colors.red[900],
                                  ),
                          ],
                        )),
                    Container(
                      height: 15,
                    ),
                    Container(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text("Nellore-2 : $nellore2",
                                style: MyText.subhead(context)
                                    .copyWith(color: Colors.purple[900])),
                            nellore2 > 0
                                ? new Icon(
                                    Icons.check,
                                    color: Colors.green[900],
                                  )
                                : new Icon(
                                    Icons.cancel,
                                    color: Colors.red[900],
                                  ),
                          ],
                        )),
                    Container(
                      height: 15,
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text("Nellore-3 : $nellore3",
                              style: MyText.subhead(context)
                                  .copyWith(color: Colors.purple[900])),
                          nellore3 > 0
                              ? new Icon(
                                  Icons.check,
                                  color: Colors.green[900],
                                )
                              : new Icon(
                                  Icons.cancel,
                                  color: Colors.red[900],
                                ),
                        ],
                      ),
                    ),
                    Container(
                      height: 15,
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text("Naidupeta : $naidupeta",
                              style: MyText.subhead(context)
                                  .copyWith(color: Colors.purple[900])),
                          naidupeta > 0
                              ? new Icon(
                                  Icons.check,
                                  color: Colors.green[900],
                                )
                              : new Icon(
                                  Icons.cancel,
                                  color: Colors.red[900],
                                ),
                        ],
                      ),
                    ),
                    Container(
                      height: 15,
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text("Tirupati-1 : $tirupathi1",
                              style: MyText.subhead(context)
                                  .copyWith(color: Colors.purple[900])),
                          tirupathi1 > 0
                              ? new Icon(
                                  Icons.check,
                                  color: Colors.green[900],
                                )
                              : new Icon(
                                  Icons.cancel,
                                  color: Colors.red[900],
                                ),
                        ],
                      ),
                    ),
                    Container(
                      height: 15,
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text("Tirupati-2 : $tirupathi2",
                              style: MyText.subhead(context)
                                  .copyWith(color: Colors.purple[900])),
                          tirupathi2 > 0
                              ? new Icon(
                                  Icons.check,
                                  color: Colors.green[900],
                                )
                              : new Icon(
                                  Icons.cancel,
                                  color: Colors.red[900],
                                ),
                        ],
                      ),
                    ),
                    Container(
                      height: 15,
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text("Others : $others",
                              style: MyText.subhead(context)
                                  .copyWith(color: Colors.purple[900])),
                          others > 0
                              ? new Icon(
                                  Icons.check,
                                  color: Colors.green[900],
                                )
                              : new Icon(
                                  Icons.cancel,
                                  color: Colors.red[900],
                                ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(LoadCSVScreen());
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                            top: 30, bottom: 15, left: 3, right: 3),
                        height: 55,
                        alignment: Alignment.center,
                        width: double.infinity,
                        color: Colors.purple[900],
                        child: Text("Upload Data",
                            style: MyText.subhead(context)
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
