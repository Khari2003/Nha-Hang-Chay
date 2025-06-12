import 'package:dartz/dartz.dart';
import 'package:my_app/domain/entities/review.dart';
import 'package:my_app/domain/repositories/reviewRepository.dart';
import 'package:my_app/core/errors/failures.dart';

// Use case để lấy danh sách đánh giá của một cửa hàng
class GetStoreReviews {
  final ReviewRepository repository;

  GetStoreReviews(this.repository);

  // Gọi phương thức lấy đánh giá từ repository
  Future<Either<Failure, List<Review>>> call({
    required String storeId,
    required int page,
    required String token,
  }) {
    return repository.getStoreReviews(
      storeId: storeId,
      page: page,
      token: token,
    );
  }
}