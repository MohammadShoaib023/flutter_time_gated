import 'package:flutter/services.dart';

/// Monotonic uptime in milliseconds (not affected by device time changes).
class UptimeService {
  static const MethodChannel _ch = MethodChannel('app.uptime/channel');

  static Future<int> getUptimeMillis() async {
    final v = await _ch.invokeMethod<int>('uptimeMillis');
    if (v == null) throw StateError('uptimeMillis returned null');
    return v;
  }
}
