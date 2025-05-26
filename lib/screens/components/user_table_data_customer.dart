import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartbs/models/customer_model.dart';

import '../../../constants.dart';

class UserTableDataCustomer extends StatelessWidget {
  const UserTableDataCustomer(
      {Key key, @required this.customerModelList, this.createdDate})
      : super(key: key);

  final List<CustomerModel> customerModelList;
  final bool createdDate;

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
            "Leads Data",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          SizedBox(
            width: double.infinity,
            child: DataTable2(
              minWidth: 600,
              columnSpacing: defaultPadding,
              columns: [
                DataColumn(
                  label: Text("Name"),
                ),
                if (!createdDate)
                  DataColumn(
                    label: Text("Caller name"),
                  ),
                if (createdDate)
                  DataColumn(
                    label: Text("Lead Date"),
                  ),
                DataColumn(
                  label: Text("Number"),
                ),
                DataColumn(
                  label: Text("Call Back"),
                ),
                DataColumn(
                  label: Text("Comments"),
                ),
              ],
              rows: List.generate(
                customerModelList.length,
                (index) =>
                    recentFileDataRow(customerModelList[index], createdDate),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

DataRow recentFileDataRow(CustomerModel customerModel, bool createdDate) {
  return DataRow(
    cells: [
      DataCell(
        Text(customerModel.customerName),
      ),
      if (!createdDate)
        DataCell(
          Text(customerModel.caller),
        ),
      if (createdDate)
        DataCell(
          Text(DateFormat(DateFormat.YEAR_MONTH_DAY).format(
              DateFormat("dd-MM-yyyy").parse(customerModel.createdDate))),
        ),
      DataCell(Text((customerModel.phoneNumber).toString())),
      DataCell(
        Text(DateFormat(DateFormat.YEAR_MONTH_DAY).format(
            DateFormat("dd-MM-yyyy").parse(customerModel.callBackDate))),
      ),
      DataCell(
        Text(customerModel.comments != null ? customerModel.comments : " "),
      ),
    ],
  );
}
