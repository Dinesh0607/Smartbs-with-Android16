import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartbs/utils/firebase_utility.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../responsive.dart';

class AdminManageData extends StatefulWidget {
  AdminManageData();

  @override
  AdminManageDataState createState() => new AdminManageDataState();
}

class AdminManageDataState extends State<AdminManageData> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(child: Text("Data Managing       ")),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(0),
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 50,
              child: InkWell(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Text("Remove Number Data",
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                onTap: () {
                  confirmationDialog(context);
                },
              ),
            ),
            Container(
              width: double.infinity,
              height: 50,
              child: InkWell(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Text("Remove All Number Data",
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                onTap: () {
                  deleteAllNumberData(context);
                },
              ),
            ),
            Divider(color: Colors.grey[200], height: 0, thickness: 0.5),
            Container(
              width: double.infinity,
              height: 50,
              child: InkWell(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Text("Download not answered data",
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                onTap: () {
                  confirmationDialogToMakeNotAnsDataActive(context);
                },
              ),
            ),
            Divider(color: Colors.grey[200], height: 0, thickness: 0.5),
            Container(
              width: double.infinity,
              height: 50,
              child: InkWell(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Text("Make Number Data Active",
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                onTap: () {
                  //confirmationDialog(context);
                },
              ),
            ),
            Divider(color: Colors.grey[200], height: 0, thickness: 0.5),
            Divider(color: Colors.grey[200], height: 0, thickness: 0.5),
          ],
        ),
      ),
    );
  }

  void confirmationDialog(BuildContext context) async {
    String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter mystate) {
          return AlertDialog(
            title: Text("Are you sure you want to remove data?"),
            content: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: DateTimeField(
                selectedDate: DateFormat("dd-MM-yyyy").parse(date),
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
                  date = DateFormat('dd-MM-yyyy').format(value);
                  mystate(() {});
                },
              ),
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
                  FirebaseUtility().removeNumberDataByDate(date);
                  VxToast.show(context,
                      msg: "Number Data Deleted : " + date,
                      bgColor: Colors.red);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
      },
    );
  }

  void deleteAllNumberData(BuildContext context) async {
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
            title: Text("Are you sure you want to remove data?"),
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
                  FirebaseUtility()
                      .removeNumberDataByLocation(selectedLocation);
                  VxToast.show(context,
                      msg: "All Number Data Deleted : " + selectedLocation,
                      bgColor: Colors.red);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
      },
    );
  }

  _generateRepot(List<String> data) async {
    String csvData = ListToCsvConverter().convert(getReportStringList(data));
    final content = base64Encode(csvData.codeUnits);
    final url = 'data:application/csv;base64,$content';
    await launch(url);
    VxToast.show(context, msg: "Report downloaded", bgColor: Colors.green);
  }

  List<List<String>> getReportStringList(List<String> inputData) {
    List<List<String>> data = [];
    data.add(["Not Answered data"]);
    for (var number in inputData) {
      data.add([number.toString()]);
    }
    return data;
  }

  void confirmationDialogToMakeNotAnsDataActive(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter mystate) {
          return AlertDialog(
            title: Text("Download not answered data will be removed from DB"),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Okay'),
                onPressed: () async {
                  _generateRepot(await FirebaseUtility().getNotAnsData());
                  VxToast.show(context,
                      msg: "Not Ans Data Active : ", bgColor: Colors.green);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
      },
    );
  }

  void alertDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Discard draft ?"),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('DISCARD'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}

class SingleChoiceDialog extends StatefulWidget {
  SingleChoiceDialog({Key key}) : super(key: key);

  @override
  SingleChoiceDialogState createState() => new SingleChoiceDialogState();
}

class SingleChoiceDialogState extends State<SingleChoiceDialog> {
  String selectedRingtone = "None";
  List<String> ringtone = ["None", "Callisto", "Ganymede", "Luna"];

  @override
  Widget build(BuildContext context) {
    return new SimpleDialog(
      title: new Text("Phone Ringtone"),
      children: ringtone
          .map((r) => RadioListTile(
                title: Text(r),
                groupValue: selectedRingtone,
                selected: r == selectedRingtone,
                value: r,
                onChanged: (val) {
                  setState(() {
                    selectedRingtone = val;
                  });
                },
              ))
          .toList(),
    );
  }
}

class MultiChoiceDialog extends StatefulWidget {
  MultiChoiceDialog({Key key}) : super(key: key);

  @override
  MultiChoiceDialogState createState() => new MultiChoiceDialogState();
}

class MultiChoiceDialogState extends State<MultiChoiceDialog> {
  List<String> colors = ["Red", "Green", "Blue", "Purple", "Olive"];

  List<bool> status = [false, false, false, false, false];

  bool getValue(String val) {
    int index = colors.indexOf(val);
    if (index == -1) return false;
    return status[index];
  }

  void toggleValue(String name) {
    int index = colors.indexOf(name);
    if (index == -1) return;
    status[index] = !status[index];
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text("Your prefered color"),
      contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 0),
      content: Wrap(
        direction: Axis.vertical,
        children: colors
            .map((c) => InkWell(
                  child: Row(
                    children: <Widget>[
                      Checkbox(value: getValue(c), onChanged: (value) {}),
                      Text(c),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      toggleValue(c);
                    });
                  },
                ))
            .toList(),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
