import 'package:flutter/material.dart';

//var _get1; // 언더바를 붙이면 다른 클래스에서 사용 못함둥
var theme = ThemeData( //모든 레이아웃 꾸밀때
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Colors.black
  )
  ,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: Colors.grey,
    )
  ),
  iconTheme:  IconThemeData(color: Colors.blue),
  appBarTheme:  const AppBarTheme(color: Colors.white,elevation: 1,
      actionsIconTheme: IconThemeData(color: Colors.black) ),
  textTheme:  TextTheme(bodyText2: TextStyle(color: Colors.black)),
);