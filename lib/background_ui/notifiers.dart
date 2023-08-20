//this will be for all notifcations (ie popups for ads, if we want a user to go to a page etc)

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//class LocalNotifications{
class LocalNotifications{
  static Future initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async{
    //! wtf is "mipmap/ic_launcher"? (it has to refer to an android folder?)
    var andoridInit = AndroidInitializationSettings('mipmap/ic_launcher'); 
    var iOSInit = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(android: andoridInit, iOS: iOSInit); // figure stuff out for other platforms later
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // this will probably be used for the user messages 
  static Future showNotification({var id = 0,required String title, required String body, var payload, bool allowSound = true,
  required FlutterLocalNotificationsPlugin fln, var importanceLvl = Importance.none, var notiPriority = Priority.min
  }) async {
    AndroidNotificationDetails androidChannel = // we should change channel the id and name
    new AndroidNotificationDetails("make_a_channelId", "notification_channel_z", playSound: allowSound,
      sound: RawResourceAndroidNotificationSound('notification'), importance: importanceLvl,
      priority: notiPriority
    ); //we want the notifcations to be changable 
    var notif = NotificationDetails(android: androidChannel, iOS: DarwinNotificationDetails()); 

    await fln.show(0,title, body, notif);
  }
}