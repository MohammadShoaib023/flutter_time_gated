# Flutter Time Gated

## Problem
I needed a simple app where Stage Two only opens after real time passes. Just
checking the phone clock is easy to cheat, so I needed a safer way.

## Idea
Use device uptime (monotonic time) instead of the wall clock, and warn if the
time looks tampered with.

## Solution
- Save the uptime when Stage One is finished.
- Only allow Stage Two after 6 hours of uptime.
- If the clock goes backward or uptime resets, block and show a warning.
- Files are split into folders: `views`, `controllers`, `models`, `services`,
  and `utils`.

## What I Used
- Flutter (Material 3)
- `shared_preferences` to save state
- MethodChannel for uptime:
  - Android: `SystemClock.elapsedRealtime()`
  - iOS: `ProcessInfo.processInfo.systemUptime`

## Run
1. Get packages:
   ```bash
   flutter pub get
   ```
2. Run the app:
   ```bash
   flutter run
   ```

## Notes
- Change the wait time in `TimeGateController.waitDuration` if you want.
