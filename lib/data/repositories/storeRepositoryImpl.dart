import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/data/datasources/store/storeDatasource.dart';
import 'package:my_app/domain/repositories/storeRepository.dart';
import 'package:my_app/data/models/storeModel.dart';
import '../../domain/entities/store.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreDataSource dataSource;

  StoreRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Store>>> getStores() async {
    try {
      final stores = await dataSource.getStores();
      return Right(stores);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, Store>> createStore(Store store) async {
    try {
      final createdStore = await dataSource.createStore(store as StoreModel);
      return Right(createdStore);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, Store>> updateStore(String id, Store store) async {
    try {
      final updatedStore = await dataSource.updateStore(id, store as StoreModel);
      return Right(updatedStore);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStore(String id) async {
    try {
      await dataSource.deleteStore(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}