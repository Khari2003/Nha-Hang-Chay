// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/entities/searchResult.dart';

abstract class OSMRepository {
  Future<Either<Failure, List<SearchResult>>> searchPlaces(String query);
}