import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smartbs/models/userInfoTable.dart';

import '../../../constants.dart';

class UserTableData extends StatelessWidget {
  const UserTableData({Key key, @required this.tableData}) : super(key: key);

  final List<UserInfoTable> tableData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tele Caller Data",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          SizedBox(
            width: double.infinity,
            child: DataTable2(
              minWidth: 600,
              columnSpacing: defaultPadding,
              columns: [
                DataColumn(
                  label: Text("User Name"),
                ),
                DataColumn(
                  label: Text("Time (HH:mm)"),
                ),
                DataColumn(
                  label: Text("Total Calls"),
                ),
                DataColumn(
                  label: Text("Leads"),
                ),
                DataColumn(
                  label: Text("Not Ans"),
                ),
                DataColumn(
                  label: Text("NI"),
                ),
                DataColumn(
                  label: Text("Call Back"),
                ),
                DataColumn(
                  label: Text("User Location"),
                ),
                DataColumn(
                  label: Text("Numbers Pulled"),
                ),
              ],
              rows: List.generate(
                tableData.length,
                (index) => recentFileDataRow(tableData[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

DataRow recentFileDataRow(UserInfoTable userInfoTable) {
  return DataRow(
    cells: [
      DataCell(
        Text(userInfoTable.userName),
      ),
      DataCell(
        Text(((userInfoTable.timeWorked / 60) / 60).truncate().toString() +
            ":" +
            (((userInfoTable.timeWorked / 60).truncate()) -
                    ((((userInfoTable.timeWorked / 60) / 60).truncate() * 60)))
                .toString()),
      ),
      DataCell(Text((userInfoTable.callBacks +
              userInfoTable.notIns +
              userInfoTable.notAns +
              userInfoTable.leads)
          .toString())),
      DataCell(Text(userInfoTable.leads.toString())),
      DataCell(Text(userInfoTable.notAns.toString())),
      DataCell(Text(userInfoTable.notIns.toString())),
      DataCell(Text(userInfoTable.callBacks.toString())),
      DataCell(Text(userInfoTable.location.toString())),
      DataCell(Text(userInfoTable.numbersPulled.toString())),
    ],
  );
}
