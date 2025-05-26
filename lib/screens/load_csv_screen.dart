import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:smartbs/utils/firebase_utility.dart';
import 'package:velocity_x/velocity_x.dart';

class LoadCSVScreen extends StatefulWidget {
  @override
  _LoadCSVScreenState createState() => _LoadCSVScreenState();
}

class _LoadCSVScreenState extends State<LoadCSVScreen> {
  //String path;
  String location;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Load Data"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton(
              value: location,
              hint: Text('Location'),
              items: [
                "Nellore-1",
                "Nellore-2",
                "Nellore-3",
                "Naidupeta",
                "Tirupati-1",
                "Tirupati-2",
                "Others"
              ]
                  .map((String item) =>
                      DropdownMenuItem<String>(child: Text(item), value: item))
                  .toList(),
              onChanged: (value) {
                location = value;
                setState(() {});
              },
            ),
            MaterialButton(
              onPressed: location != null
                  ? () {
                      loadCsvFromStorage(context, location);
                    }
                  : null,
              color: Colors.cyanAccent,
              child: Text("Load xslx form phone storage"),
            ),
          ],
        ),
      ),
    );
  }
}

loadCsvFromStorage(BuildContext context, String location) async {
  FilePickerResult result = await FilePicker.platform.pickFiles(
    allowedExtensions: ['xlsx'],
    type: FileType.custom,
  );
  PlatformFile file = result.files.first;
  String path = result.files.first.path;

  Uint8List uploadfile = result.files.single.bytes;
  EasyLoading.show(status: 'loading...', maskType: EasyLoadingMaskType.black);
  //print(uploadfile);
  //loadingCsvData(path);
  var excel = Excel.decodeBytes(uploadfile);
  int size = 0;
  List<String> mobileNumbers = [];
  for (var table in excel.tables.keys) {
    for (int row = 0; row < excel.tables[table].maxRows; row++) {
      excel.tables[table].row(row).forEach((cell) {
        mobileNumbers.add(cell.value.toString());
        size = size + 1;
        if (mobileNumbers.length == 100) {
          FirebaseUtility().updateNumberData(mobileNumbers, location);
          mobileNumbers = [];
        }
        //  Value stored in the particular cell
      });
    }
    if (mobileNumbers.length > 0)
      FirebaseUtility().updateNumberData(mobileNumbers, location);
    EasyLoading.dismiss();
    VxToast.show(context,
        msg: "Numbers uploaded Sucessfully :  " + size.toString(),
        bgColor: Colors.green,
        showTime: 10000);
    Get.back();
  }
  // Navigator.of(context).push(
  //   MaterialPageRoute(
  //     builder: (_) {
  //       //return LoadCsvDataScreen(path: path);
  //     },
  //   ),
  // );
}

Future<List<List<dynamic>>> loadingCsvData(String path) async {
  final csvFile = new File(path).openRead();
  return await csvFile
      .transform(utf8.decoder)
      .transform(
        CsvToListConverter(),
      )
      .toList();
}
