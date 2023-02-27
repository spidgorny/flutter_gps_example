import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/ui/with_foreground_task.dart';

import 'service/service_app.dart';

void main() {
  // runApp(const GpsLocationApp());
  runApp(const WithForegroundTask(child: ServiceExampleApp()));
}
