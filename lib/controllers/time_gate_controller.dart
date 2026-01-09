import 'package:shared_preferences/shared_preferences.dart';

import '../models/time_gate_status.dart';
import '../services/uptime_service.dart';

class TimeGateController {
  static const waitDuration = Duration(hours: 6);

  static const _stageOneCompleteKey = 'stage1Done';
  static const _completionUptimeMsKey = 'completionUptimeMs';
  static const _completionWallMsKey = 'completionWallMs';
  static const _lastSeenWallMsKey = 'lastSeenWallMs';

  static const _clockBackToleranceMs = 2 * 60 * 1000;

  static Future<void> completeStageOne() async {
    final prefs = await SharedPreferences.getInstance();
    final nowWall = DateTime.now().millisecondsSinceEpoch;
    final nowUptime = await UptimeService.getUptimeMillis();

    await prefs.setBool(_stageOneCompleteKey, true);
    await prefs.setInt(_completionWallMsKey, nowWall);
    await prefs.setInt(_completionUptimeMsKey, nowUptime);
    await prefs.setInt(_lastSeenWallMsKey, nowWall);
  }

  static Future<void> recordAppPause() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastSeenWallMsKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stageOneCompleteKey);
    await prefs.remove(_completionUptimeMsKey);
    await prefs.remove(_completionWallMsKey);
    await prefs.remove(_lastSeenWallMsKey);
  }

  static Future<TimeGateStatus> getGateStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final isStageOneComplete = prefs.getBool(_stageOneCompleteKey) ?? false;
    if (!isStageOneComplete) {
      return const TimeGateStatus(
        isStageOneComplete: false,
        canEnterStageTwo: false,
        remaining: waitDuration,
        isTamperingDetected: false,
      );
    }

    final completionUptime = prefs.getInt(_completionUptimeMsKey);
    if (completionUptime == null) {
      return const TimeGateStatus(
        isStageOneComplete: false,
        canEnterStageTwo: false,
        remaining: waitDuration,
        isTamperingDetected: true,
        warning: 'Saved state missing uptime. Please complete Stage One again.',
      );
    }

    final nowUptime = await UptimeService.getUptimeMillis();
    final nowWall = DateTime.now().millisecondsSinceEpoch;

    bool tamper = false;
    String? warning;

    // A) Detect wall-clock moved backwards since last seen (classic tampering)
    final lastSeenWall = prefs.getInt(_lastSeenWallMsKey);
    if (lastSeenWall != null &&
        nowWall + _clockBackToleranceMs < lastSeenWall) {
      tamper = true;
      warning =
          'Time manipulation detected. Please reset your device clock to the correct time to continue.';
    }

    // B) Detect reboot / uptime anomaly: uptime should not go backwards
    if (nowUptime < completionUptime) {
      tamper = true;
      // Reboot resets uptime; we cannot prove 6 hours elapsed without a server.
      warning =
          'Time manipulation detected. Please reset your device clock to the correct time to continue.';
    }

    // Uptime-based wait (real elapsed time)
    final elapsedMs = nowUptime - completionUptime;
    final neededMs = waitDuration.inMilliseconds;
    final remainingMs = (neededMs - elapsedMs).clamp(0, neededMs);

    // Update last seen wall clock after checks
    await prefs.setInt(_lastSeenWallMsKey, nowWall);

    final canEnter = (elapsedMs >= neededMs) && !tamper;

    return TimeGateStatus(
      isStageOneComplete: true,
      canEnterStageTwo: canEnter,
      remaining: Duration(milliseconds: remainingMs),
      isTamperingDetected: tamper,
      warning: warning,
    );
  }
}
