// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/entities/searchResult.dart';
import 'package:my_app/domain/repositories/osmRepository.dart';

class SearchPlaces {
  final OSMRepository repository;

  SearchPlaces(this.repository);

  Future<Either<Failure, List<SearchResult>>> call(String query) async {
    return await repository.searchPlaces(query);
  }
}