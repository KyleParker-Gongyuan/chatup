

import 'package:flutter/material.dart';


import 'package:chatup/background_ui/main_page.dart';
import 'package:chatup/background_ui/welcome_page.dart';
import 'package:chatup/libV2/newdata/data_helpa.dart' as db;
import 'package:chatup/libV2/newdata/registry.dart';
import 'package:shared_preferences/shared_preferences.dart';


//! INFO FOR LOGIN
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  final newdatabase = registry.get<db.DatabaseHelper>();

  @override
  void initState(){
    super.initState();
    
    //isUserInLoclDb(context); // Pass the context to the function
    _loadValueFromSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> userInDb(BuildContext context) async {
    //final rowExists = await newdatabase.checkRowExists(0);
    final rowExists = true;

    // Decide which page to navigate based on row existence
    if (rowExists) {
      Navigator.pushReplacementNamed(context, '/chat');
    } else {
      Navigator.pushReplacementNamed(context, '/welcomepage');
    }
  }
  Future<void> _loadValueFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userUuid = prefs.getString('userUuid');
    // Replace 'my_key' with your key
    if (userUuid != null) {
      // Automatically navigate to SecondPage if myString is not null
      Future.delayed(Duration.zero, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainPage(myUuid: userUuid,)), // how to goto previous page?
        );
      });
    }
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()), // how to goto previous page?
      );
    
  }
}
