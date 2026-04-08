import 'package:coupony/features/seller_flow/SellerOnboarding/data/models/seller_preferences_model.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/data/models/user_preferences_model.dart';
import 'package:coupony/features/permissions/data/models/permission_status_model.dart';
import 'package:coupony/features/Profile/data/models/saved_address_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:coupony/app.dart';
import 'package:coupony/core/storage/local_cache_service.dart';
import 'package:coupony/core/network/network_monitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/dependency_injection/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 1. Initialize Hive
  await Hive.initFlutter();

  // 2. Register Hive Adapters
  Hive.registerAdapter(UserPreferencesModelAdapter());
  Hive.registerAdapter(SellerPreferencesModelAdapter());
  Hive.registerAdapter(PermissionStatusModelAdapter());
  Hive.registerAdapter(SavedAddressModelAdapter());
  // Hive.registerAdapter(CouponModelAdapter()); // ✅ Uncomment after running build_runner

  // 3. Initialize Dependency Injection أولاً
  await di.init();

  // 4. تهيئة نسخة الـ Cache الموجودة داخل الحاوية (sl)
  await di.sl<LocalCacheService>().init();

  // 5. Initialize Network Monitor for automatic slow network detection
  await NetworkMonitor.instance.initialize();

  runApp(const MyApp());
}
