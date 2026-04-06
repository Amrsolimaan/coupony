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

abstract class CreateStoreRemoteDataSource {
  Future<bool> createStore(CreateStoreParams params);
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
