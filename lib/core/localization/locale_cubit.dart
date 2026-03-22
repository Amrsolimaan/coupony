import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:ui' as ui;

class LocaleCubit extends Cubit<Locale> {
  final FlutterSecureStorage storage;
  static const String _localeKey = 'app_locale';
  static const List<String> _supportedLanguages = ['ar', 'en'];

  LocaleCubit(this.storage) : super(_getInitialLocale()) {
    _loadSavedLocale();
  }

  /// Get initial locale based on system language
  static Locale _getInitialLocale() {
    // Get system locale
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    final systemLanguageCode = systemLocale.languageCode;

    // Check if system language is supported
    if (_supportedLanguages.contains(systemLanguageCode)) {
      return Locale(systemLanguageCode);
    }

    // Fallback to Arabic if system language is not supported
    return const Locale('ar');
  }

  Future<void> _loadSavedLocale() async {
    final savedLocale = await storage.read(key: _localeKey);
    if (savedLocale != null && _supportedLanguages.contains(savedLocale)) {
      emit(Locale(savedLocale));
    }
    // If no saved locale, keep the initial system locale
  }

  /// Check if user has manually saved a language preference
  Future<bool> hasManualPreference() async {
    final savedLocale = await storage.read(key: _localeKey);
    return savedLocale != null;
  }

  /// Update locale based on system language change (only if no manual preference)
  Future<void> updateFromSystemLocale(Locale systemLocale) async {
    // Check if user has manually set a language
    final hasManual = await hasManualPreference();
    if (hasManual) {
      // User has a preference, don't override it
      return;
    }

    // Update to system language if supported
    final systemLanguageCode = systemLocale.languageCode;
    if (_supportedLanguages.contains(systemLanguageCode)) {
      emit(Locale(systemLanguageCode));
    } else {
      // Fallback to Arabic if system language not supported
      emit(const Locale('ar'));
    }
  }

  Future<void> changeLocale(String languageCode) async {
    if (!_supportedLanguages.contains(languageCode)) {
      return; // Ignore unsupported languages
    }
    await storage.write(key: _localeKey, value: languageCode);
    emit(Locale(languageCode));
  }

  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'ar' ? 'en' : 'ar';
    await changeLocale(newLocale);
  }

  /// Clear manual preference and revert to system language
  Future<void> clearManualPreference() async {
    await storage.delete(key: _localeKey);
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    await updateFromSystemLocale(systemLocale);
  }

  bool get isArabic => state.languageCode == 'ar';
  bool get isRTL => isArabic;
}
