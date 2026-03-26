import 'network_thresholds.dart';

/// Tracks network performance using a sliding window of recent requests.
///
/// Uses a score-based system to avoid false positives:
/// - Slow  requests add  1 point
/// - Very-slow requests add 3 points
/// - Fast/normal requests subtract 1 point (clamped to 0)
///
/// A warning is triggered only after [minConsecutiveSlowRequests] or more
/// consecutive slow requests, *and* the accumulated score exceeds
/// [warningScoreThreshold].
class NetworkSpeedDetector {
  NetworkSpeedDetector({
    this.windowSize = 5,
    this.minConsecutiveSlowRequests = 2,
    this.warningScoreThreshold = 2,
  });

  /// Number of recent requests to keep in the sliding window.
  final int windowSize;

  /// Minimum consecutive slow requests before flagging a warning.
  final int minConsecutiveSlowRequests;

  /// Accumulated score needed before [shouldShowWarning] returns true.
  final int warningScoreThreshold;

  final List<int> _window = [];
  int _consecutiveSlowCount = 0;
  int _slowScore = 0;

  // ── Score weights ────────────────────────────────────────────────────────
  static const int _slowWeight = 1;
  static const int _verySlowWeight = 3;

  // ── Public API ───────────────────────────────────────────────────────────

  /// Records a completed request's elapsed time (ms).
  ///
  /// Returns `true` when the warning threshold has been reached.
  bool recordRequest(int responseTimeMs) {
    _addToWindow(responseTimeMs);
    _updateScore(NetworkThresholds.classifySpeed(responseTimeMs));
    return shouldShowWarning;
  }

  /// Resets the consecutive-slow counter and score (call after a fast request
  /// or when the user explicitly dismisses the warning).
  void reset() {
    _consecutiveSlowCount = 0;
    _slowScore = 0;
  }

  /// Whether the accumulated evidence is strong enough to show a warning.
  bool get shouldShowWarning =>
      _consecutiveSlowCount >= minConsecutiveSlowRequests &&
      _slowScore >= warningScoreThreshold;

  /// Moving average of response times in the current window (ms).
  double get averageResponseTime {
    if (_window.isEmpty) return 0;
    return _window.reduce((a, b) => a + b) / _window.length;
  }

  /// Speed category derived from the current moving average.
  NetworkSpeed get currentSpeed =>
      NetworkThresholds.classifySpeed(averageResponseTime.round());

  int get consecutiveSlowCount => _consecutiveSlowCount;
  int get slowScore => _slowScore;

  /// Snapshot of internal state — useful for debugging analytics.
  Map<String, dynamic> get analyticsData => {
        'responseTimes': List<int>.unmodifiable(_window),
        'averageMs': averageResponseTime,
        'currentSpeed': currentSpeed.name,
        'consecutiveSlowCount': _consecutiveSlowCount,
        'slowScore': _slowScore,
      };

  // ── Internal helpers ────────────────────────────────────────────────────

  void _addToWindow(int ms) {
    _window.add(ms);
    if (_window.length > windowSize) _window.removeAt(0);
  }

  void _updateScore(NetworkSpeed speed) {
    switch (speed) {
      case NetworkSpeed.fast:
      case NetworkSpeed.normal:
        _consecutiveSlowCount = 0;
        _slowScore = (_slowScore - 1).clamp(0, 999);
      case NetworkSpeed.slow:
        _consecutiveSlowCount++;
        _slowScore += _slowWeight;
      case NetworkSpeed.verySlow:
        _consecutiveSlowCount++;
        _slowScore += _verySlowWeight;
    }
  }
}
