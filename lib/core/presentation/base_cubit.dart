import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';
import 'base_state.dart';

/// Base Cubit with common error handling and state emission
abstract class BaseCubit<T> extends Cubit<BaseState<T>> {
  BaseCubit() : super(const InitialState());

  /// Helper to emit states based on Either result
  void emitFromEither(
    Either<Failure, T> either, {
    bool isFromCache = false,
  }) {
    either.fold(
      (failure) => emit(ErrorState<T>(failure)),
      (data) => emit(SuccessState<T>(data, isFromCache: isFromCache)),
    );
  }

  /// Safe state emission with try-catch
  void safeEmit(BaseState<T> state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
