// ignore_for_file: avoid_print

import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

import '../../loc/loc.dart';

final dio = Dio();

class FirstTaskHandler extends TaskHandler {
  SendPort? _sendPort;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    print('onStart');
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $customData');

    await getPositionAndSendToUrl(sendPort);
  }

  Future<void> getPositionAndSendToUrl(SendPort? sendPort) async {
    Position position = await determinePosition();
    print(position);
    sendPort?.send(position);
    final response = await dio.post(
        'https://webhook.site/1ccafabf-90fd-4438-a48c-1250a5fa343e',
        data: {
          'lat': position.latitude,
          'lon': position.longitude,
          'acc': position.accuracy,
          'alt': position.altitude,
          'speed': position.speed,
          'speedAcc': position.speedAccuracy,
          'head': position.heading,
        });
    print(response);
    sendPort?.send(response);
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    print('onEvent: $timestamp');
    await getPositionAndSendToUrl(sendPort);
    // Send data to the main isolate.
    sendPort?.send(timestamp);
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('onDestroy');
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    print('onButtonPressed >> $id');
  }

  @override
  void onNotificationPressed() {
    print('onNotificationPressed');
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}
