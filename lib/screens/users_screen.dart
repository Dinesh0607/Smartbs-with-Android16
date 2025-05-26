import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:smartbs/models/user_model.dart';
import 'package:smartbs/utils/app_strings.dart';
import 'package:smartbs/utils/firebase_utility.dart';
import 'package:velocity_x/velocity_x.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<UsersList> usersList = [];
  List<UsersList> usersListDuplicate = [];
  List<UsersList> usersSelectedList = [];
  List<UsersList> usersSearchdList = [];
  TextEditingController editingController = TextEditingController();
  bool _enabled = false;
  int _value;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  getPref() async {
    usersList = await FirebaseUtility().getUsersVerifiedList();
    usersListDuplicate = usersList;
    setState(() {});
  }

  _onToogle(bool val) {
    setState(() {
      _enabled = val;
    });
  }

  void filterSearchResults(String query) {
    List<UsersList> dummySearchList = [];
    //dummySearchList.addAll(duplicateItems);
    if (query.isNotEmpty) {
      //List<String> dummyListData = List<String>();
      usersList.forEach((item) {
        if (item.displayName.toLowerCase().contains(query.toLowerCase())) {
          dummySearchList.add(item);
        }
      });
      setState(() {
        usersList = dummySearchList;
      });
      return;
    } else {
      setState(() {
        getPref();
      });
    }
  }

  void _makeRoleTeleCaller() async {
    for (UsersList u in usersSelectedList) {
      usersList.remove(u);
      u.userRole = "Tele Caller";
      u.userVerified = true;
      usersList.add(u);
      await FirebaseUtility().setUserRole(usersList);
    }
    setState(() {});
  }

  void _makeRoleDataEntry() async {
    for (UsersList u in usersSelectedList) {
      usersList.remove(u);
      u.userRole = "Data Entry";
      u.userVerified = true;
      usersList.add(u);
      await FirebaseUtility().setUserRole(usersList);
    }
    setState(() {});
  }

  void _deactivateUser() async {
    for (UsersList u in usersSelectedList) {
      usersList.remove(u);
      u.userVerified = false;
      usersList.add(u);
      await FirebaseUtility().setUserRole(usersList);
    }
    setState(() {});
  }

  onselectecrow(bool selected, UsersList user) async {
    setState(() {
      if (selected)
        usersSelectedList.add(user);
      else
        usersSelectedList.remove(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: "Close",
        onPressed: () {
          Get.back();
        },
        child: Icon(Icons.arrow_back, color: Colors.white),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppStrings.APP_BAR_TITLE),
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
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
              child: DataTable(
                columns: [
                  DataColumn(
                      label: Text("Name"),
                      numeric: false,
                      tooltip: "User Name"),
                  DataColumn(
                      label: Text("Active"),
                      numeric: false,
                      tooltip: "User Status"),
                  DataColumn(
                      label: Text("Role"), numeric: false, tooltip: "User Role")
                ],
                rows: usersList
                    .map((e) => DataRow(
                            selected: usersSelectedList.contains(e),
                            onSelectChanged: (b) {
                              onselectecrow(b, e);
                            },
                            cells: [
                              DataCell(
                                Text(e.displayName),
                              ),
                              DataCell(e.userVerified
                                  ? Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    )),
                              DataCell(
                                Text(e.userRole != null ? e.userRole : ""),
                              ),
                            ]))
                    .toList(),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            "* All Role Changes will automatically activates Users"
                .text
                .bold
                .color(Colors.red)
                .make(),
            SizedBox(
              height: 10.0,
            ),
            Wrap(
              runSpacing: 10.0,
              spacing: 10.0,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    _makeRoleTeleCaller();
                  },
                  color: Colors.deepPurple,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Tele Caller Role',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                  ),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                ),
                RaisedButton(
                  onPressed: () {
                    _makeRoleDataEntry();
                  },
                  color: Colors.deepPurple,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Data Entry Role',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                  ),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                ),
                RaisedButton(
                  onPressed: () {
                    _deactivateUser();
                  },
                  color: Colors.deepPurple,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Block User',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                  ),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Column _listview() {
    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          onChanged: (value) {
            print("value::::::::" + value);
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
          itemCount: usersList.length,
          itemBuilder: (context, index) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListTile(
                  onTap: () async {
                    Get.defaultDialog(
                      textConfirm: "Submit",
                      textCancel: "Cancel",
                      title: "Give Access to User",
                      content: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Form(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 10.0),
                                  Text(
                                    'Give Access to User',
                                  ),
                                  SizedBox(height: 10.0),
                                  CheckboxListTile(
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    activeColor: Colors.purple,
                                    contentPadding: const EdgeInsets.all(0),
                                    value: _enabled,
                                    title: Text("Activate"),
                                    onChanged: (val) {
                                      setState(() {
                                        _enabled = val;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 10.0),
                                  DropdownButtonFormField(
                                      hint: Text("User Type"),
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
                          ),
                        ),
                        color: Colors.white,
                      ),
                    );
                  },
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: CircleAvatar(
                    child: Text("U"),
                  ),
                  title: Text(usersList[index].displayName),
                  trailing: IconButton(
                    icon: usersList[index].userVerified
                        ? new Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          )
                        : Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                    onPressed: () async {
                      FirebaseUtility().setUserVerifed(usersList[index].uid,
                          !usersList[index].userVerified, null);
                      setState(() {
                        usersList[index].userVerified =
                            !usersList[index].userVerified;
                      });
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
