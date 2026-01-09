import 'package:flutter/material.dart';

import 'controllers/time_gate_controller.dart';
import 'views/stage_one_view.dart';

void main() => runApp(const TimeGatedApp());

class TimeGatedApp extends StatefulWidget {
  const TimeGatedApp({super.key});
  @override
  State<TimeGatedApp> createState() => _TimeGatedAppState();
}

class _TimeGatedAppState extends State<TimeGatedApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      TimeGateController.recordAppPause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stage App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const StageOneView(),
    );
  }
}
