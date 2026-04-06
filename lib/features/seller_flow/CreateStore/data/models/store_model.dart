import 'dart:io';

import 'package:dio/dio.dart';
import '../../domain/entities/social_link_entity.dart';
import '../../domain/entities/store_entity.dart';
import '../../domain/use_cases/create_store_use_case.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.name,
    required super.description,
    required super.email,
    required super.phone,
    required super.addressLine1,
    required super.city,
    required super.latitude,
    required super.longitude,
    required super.categories,
    super.socials,
    super.verificationDocs,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      addressLine1: json['address_line1'] as String? ?? '',
      city: json['city'] as String? ?? '',
      latitude: json['latitude']?.toString() ?? '0.0',
      longitude: json['longitude']?.toString() ?? '0.0',
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .toList(),
      socials: (json['socials'] as List<dynamic>? ?? [])
          .map((e) => SocialLinkEntity(
                socialId: (e as Map<String, dynamic>)['social_id'] as int,
                link: e['link'] as String,
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'email': email,
      'phone': phone,
      'address_line1': addressLine1,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'categories': categories,
      'socials': socials
          .map((s) => {'social_id': s.socialId, 'link': s.link})
          .toList(),
    };
  }

  /// Builds [FormData] for multipart/form-data submission.
  ///
  /// Field keys match the /api/v1/stores multipart contract exactly.
  /// Files are added via [MultipartFile.fromFile] — async method.
  static Future<FormData> toFormData(CreateStoreParams params) async {
    final formData = FormData();

    // ── Scalar fields ──────────────────────────────────────────────────────
    formData.fields.addAll([
      MapEntry('name', params.name),
      MapEntry('phone', params.phone),
      MapEntry('description', params.description),
      MapEntry('latitude', params.latitude),
      MapEntry('longitude', params.longitude),
      MapEntry('city', params.city),
      MapEntry('address_line1', params.addressLine1),
    ]);

    // ── Category sent as an array (categories[]) ───────────────────────────
    formData.fields.add(MapEntry('categories[]', params.categoryId.toString()));

    // ── Socials (array of objects) ─────────────────────────────────────────
    for (var i = 0; i < params.socials.length; i++) {
      final social = params.socials[i];
      formData.fields.add(MapEntry('socials[$i][social_id]', social.socialId.toString()));
      formData.fields.add(MapEntry('socials[$i][link]', social.link));
    }

    // ── Logo ───────────────────────────────────────────────────────────────
    if (params.logo != null) {
      formData.files.add(MapEntry(
        'logo_url',
        await MultipartFile.fromFile(
          params.logo!.path,
          filename: _filename(params.logo!),
        ),
      ));
    }

    // ── Verification documents ─────────────────────────────────────────────
    await _addFileField(formData, 'verification_docs[commercial_register]', params.commercialRegister);
    await _addFileField(formData, 'verification_docs[tax_card]', params.taxCard);
    await _addFileField(formData, 'verification_docs[id_card_front]', params.idCardFront);
    await _addFileField(formData, 'verification_docs[id_card_back]', params.idCardBack);

    return formData;
  }

  static Future<void> _addFileField(FormData formData, String key, File? file) async {
    if (file == null) return;
    formData.files.add(MapEntry(
      key,
      await MultipartFile.fromFile(file.path, filename: _filename(file)),
    ));
  }

  static String _filename(File file) {
    return file.path.split(RegExp(r'[/\\]')).last;
  }
}
