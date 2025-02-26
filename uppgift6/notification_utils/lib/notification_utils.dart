import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'permission_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;
export 'notification_service.dart'; // Export the notification service
export 'permission_utils.dart'
    hide flutterLocalNotificationsPlugin; // Export permission utilities
export 'timezone_utils.dart';

Future<void> scheduleNotification(
    {required String title,
    required String content,
    required DateTime deliveryTime,
    required int id}) async {
  await requestPermissions(); // be om tillåtelse innan schemaläggning sker (kommer ihåg ditt val sen tidigare)

  String channelId = const Uuid()
      .v4(); // unikt per notis. Oklart varför den heter channelId om jag förstått docs.
  const String channelName =
      "notifications_channel"; // kanal av notiser där alla notiser inom denna kanal levereras på liknande sätt. Går att konfigurera kanaler på olika sätt.
  String channelDescription =
      "Standard notifications"; // Beskrivningen av denna kanal som dyker upp i settings på android.

  // Android-specifika inställningar
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId, channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      timeoutAfter: 50000,
      ticker: 'ticker');

  // iOS-specifika inställningar
  var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

  // Kombinera plattformsinställningar
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.zonedSchedule(id, title, content,
      tz.TZDateTime.from(deliveryTime, tz.local), platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime);
}
