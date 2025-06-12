import 'package:dartz/dartz.dart';
import 'package:my_app/domain/entities/review.dart';
import 'package:my_app/domain/repositories/reviewRepository.dart';
import 'package:my_app/core/errors/failures.dart';

// Use case để gửi một đánh giá mới
class LeaveReview {
  final ReviewRepository repository;

  LeaveReview(this.repository);

  // Gọi phương thức gửi đánh giá từ repository
  Future<Either<Failure, Review>> call({
    required String storeId,
    required int rating,
    String? comment,
    List<String> imagePaths = const [],
    required String token,
  }) {
    return repository.leaveReview(
      storeId: storeId,
      rating: rating,
      comment: comment,
      imagePaths: imagePaths,
      token: token,
    );
  }
}