import 'package:coupony/core/constants/api_constants.dart';
import 'package:coupony/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/social_platform_entity.dart';
import '../../domain/use_cases/create_store_use_case.dart';
import '../models/category_model.dart';
import '../models/social_platform_model.dart';
import '../models/store_model.dart';
import '../../../../auth/data/models/user_store_model.dart';

abstract class CreateStoreRemoteDataSource {
  Future<bool> createStore(CreateStoreParams params);
  Future<bool> updateStore(String storeId, CreateStoreParams params);
  Future<List<UserStoreModel>> getStores();
  Future<List<CategoryEntity>> getCategories();
  Future<List<SocialPlatformEntity>> getSocialPlatforms();
}

class CreateStoreRemoteDataSourceImpl implements CreateStoreRemoteDataSource {
  final DioClient client;
  final Logger logger;

  const CreateStoreRemoteDataSourceImpl({
    required this.client,
    required this.logger,
  });

  @override
  Future<bool> createStore(CreateStoreParams params) async {
    final formData = await StoreModel.toFormData(params);

    final response = await client.post(
      ApiConstants.createStore,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    logger.i('CreateStore response: ${response.statusCode}');
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> updateStore(String storeId, CreateStoreParams params) async {
    final formData = await StoreModel.toFormData(params);

    final response = await client.put(
      ApiConstants.updateStore(storeId),
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    logger.i('UpdateStore response: ${response.statusCode}');
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<List<UserStoreModel>> getStores() async {
    logger.i('📥 GET STORES REQUEST — ${ApiConstants.stores}');
    
    final response = await client.get(ApiConstants.stores);
    final data = response.data as Map<String, dynamic>? ?? {};
    
    logger.i('✅ GET STORES RESPONSE: $data');

    // Parse the response: data.data contains the stores array
    final storesData = data['data'] as Map<String, dynamic>? ?? {};
    final storesList = storesData['data'] as List<dynamic>? ?? [];

    return storesList
        .map((e) => UserStoreModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final response = await client.get(ApiConstants.getCategories);

    final data = response.data;
    List<dynamic> list;

    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic> && data['data'] is List) {
      list = data['data'] as List;
    } else {
      list = [];
    }

    return list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SocialPlatformEntity>> getSocialPlatforms() async {
    final response = await client.get(ApiConstants.getSocials);

    final data = response.data;
    List<dynamic> list;

    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic> && data['data'] is List) {
      list = data['data'] as List;
    } else {
      list = [];
    }

    return list
        .map((e) => SocialPlatformModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
