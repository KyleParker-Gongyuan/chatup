
import 'package:flutter/material.dart';

import 'package:chatup/background_ui/main_page.dart';
import 'package:chatup/chat/pages/newUserStart/register_holder.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:chatup/libV2/newdata/data_helpa.dart' as db;
import 'package:chatup/libV2/newdata/registry.dart';
import 'package:shared_preferences/shared_preferences.dart';




class SettingsPage extends StatelessWidget {
  //const SettingsPage ({super.key});
  final database = registry.get<db.DatabaseHelper>(); 
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Handle create account
                  Navigator.pop(//! THIS goto 'X' page
                    context,
                  );
                },
                child: const Text('go back'),
              ),
              ElevatedButton(
                onPressed: () async {
                  
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  final String? userUuid = prefs.getString('userUuid');

                  // TODO: Handle create account
                  Navigator.push(//! THIS goto 'X' page
                    context,
                  MaterialPageRoute(builder: (context)  => MainPage(myUuid: userUuid!,)), //TODO: CHANGE THIS
                  );
                },
                child: const Text('go mainpage'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Handle create account
                  Navigator.push(//! THIS goto 'X' page
                    context,
                    //MaterialPageRoute(builder: (context) => InitLanguageSelector()), //TODO: CHANGE THIS
                    MaterialPageRoute(builder: (context) => WillPopScope(
                      // this should mean that they cant go back a page to make another account  
                      onWillPop: () => Future.value(false), 
                      //child: RegisterPagez(isRegistering:true)
                      child: SignupPage()
                      ) //TODO: CHANGE THIS
                    )
                  );
                },
                child: const Text('true sign up'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Handle create account
                  Navigator.push(//! THIS goto 'X' page
                    context,
                    
                    MaterialPageRoute(builder: (context) => WillPopScope(
                      // this should mean that they cant go back a page to make another account  
                      onWillPop: () => Future.value(false), 
                      child:  SettingsList(
      sections: [
        SettingsSection(
          title: Text('Common'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: Icon(Icons.language),
              title: Text('Language'),
              value: Text('English'),
            ),
            SettingsTile.switchTile(
              onToggle: (value) {},
              initialValue: true,
              leading: Icon(Icons.format_paint),
              title: Text('Enable custom theme'),
            ),
          ],
        ),
      ],
    ),
                      ) //TODO: CHANGE THIS
                    )
                  );
                },
                child: const Text('settings V2 package'),
              ),
            ],
          ),
        ),
      ),
    );

  }
}



