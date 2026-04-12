import 'dart:io';

import 'package:coupony/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/product.dart';
import '../repositories/seller_products_repository.dart';

// ════════════════════════════════════════════════════════
// INPUT DTOs
// ════════════════════════════════════════════════════════

class ProductImageInput {
  final File file;
  final int sortOrder;
  final bool isPrimary;

  const ProductImageInput({
    required this.file,
    this.sortOrder = 0,
    this.isPrimary = false,
  });
}

class ProductAttributeInput {
  final String attributeName;
  final String attributeValue;
  final int sortOrder;

  const ProductAttributeInput({
    required this.attributeName,
    required this.attributeValue,
    this.sortOrder = 0,
  });
}

class ProductVariantInput {
  final String title;
  final String optionSummary;
  final String sku;
  final String barcode;
  final double price;
  final double compareAtPrice;
  final String currency;
  final int sortOrder;
  final bool isDefault;
  final bool isActive;
  final List<ProductAttributeInput> attributes;

  const ProductVariantInput({
    required this.title,
    this.optionSummary = '',
    this.sku = '',
    this.barcode = '',
    required this.price,
    this.compareAtPrice = 0.0,
    this.currency = 'EGP',
    this.sortOrder = 0,
    this.isDefault = false,
    this.isActive = true,
    this.attributes = const [],
  });
}

// ════════════════════════════════════════════════════════
// PARAMS
// ════════════════════════════════════════════════════════

class CreateProductParams {
  final String storeId;
  final String title;
  final String slug;
  final String shortDescription;
  final String description;
  final String productType;
  final double basePrice;
  final double compareAtPrice;
  final String currency;
  final String sku;
  final String status;
  final bool isFeatured;
  final List<int> categoryIds;
  final List<ProductImageInput> images;
  final List<ProductVariantInput> variants;

  const CreateProductParams({
    required this.storeId,
    required this.title,
    this.slug = '',
    this.shortDescription = '',
    this.description = '',
    this.productType = 'standard',
    required this.basePrice,
    this.compareAtPrice = 0.0,
    this.currency = 'EGP',
    this.sku = '',
    this.status = 'draft',
    this.isFeatured = false,
    this.categoryIds = const [],
    this.images = const [],
    this.variants = const [],
  });
}

// ════════════════════════════════════════════════════════
// USE CASE
// ════════════════════════════════════════════════════════

class CreateProductUseCase {
  final SellerProductsRepository repository;

  const CreateProductUseCase(this.repository);

  Future<Either<Failure, Product>> call(CreateProductParams params) {
    return repository.createProduct(params);
  }
}
