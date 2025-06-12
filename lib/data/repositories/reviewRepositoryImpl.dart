import 'package:dartz/dartz.dart';
import '../../domain/entities/review.dart';
import 'package:my_app/domain/repositories/reviewRepository.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/data/datasources/review/reviewDatasource.dart';

// Triển khai repository cho đánh giá, xử lý logic giao tiếp với data source
class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewDataSource dataSource;

  ReviewRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<Either<Failure, Review>> leaveReview({
    required String storeId,
    required int rating,
    String? comment,
    List<String> imagePaths = const [],
    required String token,
  }) async {
    try {
      // Gửi đánh giá qua data source
      final review = await dataSource.leaveReview(
        storeId: storeId,
        rating: rating,
        comment: comment,
        imagePaths: imagePaths,
        token: token,
      );
      return Right(review);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getStoreReviews({
    required String storeId,
    required int page,
    required String token,
  }) async {
    try {
      // Lấy danh sách đánh giá qua data source
      final reviews = await dataSource.getStoreReviews(
        storeId: storeId,
        page: page,
        token: token,
      );
      return Right(reviews);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}