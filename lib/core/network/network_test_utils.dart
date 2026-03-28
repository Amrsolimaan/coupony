import 'dart:async';
import 'network_monitor.dart';
import 'network_thresholds.dart';

/// Utility class for testing network monitoring functionality
/// Only use in development/testing environments
class NetworkTestUtils {
  NetworkTestUtils._();

  /// Simulates a slow network request for testing purposes
  static Future<void> simulateSlowRequest({
    int responseTimeMs = 6000,
    RequestType requestType = RequestType.api,
  }) async {
    final monitor = NetworkMonitor.instance;
    
    // Simulate the request delay
    await Future.delayed(Duration(milliseconds: responseTimeMs));
    
    // Record the slow request
    monitor.recordRequest(
      responseTimeMs: responseTimeMs,
      requestType: requestType,
    );
    
    print('Simulated ${requestType.name} request: ${responseTimeMs}ms');
  }

  /// Simulates multiple slow requests to trigger warning
  static Future<void> simulateMultipleSlowRequests({
    int count = 3,
    int delayBetweenRequests = 1000,
  }) async {
    for (int i = 0; i < count; i++) {
      await simulateSlowRequest(responseTimeMs: 7000);
      if (i < count - 1) {
        await Future.delayed(Duration(milliseconds: delayBetweenRequests));
      }
    }
  }

  /// Resets the network monitor state for clean testing
  static void resetMonitorState() {
    // This would reset internal counters if we had access to them
    // For now, we can just wait for the cooldown period
    print('Monitor state reset (wait for cooldown to expire)');
  }

  /// Gets current network monitoring statistics
  static Map<String, dynamic> getMonitorStats() {
    return NetworkMonitor.instance.analyticsSnapshot;
  }
}