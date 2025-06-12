import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/repositories/storeRepository.dart';

class DeleteStore {
  final StoreRepository repository;

  DeleteStore(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteStore(id);
  }
}