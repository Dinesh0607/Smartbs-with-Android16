import 'dart:io';

import 'package:flutter/material.dart';

enum DeviceType {
  ANDROIDPHONE,
  ANDROID7INCHTABLET,
  ANDROID10INCHTABLET,
  IOSIPAD3GEN, // WIDTH 834 HEIGHT 1112
  IOSIPADPRO12INCHTABLET, // WIDTH 1024
  IOSIPADPRO11INCHTABLET, // WIDTH 834 HEIGHT 1194
  IOSIPADPRO9INCHTABLET, // WIDTH 768
  IOSIPAD7, // WIDTH 810
  IOSDEVICE
}

class AppDimens {
  double textw8 = 8;
  double textw10 = 10;
  double textw12 = 12;
  double textw13 = 13;
  double textw11 = 11;
  double textw14 = 14;
  double textw16 = 16;
  double textw17 = 17;
  double textw18 = 18;
  double textw20 = 20;
  double textw22 = 22;
  double textw24 = 24;
  double textw26 = 26;
  double textw28 = 28;
  double textw30 = 30;

  double paddingw0 = 0;
  double paddingw5 = 5;
  double paddingw11 = 11;
  double paddingw7 = 7;
  double paddingw9 = 9;

  double paddingw10 = 10;
  double paddingw12 = 12;
  double paddingw15 = 15;

  double buttonmargin = 14;
  // used in view patient journal
  double journalimageheightwidth = 120;

  // used in patient journal
  double patientjournaltabpadding = 8;

  //app arrow icon size
  double arrowiconsize = 14;

  //delete button padding
  double deletebuttonpadding = 5;

  //popup buttons
  double deletebuttoncrosssize = 100;
  // double popupchoicebuttonpadding = 15;

  //icon in appBar
  double homebottombarIcon = 10;
  //delete Icon
  double addIcon = 22;
  //status Icon
  double statusicon = 14;
  //maxLines in userporfilefinal image
  int maxlines = 14;

  double weserveiconHeight = 110;
  double weserveiconwidth = 110;

  double height = 25;
  double width = 25;
  double heightTextFormField = 25;

  double savedScreenimageheight = 40;
  double savedScreenimageWidth = 40;

  double chatWidth = 250.0;
  double addButtonWidth = 50.0;

  double profileImageHeight = 100;
  double profileImagewidth = 100;

  double newServiceImageHeight = 50;
  double newServiceImagewidth = 50;

  double upperPadding = 5;
  double bottomPadding = 5;
  double leftPadding = 5;
  double rightPadding = 5;

  double cartSize = 20;

  double dotsize = 10;

  double chatscreenprofileheight = 45;
  double chatscreenprofilewidth = 45;

  double chattingscreenprofileheight = 45;
  double chattingscreenprofilewidth = 45;

  double textFieldHeight = 55;

  double textField = 55;

  double badgesizetop = 10;
  double badgesizeright = 8;

  double sendButtonheight = 47;
  double sendButtonWidth = 47;

  //height of image in service detail page
  double imageHeight = 250;

  //item view height in home page
  double itemHeight = 176;

  //loginscreen.dart
  double countrypickerheight = 47;
  double mobilenumbertextfieldheight = 65;

  //UserChatListItemView.dart
  double userimage = 45;

  //ServiceDetailPage.dart
  double plusminusiconsize = 10;

  //splash.dart
  double splashiconheight = 250;

  //introSlider.dart
  double sliderImagehw = 100;

  DeviceType deviceType = DeviceType.ANDROIDPHONE;
  AppDimens(Size size) {
    double screenwidth = size.width;
    double screenheight = size.height;
    // print(" ################### device width " + screenwidth.toString());
    // print(" ################### device height " + screenheight.toString());

    /*
    320dp: a typical phone screen (240x320 ldpi, 320x480 mdpi, 480x800 hdpi, etc).
    480dp: a large phone screen ~5" (480x800 mdpi).
    600dp: a 7” tablet (600x1024 mdpi).
    720dp: a 10” tablet (720x1280 mdpi, 800x1280 mdpi, etc).
*/
    if (Platform.isAndroid) {
      if ((screenwidth >= 600 && screenwidth <= 700)) {
        deviceType = DeviceType.ANDROID7INCHTABLET;
        textw8 = 18;
        paddingw5 = 5;
        paddingw0 = 5;

        buttonmargin = 16;
        journalimageheightwidth = 200;
        patientjournaltabpadding = 16;
        arrowiconsize = 22;
        deletebuttonpadding = 14;
        deletebuttoncrosssize = 140;
        homebottombarIcon = 33;
        maxlines = 25;
        weserveiconHeight = 120;
        weserveiconwidth = 120;
        height = 30;
        width = 30;
        chatWidth = 350.0;
        addIcon = 33;
        addButtonWidth = 60.0;
        profileImageHeight = 60;
        profileImagewidth = 60;
        upperPadding = 10;
        bottomPadding = 10;
        leftPadding = 10;
        rightPadding = 10;
        cartSize = 30;
        dotsize = 10;

        newServiceImageHeight = 30;
        newServiceImagewidth = 30;

        savedScreenimageheight = 50;
        savedScreenimageWidth = 50;

        chatscreenprofileheight = 50;
        chatscreenprofilewidth = 50;

        chattingscreenprofileheight = 50;
        chattingscreenprofilewidth = 50;

        textFieldHeight = 60;
        textField = 50;

        badgesizetop = 10;
        badgesizeright = 8;

        sendButtonheight = 57;
        sendButtonWidth = 57;

        imageHeight = 270;

        itemHeight = 176;

        countrypickerheight = 52;
        mobilenumbertextfieldheight = 70;
        userimage = 50;
        plusminusiconsize = 14;
        splashiconheight = 180;

        sliderImagehw = 300;
        // paddingw10 = 18;
      } else if ((screenwidth > 700)) {
        deviceType = DeviceType.ANDROID10INCHTABLET;
        paddingw0 = 10;
        textw8 = 20;
        paddingw5 = 7;
        buttonmargin = 16;
        journalimageheightwidth = 200;
        arrowiconsize = 22;
        deletebuttonpadding = 14;
        deletebuttonpadding = 14;
        deletebuttoncrosssize = 140;
        weserveiconHeight = 110;
        weserveiconwidth = 140;
        height = 35;
        width = 35;
        homebottombarIcon = 33;
        chatWidth = 450.0;
        profileImageHeight = 70;
        profileImagewidth = 70;
        upperPadding = 15;
        bottomPadding = 15;
        leftPadding = 15;
        rightPadding = 15;
        savedScreenimageheight = 60;
        savedScreenimageWidth = 60;
        addIcon = 35;
        newServiceImageHeight = 40;
        newServiceImagewidth = 40;
        cartSize = 35;
        dotsize = 15;

        chatscreenprofileheight = 55;
        chatscreenprofilewidth = 55;

        chattingscreenprofileheight = 65;
        chattingscreenprofilewidth = 65;
        textFieldHeight = 75;
        textField = 65;
        addButtonWidth = 60.0;

        badgesizetop = 5;
        badgesizeright = 10;

        sendButtonheight = 75;
        sendButtonWidth = 75;

        imageHeight = 300;

        itemHeight = 176;

        countrypickerheight = 52;
        mobilenumbertextfieldheight = 70;
        userimage = 53;
        plusminusiconsize = 14;
        splashiconheight = 180;

        sliderImagehw = 350;
        // paddingw10 = 70;
      } else {
        deviceType = DeviceType.ANDROIDPHONE;
        paddingw0 = 0;
        buttonmargin = 14;
        textw8 = 8;
        paddingw5 = 5;
        journalimageheightwidth = 120;
        patientjournaltabpadding = 8;
        arrowiconsize = 14;
        deletebuttonpadding = 5;
        deletebuttoncrosssize = 100;
        weserveiconHeight = 110;
        weserveiconwidth = 110;
        height = 25;
        width = 25;
        homebottombarIcon = 22;
        chatWidth = 250.0;
        addIcon = 22;
        addButtonWidth = 50.0;
        profileImageHeight = 60;
        profileImagewidth = 60;
        upperPadding = 1;
        bottomPadding = 1;
        leftPadding = 5;
        rightPadding = 5;
        savedScreenimageheight = 40;
        savedScreenimageWidth = 40;

        newServiceImageHeight = 20;
        newServiceImagewidth = 20;

        cartSize = 22;
        dotsize = 8;

        chatscreenprofileheight = 45;
        chatscreenprofilewidth = 45;

        chattingscreenprofileheight = 45;
        chattingscreenprofilewidth = 45;
        textFieldHeight = 55;
        textField = 45;

        badgesizetop = 11;
        badgesizeright = 9;

        sendButtonheight = 47;
        sendButtonWidth = 47;

        imageHeight = 250;

        itemHeight = 176;

        sliderImagehw = 300;

        // paddingw10 = 10;
      }
    } else if (Platform.isIOS) {
      if ((screenwidth >= 750 && screenwidth <= 800)) {
        deviceType = DeviceType.IOSIPADPRO9INCHTABLET;
        textw8 = 18;
        paddingw5 = 5;
        paddingw0 = 5;

        buttonmargin = 16;
        journalimageheightwidth = 200;
        patientjournaltabpadding = 16;
        arrowiconsize = 22;
        deletebuttonpadding = 14;
        deletebuttoncrosssize = 140;
        homebottombarIcon = 33;
        maxlines = 25;
        weserveiconHeight = 120;
        weserveiconwidth = 120;
        height = 30;
        width = 30;
        chatWidth = 350.0;
        addIcon = 33;
        addButtonWidth = 60.0;
        profileImageHeight = 60;
        profileImagewidth = 60;
        upperPadding = 10;
        bottomPadding = 10;
        leftPadding = 10;
        rightPadding = 10;
        cartSize = 30;
        dotsize = 10;

        newServiceImageHeight = 30;
        newServiceImagewidth = 30;

        savedScreenimageheight = 50;
        savedScreenimageWidth = 50;

        chatscreenprofileheight = 50;
        chatscreenprofilewidth = 50;

        chattingscreenprofileheight = 50;
        chattingscreenprofilewidth = 50;

        textFieldHeight = 60;
        textField = 50;

        badgesizetop = 10;
        badgesizeright = 8;

        sendButtonheight = 57;
        sendButtonWidth = 57;

        imageHeight = 270;

        itemHeight = 176;

        countrypickerheight = 52;
        mobilenumbertextfieldheight = 70;
        userimage = 50;
        plusminusiconsize = 14;
        splashiconheight = 180;

        sliderImagehw = 300;
        // paddingw10 = 18;
      } else if ((screenwidth > 800 && screenwidth < 900)) {
        if (screenwidth == 810) {
          deviceType = DeviceType.IOSIPAD7;
        } else if (screenwidth == 834 && screenheight == 1194) {
          deviceType = DeviceType.IOSIPADPRO11INCHTABLET;
        } else if (screenwidth == 834 && screenheight == 1112) {
          deviceType = DeviceType.IOSIPAD3GEN;
        }
        paddingw0 = 10;
        textw8 = 20;
        paddingw5 = 7;
        buttonmargin = 16;
        journalimageheightwidth = 200;
        arrowiconsize = 22;
        deletebuttonpadding = 14;
        deletebuttonpadding = 14;
        deletebuttoncrosssize = 140;
        weserveiconHeight = 110;
        weserveiconwidth = 140;
        height = 35;
        width = 35;
        homebottombarIcon = 33;
        chatWidth = 450.0;
        profileImageHeight = 70;
        profileImagewidth = 70;
        upperPadding = 15;
        bottomPadding = 15;
        leftPadding = 15;
        rightPadding = 15;
        savedScreenimageheight = 60;
        savedScreenimageWidth = 60;
        addIcon = 35;
        newServiceImageHeight = 40;
        newServiceImagewidth = 40;
        cartSize = 35;
        dotsize = 15;

        chatscreenprofileheight = 55;
        chatscreenprofilewidth = 55;

        chattingscreenprofileheight = 65;
        chattingscreenprofilewidth = 65;
        textFieldHeight = 75;
        textField = 65;
        addButtonWidth = 60.0;

        badgesizetop = 5;
        badgesizeright = 10;

        sendButtonheight = 75;
        sendButtonWidth = 75;

        imageHeight = 300;

        itemHeight = 176;

        countrypickerheight = 52;
        mobilenumbertextfieldheight = 70;
        userimage = 53;
        plusminusiconsize = 14;
        splashiconheight = 180;

        sliderImagehw = 300;
        // paddingw10 = 70;
      } else if ((screenwidth > 1000)) {
        deviceType = DeviceType.IOSIPADPRO12INCHTABLET;
        paddingw0 = 10;
        textw8 = 20;
        paddingw5 = 7;
        buttonmargin = 16;
        journalimageheightwidth = 200;
        arrowiconsize = 22;
        deletebuttonpadding = 14;
        deletebuttonpadding = 14;
        deletebuttoncrosssize = 140;
        weserveiconHeight = 110;
        weserveiconwidth = 140;
        height = 35;
        width = 35;
        homebottombarIcon = 33;
        chatWidth = 450.0;
        profileImageHeight = 70;
        profileImagewidth = 70;
        upperPadding = 15;
        bottomPadding = 15;
        leftPadding = 15;
        rightPadding = 15;
        savedScreenimageheight = 60;
        savedScreenimageWidth = 60;
        addIcon = 35;
        newServiceImageHeight = 40;
        newServiceImagewidth = 40;
        cartSize = 35;
        dotsize = 15;

        chatscreenprofileheight = 55;
        chatscreenprofilewidth = 55;

        chattingscreenprofileheight = 65;
        chattingscreenprofilewidth = 65;
        textFieldHeight = 75;
        textField = 65;
        addButtonWidth = 60.0;

        badgesizetop = 5;
        badgesizeright = 10;

        sendButtonheight = 75;
        sendButtonWidth = 75;

        imageHeight = 300;

        itemHeight = 176;

        countrypickerheight = 52;
        mobilenumbertextfieldheight = 70;
        userimage = 53;
        plusminusiconsize = 14;
        splashiconheight = 180;

        sliderImagehw = 350;
        // paddingw10 = 70;
      } else {
        deviceType = DeviceType.IOSDEVICE;
        paddingw0 = 0;
        buttonmargin = 14;
        textw8 = 8;
        paddingw5 = 5;
        journalimageheightwidth = 120;
        patientjournaltabpadding = 8;
        arrowiconsize = 14;
        deletebuttonpadding = 5;
        deletebuttoncrosssize = 100;
        weserveiconHeight = 110;
        weserveiconwidth = 110;
        height = 25;
        width = 25;
        homebottombarIcon = 22;
        chatWidth = 250.0;
        addIcon = 22;
        addButtonWidth = 50.0;
        profileImageHeight = 60;
        profileImagewidth = 60;
        upperPadding = 1;
        bottomPadding = 1;
        leftPadding = 5;
        rightPadding = 5;
        savedScreenimageheight = 40;
        savedScreenimageWidth = 40;

        newServiceImageHeight = 20;
        newServiceImagewidth = 20;

        cartSize = 22;
        dotsize = 8;

        chatscreenprofileheight = 45;
        chatscreenprofilewidth = 45;

        chattingscreenprofileheight = 45;
        chattingscreenprofilewidth = 45;
        textFieldHeight = 55;
        textField = 45;

        badgesizetop = 11;
        badgesizeright = 9;

        sendButtonheight = 47;
        sendButtonWidth = 47;

        imageHeight = 250;

        itemHeight = 176;
        plusminusiconsize = 10;
        sliderImagehw = 350;

        // paddingw10 = 10;
      }
    }

    incresevalues();
  }

  incresevalues() {
    textw10 = textw8 + 2;
    textw12 = textw8 + 4;
    textw11 = textw8 + 3;
    textw14 = textw8 + 6;
    textw16 = textw8 + 8;
    textw18 = textw8 + 10;
    textw20 = textw8 + 12;
    textw22 = textw8 + 14;
    textw24 = textw8 + 16;
    textw26 = textw8 + 18;
    textw28 = textw8 + 20;
    textw30 = textw8 + 22;

    paddingw5 = paddingw5;
    paddingw10 = paddingw5 + 5;
    paddingw15 = paddingw5 + 10;
    paddingw12 = paddingw5 + 8;
    paddingw11 = paddingw5 + 6;
    paddingw7 = paddingw5 + 2;
    paddingw9 = paddingw5 + 4;
  }
}
