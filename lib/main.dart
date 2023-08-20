//import 'dart:js';


import 'package:flutter/material.dart';





import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'chat/pages/splash_screen.dart';
import 'libV2/newdata/registry.dart';








Future<void> main() async {

//  prefs.setString('loginToken', value)
  

  //check if is a user locally {goto mainpage} else login/signup
  
  await Supabase.initialize(url: 'https://teszdgkwtuwbossvhwpy.supabase.co', anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRlc3pkZ2t3dHV3Ym9zc3Zod3B5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg4OTIxMDcsImV4cCI6MjAwNDQ2ODEwN30.9qJPdJEAhsBlVp-89xKDWjnDho86VNrdLa0jN6a3Wuo',
    realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 15), 
  );
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userUuid = prefs.getString('userUuid');

  setupDb(userUuid);

  


  runApp(const MainApp());


}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      title: 'Generic ChatApp',
      theme: ThemeData(
          
          brightness: Brightness.light,
          inputDecorationTheme: const InputDecorationTheme(
          
          focusedBorder: OutlineInputBorder(
            
            borderSide: BorderSide(
                style: BorderStyle.solid, 
                color: Colors.blue,
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
        ),

      home: const SplashScreen(),
    );
  }

}


