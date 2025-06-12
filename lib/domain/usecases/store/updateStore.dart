import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/entities/store.dart';
import 'package:my_app/domain/repositories/storeRepository.dart';

class UpdateStore {
  final StoreRepository repository;

  UpdateStore(this.repository);

  Future<Either<Failure, Store>> call(String id, Store store) async {
    return await repository.updateStore(id, store);
  }
}