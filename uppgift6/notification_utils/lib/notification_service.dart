// import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'permission_utils.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> scheduleNotification({
  required String title,
  required String content,
  required DateTime deliveryTime,
  required int id, // Use the provided ID directly
}) async {
  await requestPermissions();

  const String channelId = "parking_channel_id"; // Consistent channel ID
  const String channelName = "Parking Notifications"; // Consistent channel name
  const String channelDescription = "Notifications for parking events";

  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker', // Consider removing if it's not needed
    // Add other Android-specific settings as needed (e.g., sound, icon)
  );

  const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(); // Add iOS settings if needed

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id, // Use the provided ID directly (important!)
    title,
    content,
    tz.TZDateTime.from(deliveryTime, tz.local),
    platformChannelSpecifics,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}

Future<void> cancelNotification(int id) async {
  await flutterLocalNotificationsPlugin.cancel(id);
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
