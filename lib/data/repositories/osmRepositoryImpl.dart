import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/data/datasources/osm/osmDatasource.dart';
import 'package:my_app/domain/entities/searchResult.dart';
import 'package:my_app/domain/repositories/osmRepository.dart';

class OSMRepositoryImpl implements OSMRepository {
  final OSMDataSource dataSource;

  OSMRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<SearchResult>>> searchPlaces(String query) async {
    try {
      final results = await dataSource.searchPlaces(query);
      return Right(results); // Trả về danh sách SearchResult
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}