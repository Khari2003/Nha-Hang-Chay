// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/entities/store.dart';

abstract class StoreRepository {
  Future<Either<Failure, List<Store>>> getStores();
}