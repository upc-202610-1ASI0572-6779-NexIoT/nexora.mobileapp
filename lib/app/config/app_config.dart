/// Centralised runtime configuration for the Nexora mobile app.
class AppConfig {
  const AppConfig._();

  /// Base URL of the Nexora backend (web service).
  ///
  /// ┌──────────────────────────────────────────────────────────────────────┐
  /// │  SWITCH LOCAL  <->  PRODUCTION  by editing the `defaultValue` below.    │
  /// │                                                                        │
  /// │  LOCAL (current): 'http://10.0.2.2:5001'                               │
  /// │      10.0.2.2 is how the Android emulator reaches your computer's       │
  /// │      localhost, where the backend runs on port 5001.                   │
  /// │                                                                        │
  /// │  PRODUCTION: 'https://nexora-webservice.onrender.com'                  │
  /// └──────────────────────────────────────────────────────────────────────┘
  ///
  /// Can also be overridden at run time without editing code, e.g.:
  ///   flutter run --dart-define=NEXORA_API_BASE=https://nexora-webservice.onrender.com
  static const String apiBaseUrl = String.fromEnvironment(
    'NEXORA_API_BASE',
    defaultValue: 'https://nexora-webservice.onrender.com',
  );

  /// Device that reports water flow (L/min) — matches the embedded/edge/seed id.
  static const String waterDeviceId = 'water-safety-unit-apt-402';

  /// Device that reports electrical current (A) — matches the embedded/edge/seed id.
  static const String powerDeviceId = 'voltage-safety-unit-apt-402';

  /// How often the live consumption card refreshes its readings.
  static const Duration livePollInterval = Duration(seconds: 4);
}
