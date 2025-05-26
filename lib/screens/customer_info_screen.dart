import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:get/route_manager.dart';
import 'package:smartbs/models/customer_model.dart';
import 'package:smartbs/utils/firebase_utility.dart';

// import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';

class CustomerInfo extends StatefulWidget {
  const CustomerInfo();

  @override
  _CustomerInfoState createState() => _CustomerInfoState();
}

class _CustomerInfoState extends State<CustomerInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Enter Customer Data"),
      ),
      body: const TextFormFieldDemo(),
    );
  }
}

class TextFormFieldDemo extends StatefulWidget {
  const TextFormFieldDemo({Key key}) : super(key: key);

  @override
  TextFormFieldDemoState createState() => TextFormFieldDemoState();
}

class TextFormFieldDemoState extends State<TextFormFieldDemo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CustomerModel customerData = CustomerModel();
  String service;

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
      backgroundColor: Colors.green,
    ));
  }

  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void setService(DateTime dob) {
    setState(() {
      service =
          ((DateTime.now().difference(dob).inDays) / 365).toStringAsFixed(0);
      customerData.service = service;
    });
  }

  void _handleSubmitted() async {
    final form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidateMode =
          AutovalidateMode.always; // Start validating on every change.
      showInSnackBar(
        "Error",
      );
    } else {
      print(customerData.toJson());
      FirebaseUtility().saveCustomerData(customerData);
      form.save();
      showInSnackBar(customerData.customerName + " Saved");
      Get.back();
    }
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

  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: "Close",
        onPressed: () {
          Get.back();
        },
        child: Icon(Icons.arrow_back, color: Colors.white),
      ),
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        autovalidateMode: _autoValidateMode,
        child: Scrollbar(
          child: SingleChildScrollView(
            dragStartBehavior: DragStartBehavior.down,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sizedBoxSpace,
                DropdownButtonFormField(
                  value: customerData.bank,
                  items: [
                    DropdownMenuItem(
                      child: Text("HDFC"),
                      value: "HDFC",
                    ),
                    DropdownMenuItem(
                      child: Text("ICICI"),
                      value: "ICICI",
                    ),
                  ],
                  onChanged: (value) {
                    //print(value);
                    customerData.bank = value.toString();
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
                    icon: const Icon(Icons.confirmation_number),
                    hintText: "Customer Serial Number",
                    labelText: "Serial Number",
                  ),
                  onChanged: (value) {
                    customerData.customerName = value;
                  },
                  //validator: _validateName,
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
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Enter customer location";
                    else
                      return null;
                  },
                ),
                sizedBoxSpace,
                DateTimeField(
                  lastDate: DateTime.now(),
                  //errorText: "Required",
                  mode: DateTimeFieldPickerMode.date,
                  decoration: InputDecoration(
                    filled: true,
                    icon: const Icon(Icons.date_range),
                    hintText: "Date of birth",
                    labelText: "Date of birth",
                  ),
                  //label: "Date of birth",
                  initialDatePickerMode: DatePickerMode.day,
                  onDateSelected: (DateTime value) {
                    setService(value);
                    setState(() {
                      customerData.dob = value;
                    });
                  },
                  selectedDate:
                      customerData.dob != null ? customerData.dob : null,
                ),
                sizedBoxSpace,
                Text(service != null ? "Service: $service" : "Service: "),
                sizedBoxSpace,
                TextFormField(
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
                  decoration: InputDecoration(
                    filled: true,
                    icon: const Icon(Icons.email),
                    hintText: "sample@gmail.com",
                    labelText: "Email address",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    customerData.email = value;
                  },
                  validator: _emailValidator,
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
                  validator: _validateSalary,
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
                  validator: _validateSalary,
                ),
                sizedBoxSpace,
                TextFormField(
                  keyboardType: TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "Applied amount",
                    suffixText: "₹",
                  ),
                  maxLines: 1,
                  onChanged: (value) {
                    customerData.appliedAmount = value;
                  },
                  validator: _validateSalary,
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
                  validator: _validateSalary,
                ),
                sizedBoxSpace,
                TextFormField(
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    filled: true,
                    icon: const Icon(Icons.perm_identity_sharp),
                    hintText: "Who reached customer?",
                    labelText: "Caller Name",
                  ),
                  onChanged: (value) {
                    customerData.caller = value;
                  },
                  validator: _validateName,
                ),
                sizedBoxSpace,
                DropdownButtonFormField(
                  value: customerData.bank,
                  items: [
                    DropdownMenuItem(
                      child: Text("Applied"),
                      value: "Applied",
                    ),
                    DropdownMenuItem(
                      child: Text("Approved"),
                      value: "Approved",
                    ),
                  ],
                  onChanged: (value) {
                    customerData.applicationStatus = value;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    icon: const Icon(Icons.priority_high),
                    hintText: "Status",
                    labelText: "Status",
                  ),
                  validator: _validateName,
                ),
                sizedBoxSpace,
                Center(
                  child: RaisedButton(
                    onPressed: () {
                      _handleSubmitted();
                    },
                    color: Colors.deepPurple,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Submit',
                        style: TextStyle(fontSize: 25, color: Colors.white),
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
    );
  }
}
