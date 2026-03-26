/// Request type categories — used to pick the correct threshold bucket.
enum RequestType { auth, api, upload, download }

/// Connection type as detected by connectivity_plus.
enum ConnectionType { wifi, mobile, ethernet, unknown }

/// Speed category assigned to a request after measuring its response time.
enum NetworkSpeed { fast, normal, slow, verySlow }

/// How aggressively the monitor reacts to slow requests.
enum NetworkSensitivity { low, medium, high }

/// All threshold constants and helper calculations live here so they can be
/// tuned from one place without touching business logic.
class NetworkThresholds {
  NetworkThresholds._();

  // ── Base thresholds (ms) by request type ─────────────────────────────────
  static const Map<RequestType, int> baseThresholds = {
    RequestType.auth: 3000,
    RequestType.api: 4000,
    RequestType.upload: 10000,
    RequestType.download: 8000,
  };

  // ── Connection-type multipliers ──────────────────────────────────────────
  // WiFi is fastest, so it keeps the base threshold.
  // Mobile data gets 50 % more time; unknown gets 20 % more as a safety net.
  static const Map<ConnectionType, double> connectionMultipliers = {
    ConnectionType.ethernet: 0.75,
    ConnectionType.wifi: 1.0,
    ConnectionType.mobile: 1.5,
    ConnectionType.unknown: 1.2,
  };

  // ── General speed-category cut-offs (ms) ────────────────────────────────
  static const int fastMs = 2000;   // < 2 s  → fast
  static const int normalMs = 4000; // 2–4 s  → normal
  static const int slowMs = 8000;   // 4–8 s  → slow  (> 8 s → very slow)

  // ── Sensitivity multipliers ──────────────────────────────────────────────
  static const Map<NetworkSensitivity, double> sensitivityMultipliers = {
    NetworkSensitivity.low: 1.5,
    NetworkSensitivity.medium: 1.0,
    NetworkSensitivity.high: 0.7,
  };

  /// Returns the effective threshold (ms) for a specific request context.
  static int getEffectiveThreshold({
    required RequestType requestType,
    required ConnectionType connectionType,
    NetworkSensitivity sensitivity = NetworkSensitivity.medium,
  }) {
    final base = baseThresholds[requestType] ?? baseThresholds[RequestType.api]!;
    final connMul = connectionMultipliers[connectionType] ?? 1.2;
    final sensMul = sensitivityMultipliers[sensitivity] ?? 1.0;
    return (base * connMul * sensMul).round();
  }

  /// Maps a raw response time to a [NetworkSpeed] category.
  static NetworkSpeed classifySpeed(int responseTimeMs) {
    if (responseTimeMs < fastMs) return NetworkSpeed.fast;
    if (responseTimeMs < normalMs) return NetworkSpeed.normal;
    if (responseTimeMs < slowMs) return NetworkSpeed.slow;
    return NetworkSpeed.verySlow;
  }
}
