import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartbs/models/user_model.dart';

class MenuController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  void controlMenu() {
    if (!_scaffoldKey.currentState.isDrawerOpen) {
      _scaffoldKey.currentState.openDrawer();
    } else
      _scaffoldKey.currentState.openEndDrawer();
  }

  String _filter = "Today";

  String get filter => _filter;

  void changeFilter(String filter) {
    print("Provider Filter" + filter);
    _filter = filter;
    print(_filter);
  }

  String _filterDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  String get filterDate => _filterDate;

  void changeFilterDate(String filterDate) {
    print("Provider Filter" + filterDate);
    _filterDate = filterDate;
    print(_filterDate);
    notifyListeners();
  }

  UserModel _userModal = new UserModel();

  UserModel get userModal => _userModal;

  void changeUser(UserModel userModal) {
    _userModal = userModal;
    notifyListeners();
  }
}
