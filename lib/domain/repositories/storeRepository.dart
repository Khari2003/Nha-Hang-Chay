import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/entities/store.dart';

abstract class StoreRepository {
  Future<Either<Failure, List<Store>>> getStores();
  Future<Either<Failure, Store>> createStore(Store store);
  Future<Either<Failure, Store>> updateStore(String id, Store store);
  Future<Either<Failure, void>> deleteStore(String id);
}