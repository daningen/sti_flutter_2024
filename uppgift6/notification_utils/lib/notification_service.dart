// import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

import 'permission_utils.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> scheduleNotification({
  required String title,
  required String content,
  required DateTime deliveryTime,
  required int id,
}) async {
  await requestPermissions(); // Request permissions before scheduling

  String channelId = const Uuid().v4(); // Unique ID per notification
  const String channelName = "notifications_channel";
  String channelDescription = "Standard notifications";

  // Android-specific settings
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  // iOS-specific settings
  var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

  // Combine platform settings
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    content,
    tz.TZDateTime.from(deliveryTime, tz.local),
    platformChannelSpecifics,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}

// ✅ Add the new function for showing parking notifications
Future<void> showParkingNotification(String parkingId) async {
  await requestPermissions(); // Ensure permissions are granted

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'parking_channel_id',
    'Parking Notifications',
    channelDescription: 'Notifications for parking events',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails, iOS: iosDetails);

  await flutterLocalNotificationsPlugin.show(
    
    1, // Unique notification ID
    'Parking Update',
    'A new parking event has occurred!',
   
    platformDetails,
    payload: parkingId, // Attach parking ID to notification
  );
}
