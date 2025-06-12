import 'package:dartz/dartz.dart';
import '../entities/review.dart';
import 'package:my_app/core/errors/failures.dart';

// Interface định nghĩa các phương thức trừu tượng cho repository đánh giá
abstract class ReviewRepository {
  // Gửi đánh giá mới cho cửa hàng
  Future<Either<Failure, Review>> leaveReview({
    required String storeId, // ID cửa hàng
    required int rating, // Điểm số
    String? comment, // Bình luận
    List<String> imagePaths, // Danh sách đường dẫn hình ảnh
    required String token, // Token xác thực
  });

  // Lấy danh sách đánh giá của một cửa hàng theo trang
  Future<Either<Failure, List<Review>>> getStoreReviews({
    required String storeId, // ID cửa hàng
    required int page, // Trang hiện tại
    required String token, // Token xác thực
  });
}