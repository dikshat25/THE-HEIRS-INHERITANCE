import 'package:flutter/material.dart';
import 'package:mealmatch/login.dart';
import 'package:mealmatch/login2.dart';
import 'package:mealmatch/register.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'login',
    routes: {

      'login' : (context)=>MyLogin(),
      'register':(context)=>MyRegister(),
      'login2':(context)=> Login()


    },
  ));
}
