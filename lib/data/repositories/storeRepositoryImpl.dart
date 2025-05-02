// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/data/datasources/store/storeDatasource.dart';
import 'package:my_app/domain/repositories/storeRepository.dart';
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
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}