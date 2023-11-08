import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationController {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings("ic_launcher");

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails("CHANNEL_ID", "CHANNEL_NAME",
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            icon: "ic_launcher",
            sound: RawResourceAndroidNotificationSound("alertsound")),
        iOS: DarwinNotificationDetails());
  }

  Future<void> showNotifications(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return flutterLocalNotificationsPlugin.show(
        0, title, body, await notificationDetails());
  }
}
