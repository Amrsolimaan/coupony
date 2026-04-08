import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for managing saved email addresses for "Remember Me" functionality
/// Stores up to 5 most recent emails in chronological order (newest first)
class SavedEmailsService {
  final SharedPreferences _prefs;
  static const String _savedEmailsKey = 'saved_login_emails';
  static const int _maxSavedEmails = 5;

  SavedEmailsService(this._prefs);

  /// Get list of saved emails (newest first)
  List<String> getSavedEmails() {
    final jsonString = _prefs.getString(_savedEmailsKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    
    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  /// Save an email to the list (adds to top, removes duplicates, keeps max 5)
  Future<void> saveEmail(String email) async {
    if (email.trim().isEmpty) return;
    
    final emails = getSavedEmails();
    
    // Remove if already exists (to move it to top)
    emails.remove(email);
    
    // Add to beginning (most recent)
    emails.insert(0, email);
    
    // Keep only last 5
    if (emails.length > _maxSavedEmails) {
      emails.removeRange(_maxSavedEmails, emails.length);
    }
    
    await _prefs.setString(_savedEmailsKey, json.encode(emails));
  }

  /// Remove a specific email from the list
  Future<void> removeEmail(String email) async {
    final emails = getSavedEmails();
    emails.remove(email);
    await _prefs.setString(_savedEmailsKey, json.encode(emails));
  }

  /// Clear all saved emails
  Future<void> clearAllEmails() async {
    await _prefs.remove(_savedEmailsKey);
  }

  /// Get the most recent email (for autofill)
  String? getLastEmail() {
    final emails = getSavedEmails();
    return emails.isNotEmpty ? emails.first : null;
  }
}
