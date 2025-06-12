// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/repositories/storeRepository.dart';
import '../../entities/store.dart';

class GetStores {
  final StoreRepository repository;

  GetStores(this.repository);

  Future<Either<Failure, List<Store>>> call() async {
    final result = await repository.getStores();
    result.fold(
      (failure) => debugPrint('  Failure: ${failure.message}'),
      (stores) {
        debugPrint('  Stores count: ${stores.length}');
      },
    );
    return result;
  }
}