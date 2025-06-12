// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/repositories/storeRepository.dart';
import '../../entities/store.dart';

class CreateStore {
  final StoreRepository repository;

  CreateStore(this.repository);

  Future<Either<Failure, Store>> call(Store store) async {
    final result = await repository.createStore(store);
    result.fold(
      (failure) => debugPrint('Failure: ${failure.message}'),
      (store) => debugPrint('Store created: ${store.name}'),
    );
    return result;
  }
}