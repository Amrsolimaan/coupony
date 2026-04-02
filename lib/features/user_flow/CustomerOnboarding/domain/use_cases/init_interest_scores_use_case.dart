import 'package:dartz/dartz.dart';
import 'package:coupony/core/errors/failures.dart';
import 'package:coupony/core/storage/local_cache_service.dart';

class InitInterestScoresUseCase {
  final LocalCacheService cacheService;

  InitInterestScoresUseCase(this.cacheService);

  Future<Either<Failure, void>> call(List<String> categories) {
    return cacheService.initializeCategoryScores(categories);
  }
}
