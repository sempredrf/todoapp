import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:get/get.dart';
import 'package:todoapp/ui/notified_page.dart';

class NotifyHelper {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); //

  Future _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    Get.dialog(const Text("welcome to flutter!"));
  }

  Future _selectNotification(String? payload) async {
    if (payload!.isNotEmpty) {
      Get.to(() => NotifiedPage(payload: payload));
    }
  }

  AndroidNotificationDetails _androidNotificationDetails() =>
      const AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

  IOSInitializationSettings _initializationSettingsIOS() =>
      IOSInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
          onDidReceiveLocalNotification: _onDidReceiveLocalNotification);

  tz.TZDateTime _converTime(int hours, int minutes, int seconds) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hours,
      minutes,
      seconds,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> _configureLocalTimezone() async {
    tz.initializeTimeZones();
    final String timeZone = await FlutterNativeTimezone.getLocalTimezone();
    if (timeZone != "GMT") {
      tz.setLocalLocation(tz.getLocation(timeZone));
    }
  }

  initializeNotification() async {
    //tz.initializeTimeZones();
    await _configureLocalTimezone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('appicon');

    final IOSInitializationSettings initializationSettingsIOS =
        _initializationSettingsIOS();

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: _selectNotification,
    );
  }

  Future<void> displayNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: _androidNotificationDetails(),
        iOS: const IOSNotificationDetails());

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> scheduledNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
    int hours = 0,
    int minutes = 0,
    int seconds = 5,
  }) async {
    // final tz.TZDateTime scheduledTime =
    //     tz.TZDateTime.now(tz.local).add(Duration(
    //   hours: hours!,
    //   minutes: minutes!,
    //   seconds: seconds!,
    // ));
    final tz.TZDateTime scheduledTime = _converTime(
      hours,
      minutes,
      seconds,
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: _androidNotificationDetails());

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestPermission();
    }
  }
}
