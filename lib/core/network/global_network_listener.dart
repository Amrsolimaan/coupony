import 'dart:async';
import 'package:coupony/core/network/network_thresholds.dart';
import 'package:flutter/material.dart';
import '../localization/l10n/app_localizations.dart';
import '../extensions/snackbar_extension.dart';
import 'network_monitor.dart';

/// Global network monitoring widget that automatically shows warnings
/// when slow network is detected. Wraps the entire app to provide
/// automatic network feedback without manual intervention.
class GlobalNetworkListener extends StatefulWidget {
  final Widget child;
  
  const GlobalNetworkListener({
    super.key,
    required this.child,
  });

  @override
  State<GlobalNetworkListener> createState() => _GlobalNetworkListenerState();
}

class _GlobalNetworkListenerState extends State<GlobalNetworkListener> {
  StreamSubscription<NetworkQualityEvent>? _networkSubscription;
  DateTime? _lastWarningShown;
  
  // Prevent spam - only show warning once every 2 minutes
  static const Duration _warningCooldown = Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    _initializeNetworkMonitoring();
  }

  void _initializeNetworkMonitoring() {
    // Initialize network monitor
    NetworkMonitor.instance.initialize().then((_) {
      // Listen to network quality events
      _networkSubscription = NetworkMonitor.instance.qualityStream.listen(
        _handleNetworkQualityEvent,
        onError: (error) {
          debugPrint('Network monitoring error: $error');
        },
      );
    }).catchError((error) {
      debugPrint('Failed to initialize network monitor: $error');
    });
  }

  void _handleNetworkQualityEvent(NetworkQualityEvent event) {
    // Only show warning if context is available and cooldown has passed
    if (!mounted || !_shouldShowWarning(event)) return;

    // Use post frame callback to ensure widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final l10n = AppLocalizations.of(context);
      if (l10n == null) return;

      // Determine message based on severity
      final message = _getWarningMessage(event, l10n);
      
      // Show the warning
      context.showNetworkSlowSnackBar(
        message,
        duration: const Duration(seconds: 6), // Longer duration for network warnings
      );
      
      // Update last warning time
      _lastWarningShown = DateTime.now();
      
      debugPrint('Network warning shown: ${event.speed.name} (${event.averageResponseTimeMs}ms avg)');
    });
  }

  bool _shouldShowWarning(NetworkQualityEvent event) {
    // Only show for slow or very slow networks
    if (event.speed != NetworkSpeed.slow && event.speed != NetworkSpeed.verySlow) {
      return false;
    }

    // Check cooldown period
    if (_lastWarningShown != null) {
      final timeSinceLastWarning = DateTime.now().difference(_lastWarningShown!);
      if (timeSinceLastWarning < _warningCooldown) {
        return false;
      }
    }

    return true;
  }

  String _getWarningMessage(NetworkQualityEvent event, AppLocalizations l10n) {
    switch (event.speed) {
      case NetworkSpeed.verySlow:
        return l10n.network_very_slow_warning;
      case NetworkSpeed.slow:
      default:
        return l10n.network_slow_warning;
    }
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Extension to easily wrap any widget with network monitoring
extension NetworkMonitoring on Widget {
  /// Wraps this widget with global network monitoring
  Widget withNetworkMonitoring() {
    return GlobalNetworkListener(child: this);
  }
}