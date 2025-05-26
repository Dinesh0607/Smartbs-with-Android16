import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:smartbs/base/img.dart';
import 'package:smartbs/base/my_text.dart';
import 'package:smartbs/controllers/MenuController.dart';
import 'package:smartbs/models/user_model.dart';
import 'package:smartbs/screens/dashboard/components/leadsdata_screen_admin.dart';
import 'package:smartbs/screens/dashboard/components/manage_data_admin.dart';
import 'package:smartbs/screens/dashboard/components/user_access_management_screen.dart';
import 'package:smartbs/signin/signin.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../main.dart';

class SideBar {
  Drawer getDrawer(BuildContext context, UserModel user) {
    void onDrawerItemClicked(String name) {
      // Navigator.pop(context);
      VxToast.show(context, msg: name + " Selected");
    }

    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 190,
              child: Stack(
                children: <Widget>[
                  Image.asset(
                    Img.get('material_bg_1.png'),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40, horizontal: 14),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.grey[100],
                      child: CircleAvatar(
                        radius: 33,
                        backgroundImage: NetworkImage(user.photoURL),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(user.displayName,
                              style: MyText.body2(context).copyWith(
                                  color: Colors.grey[100],
                                  fontWeight: FontWeight.bold)),
                          Container(height: 5),
                          Text(user.email,
                              style: MyText.body2(context)
                                  .copyWith(color: Colors.grey[100]))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text("Home",
                  style: MyText.subhead(context).copyWith(
                      color: Colors.black, fontWeight: FontWeight.w500)),
              leading: Icon(Icons.home, size: 25.0, color: Colors.grey),
              onTap: context.read<MenuController>().controlMenu,
            ),
            ListTile(
              title: Text("User Access",
                  style: MyText.subhead(context).copyWith(
                      color: Colors.black, fontWeight: FontWeight.w500)),
              leading: Icon(Icons.whatshot, size: 25.0, color: Colors.grey),
              onTap: () {
                Get.to(UserAccessScreen());
              },
            ),
            ListTile(
              title: Text("Leads Data",
                  style: MyText.subhead(context).copyWith(
                      color: Colors.black, fontWeight: FontWeight.w500)),
              leading: Icon(Icons.group_sharp, size: 25.0, color: Colors.grey),
              onTap: () {
                Get.to(LeadsDataScreenAdmin());
              },
            ),
            ListTile(
              title: Text("Actions",
                  style: MyText.subhead(context).copyWith(
                      color: Colors.black, fontWeight: FontWeight.w500)),
              leading: Icon(
                Icons.attractions,
                size: 25.0,
                color: Colors.grey,
              ),
              onTap: () {
                Get.to(AdminManageData());
              },
            ),
            Divider(),
            ListTile(
              title: Text("Settings",
                  style: MyText.subhead(context).copyWith(
                      color: Colors.black, fontWeight: FontWeight.w500)),
              leading: Icon(Icons.settings, size: 25.0, color: Colors.grey),
              onTap: () {
                onDrawerItemClicked("Settings");
              },
            ),
            ListTile(
              title: Text("Help",
                  style: MyText.subhead(context).copyWith(
                      color: Colors.black, fontWeight: FontWeight.w500)),
              leading: Icon(Icons.help_outline, size: 25.0, color: Colors.grey),
              onTap: () {
                onDrawerItemClicked("Help");
              },
            ),
            ListTile(
              title: Text("Logout",
                  style: MyText.subhead(context).copyWith(
                      color: Colors.black, fontWeight: FontWeight.w500)),
              leading: Icon(Icons.logout, size: 25.0, color: Colors.grey),
              onTap: () {
                signOutGoogle();
                VxToast.show(context,
                    msg: "Logout Sucessfully", bgColor: Colors.red);
                Get.offAll(LoginPage(title: 'Smart Business Solutions'));
              },
            ),
          ],
        ),
      ),
    );
  }
}
