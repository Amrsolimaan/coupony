import 'dart:io';

import 'package:dio/dio.dart';
import '../../domain/entities/product.dart';
import '../../domain/use_cases/create_product_use_case.dart';
import '../../domain/use_cases/update_product_use_case.dart';
import 'product_attribute_model.dart';
import 'product_image_model.dart';
import 'product_variant_model.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    super.slug,
    super.shortDescription,
    super.description,
    super.productType,
    required super.basePrice,
    super.compareAtPrice,
    super.currency,
    super.sku,
    super.status,
    super.isFeatured,
    super.categoryIds,
    super.images,
    super.variants,
    super.createdAt,
    super.updatedAt,
  });

  // ════════════════════════════════════════════════════════
  // FROM JSON
  // ════════════════════════════════════════════════════════

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List<dynamic>? ?? [];
    final images = rawImages
        .map((i) => ProductImageModel.fromJson(i as Map<String, dynamic>))
        .toList();

    final rawVariants = json['variants'] as List<dynamic>? ?? [];
    final variants = rawVariants
        .map((v) => ProductVariantModel.fromJson(v as Map<String, dynamic>))
        .toList();

    final rawCategoryIds = json['category_ids'] as List<dynamic>? ?? [];
    final categoryIds =
        rawCategoryIds.map((id) => (id as num).toInt()).toList();

    return ProductModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      shortDescription: json['short_description'] as String? ?? '',
      description: json['description'] as String? ?? '',
      productType: json['product_type'] as String? ?? 'standard',
      basePrice: _parseDouble(json['base_price']),
      compareAtPrice: _parseDouble(json['compare_at_price']),
      currency: json['currency'] as String? ?? 'EGP',
      sku: json['sku'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      isFeatured: _parseBool(json['is_featured']),
      categoryIds: categoryIds,
      images: images,
      variants: variants,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  // ════════════════════════════════════════════════════════
  // TO FORM DATA — POST /stores/{id}/products (create)
  // ════════════════════════════════════════════════════════

  static Future<FormData> toCreateFormData(CreateProductParams p) async {
    final fields = <MapEntry<String, String>>[];
    final files = <MapEntry<String, MultipartFile>>[];

    // ── Basic fields ──────────────────────────────────────
    fields.addAll([
      MapEntry('title', p.title),
      MapEntry('slug', p.slug),
      MapEntry('short_description', p.shortDescription),
      MapEntry('description', p.description),
      MapEntry('product_type', p.productType),
      MapEntry('base_price', p.basePrice.toStringAsFixed(2)),
      MapEntry('compare_at_price', p.compareAtPrice.toStringAsFixed(2)),
      MapEntry('currency', p.currency),
      MapEntry('sku', p.sku),
      MapEntry('status', p.status),
      MapEntry('is_featured', p.isFeatured ? '1' : '0'),
    ]);

    // ── Category IDs ──────────────────────────────────────
    for (var i = 0; i < p.categoryIds.length; i++) {
      fields.add(MapEntry('category_ids[$i]', p.categoryIds[i].toString()));
    }

    // ── Images ────────────────────────────────────────────
    for (var i = 0; i < p.images.length; i++) {
      final img = p.images[i];
      fields.addAll([
        MapEntry('images[$i][sort_order]', img.sortOrder.toString()),
        MapEntry('images[$i][is_primary]', img.isPrimary ? '1' : '0'),
      ]);
      files.add(MapEntry(
        'images[$i][file]',
        await MultipartFile.fromFile(
          img.file.path,
          filename: img.file.path.split(Platform.pathSeparator).last,
        ),
      ));
    }

    // ── Variants ──────────────────────────────────────────
    for (var i = 0; i < p.variants.length; i++) {
      final v = p.variants[i];
      fields.addAll([
        MapEntry('variants[$i][title]', v.title),
        MapEntry('variants[$i][option_summary]', v.optionSummary),
        MapEntry('variants[$i][sku]', v.sku),
        MapEntry('variants[$i][barcode]', v.barcode),
        MapEntry('variants[$i][price]', v.price.toStringAsFixed(2)),
        MapEntry('variants[$i][compare_at_price]',
            v.compareAtPrice.toStringAsFixed(2)),
        MapEntry('variants[$i][currency]', v.currency),
        MapEntry('variants[$i][sort_order]', v.sortOrder.toString()),
        MapEntry('variants[$i][is_default]', v.isDefault ? '1' : '0'),
        MapEntry('variants[$i][is_active]', v.isActive ? '1' : '0'),
      ]);

      for (var j = 0; j < v.attributes.length; j++) {
        final attr = v.attributes[j];
        fields.addAll([
          MapEntry(
              'variants[$i][attributes][$j][attribute_name]', attr.attributeName),
          MapEntry(
              'variants[$i][attributes][$j][attribute_value]', attr.attributeValue),
          MapEntry(
              'variants[$i][attributes][$j][sort_order]', attr.sortOrder.toString()),
        ]);
      }
    }

    return FormData()
      ..fields.addAll(fields)
      ..files.addAll(files);
  }

  // ════════════════════════════════════════════════════════
  // TO FORM DATA — POST + _method=PATCH for status update
  // ════════════════════════════════════════════════════════

  static FormData toStatusFormData(String status) {
    return FormData.fromMap({
      '_method': 'PATCH',
      'status': status,
    });
  }

  // ════════════════════════════════════════════════════════
  // TO JSON — PUT /stores/{id}/products/{id} (full update)
  // ════════════════════════════════════════════════════════

  static Map<String, dynamic> toUpdateJson(UpdateProductParams p) {
    final data = <String, dynamic>{};

    if (p.title != null) data['title'] = p.title;
    if (p.slug != null) data['slug'] = p.slug;
    if (p.shortDescription != null) {
      data['short_description'] = p.shortDescription;
    }
    if (p.description != null) data['description'] = p.description;
    if (p.status != null) data['status'] = p.status;
    if (p.isFeatured != null) data['is_featured'] = p.isFeatured;
    if (p.categoryIds != null) data['category_ids'] = p.categoryIds;

    if (p.variants != null) {
      data['variants'] = p.variants!
          .map((v) => ProductVariantModel(
                id: '',
                title: v.title,
                optionSummary: v.optionSummary,
                sku: v.sku,
                barcode: v.barcode,
                price: v.price,
                compareAtPrice: v.compareAtPrice,
                currency: v.currency,
                sortOrder: v.sortOrder,
                isDefault: v.isDefault,
                isActive: v.isActive,
                attributes: v.attributes
                    .map((a) => ProductAttributeModel(
                          attributeName: a.attributeName,
                          attributeValue: a.attributeValue,
                          sortOrder: a.sortOrder,
                        ))
                    .toList(),
              ).toJson())
          .toList();
    }

    return data;
  }

  // ════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }
}
