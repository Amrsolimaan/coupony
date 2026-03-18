import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleCubit extends Cubit<Locale> {
  final FlutterSecureStorage storage;
  static const String _localeKey = 'app_locale';

  LocaleCubit(this.storage) : super(const Locale('ar')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final savedLocale = await storage.read(key: _localeKey);
    if (savedLocale != null) {
      emit(Locale(savedLocale));
    }
  }

  Future<void> changeLocale(String languageCode) async {
    await storage.write(key: _localeKey, value: languageCode);
    emit(Locale(languageCode));
  }

  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'ar' ? 'en' : 'ar';
    await changeLocale(newLocale);
  }

  bool get isArabic => state.languageCode == 'ar';
  bool get isRTL => isArabic;
}