import 'dart:convert';
import 'dart:core';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbs/models/user_model.dart';
import 'package:smartbs/screens/home_screen.dart';
import 'package:smartbs/signin/signin.dart';
import 'package:smartbs/utils/app_strings.dart';
import 'package:smartbs/utils/locator.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'controllers/MenuController.dart';

void main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  UserModel user;
  if (prefs.getString(AppStrings.USER_PREF_KEY) != null) {
    user = UserModel.fromJson(
        jsonDecode(prefs.getString(AppStrings.USER_PREF_KEY)));
    if (user != null && user.uid.isNotEmpty) print("${user.displayName}");
  }
  runApp(MyApp(user));
}

class MyApp extends StatelessWidget {
  final UserModel user;

  MyApp(this.user);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MenuController(),
          ),
        ],
        child: GetMaterialApp(
          title: 'Smart Business Solutions',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.deepPurple,
          ),
          home: user != null && user.uid.isNotEmpty
              ? FirstScreen()
              : LoginPage(title: 'Smart Business Solutions'),
          builder: EasyLoading.init(),
        ));
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return _loginPage();
  }

  Scaffold _loginPage() {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage("assets/sbslogo1.jpeg"),
              height: 250,
            ),
            SizedBox(height: 50),
            _signInButton(),
          ],
        ),
      ),
    );
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        User user = await signInWithGoogle();
        if (user != null &&
            user.email != null &&
            (user.email == "smartbsflutter@gmail.com" ||
                user.email == "smartbusinesssolutions8088@gmail.com"))
          Get.off(FirstScreen());
        else if (user.uid != null) Get.off(FirstScreen());
        VxToast.show(context, msg: "Login Sucessfully", bgColor: Colors.green);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
