import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'network_speed_detector.dart';
import 'network_thresholds.dart';

/// Emitted on [NetworkMonitor.qualityStream] whenever a request is recorded.
class NetworkQualityEvent {
  const NetworkQualityEvent({
    required this.speed,
    required this.averageResponseTimeMs,
    required this.connectionType,
    required this.timestamp,
  });

  final NetworkSpeed speed;
  final double averageResponseTimeMs;
  final ConnectionType connectionType;
  final DateTime timestamp;
}

/// Global singleton that tracks network quality throughout the app lifetime.
///
/// ## Setup
/// Call [initialize] once at app startup (e.g., inside `main()`):
/// ```dart
/// await NetworkMonitor.instance.initialize();
/// ```
///
/// ## Automatic usage
/// Add [NetworkMonitorInterceptor] to DioClient — it calls [recordRequest]
/// automatically on every HTTP response.
///
/// ## Manual warning display
/// ```dart
/// final shouldWarn = NetworkMonitor.instance.recordRequest(
///   responseTimeMs: elapsed,
///   requestType: RequestType.api,
/// );
/// if (shouldWarn && context.mounted) {
///   context.showNetworkSlowSnackBar(message);
/// }
/// ```
class NetworkMonitor {
  NetworkMonitor._internal();

  static final NetworkMonitor instance = NetworkMonitor._internal();

  // ── Dependencies ─────────────────────────────────────────────────────────
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker();
  final NetworkSpeedDetector _detector = NetworkSpeedDetector();

  // ── State ─────────────────────────────────────────────────────────────────
  ConnectionType _connectionType = ConnectionType.unknown;

  DateTime? _lastWarningShown;
  static const Duration _baseCooldown = Duration(minutes: 2);

  // Exponential back-off: after each warning the cooldown doubles,
  // capped at 2^4 × base = 32 minutes.
  int _backoffLevel = 0;
  static const int _maxBackoffLevel = 4;

  // ── Stream ────────────────────────────────────────────────────────────────
  final StreamController<NetworkQualityEvent> _qualityController =
      StreamController<NetworkQualityEvent>.broadcast();

  /// Broadcasts a [NetworkQualityEvent] after every recorded request.
  Stream<NetworkQualityEvent> get qualityStream => _qualityController.stream;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  // ── Public configuration ──────────────────────────────────────────────────

  ConnectionType get connectionType => _connectionType;

  /// Detection sensitivity — change at runtime based on user preference.
  NetworkSensitivity sensitivity = NetworkSensitivity.medium;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Initializes connectivity detection. Call once at app startup.
  Future<void> initialize() async {
    final initial = await _connectivity.checkConnectivity();
    _updateConnectionType(initial);

    _connectivitySub = _connectivity.onConnectivityChanged
        .listen(_updateConnectionType);
  }

  /// Releases resources. Call when the app is permanently shutting down.
  void dispose() {
    _connectivitySub?.cancel();
    _qualityController.close();
  }

  // ── Core recording API ────────────────────────────────────────────────────

  /// Records a completed request and returns `true` if a slow-network warning
  /// should be shown to the user right now.
  ///
  /// [responseTimeMs]  — elapsed time from request start to response received.
  /// [requestType]     — used to pick the correct threshold bucket.
  /// [requestSizeBytes]— optional; adjusts upload/download thresholds for
  ///                     large payloads (adds 1 s per MB beyond the first).
  bool recordRequest({
    required int responseTimeMs,
    required RequestType requestType,
    int? requestSizeBytes,
  }) {
    final threshold = _effectiveThreshold(requestType, requestSizeBytes, sensitivity);
    final isFast = responseTimeMs <= threshold;

    if (isFast) {
      _detector.reset();
      _backoffLevel = (_backoffLevel - 1).clamp(0, _maxBackoffLevel);
    }

    final warn = _detector.recordRequest(responseTimeMs);

    _qualityController.add(NetworkQualityEvent(
      speed: _detector.currentSpeed,
      averageResponseTimeMs: _detector.averageResponseTime,
      connectionType: _connectionType,
      timestamp: DateTime.now(),
    ));

    if (warn && _cooldownExpired()) {
      _lastWarningShown = DateTime.now();
      if (_backoffLevel < _maxBackoffLevel) _backoffLevel++;
      return true;
    }
    return false;
  }

  /// Convenience method for timeout errors — treats them as a very-slow
  /// request (3× the normal threshold for that type).
  void recordTimeout({required RequestType requestType}) {
    final base = NetworkThresholds.baseThresholds[requestType] ??
        NetworkThresholds.baseThresholds[RequestType.api]!;
    recordRequest(
      responseTimeMs: base * 3,
      requestType: requestType,
    );
  }

  /// Returns `true` if the device has an active internet connection.
  Future<bool> get isOnline => _connectionChecker.hasConnection;

  /// Snapshot of internal state — useful for debugging.
  Map<String, dynamic> get analyticsSnapshot => {
        ..._detector.analyticsData,
        'connectionType': _connectionType.name,
        'sensitivity': sensitivity.name,
        'backoffLevel': _backoffLevel,
        'lastWarningShown': _lastWarningShown?.toIso8601String(),
        'cooldownExpired': _cooldownExpired(),
      };

  // ── Internal helpers ──────────────────────────────────────────────────────

  bool _cooldownExpired() {
    if (_lastWarningShown == null) return true;
    final elapsed = DateTime.now().difference(_lastWarningShown!);
    final cooldown = Duration(
      milliseconds: _baseCooldown.inMilliseconds * (1 << _backoffLevel),
    );
    return elapsed >= cooldown;
  }

  int _effectiveThreshold(RequestType type, int? sizeBytes, NetworkSensitivity sens) {
    int base = NetworkThresholds.getEffectiveThreshold(
      requestType: type,
      connectionType: _connectionType,
      sensitivity: sens,
    );

    // For uploads/downloads, add 1 s per MB beyond the first megabyte
    if (sizeBytes != null &&
        (type == RequestType.upload || type == RequestType.download)) {
      final sizeMb = sizeBytes / (1024 * 1024);
      if (sizeMb > 1) base += (sizeMb * 1000).round();
    }
    return base;
  }

  void _updateConnectionType(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.ethernet)) {
      _connectionType = ConnectionType.ethernet;
    } else if (results.contains(ConnectivityResult.wifi)) {
      _connectionType = ConnectionType.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      _connectionType = ConnectionType.mobile;
    } else {
      _connectionType = ConnectionType.unknown;
    }
  }
}
