import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/entities/review.dart';
import 'package:my_app/domain/usecases/review/getStoreReviews.dart';
import 'package:my_app/domain/usecases/review/leaveReview.dart';
import 'package:flutter/foundation.dart';

// ViewModel để quản lý logic giao diện cho chức năng đánh giá
class ReviewViewModel extends ChangeNotifier {
  final LeaveReview leaveReview;
  final GetStoreReviews getStoreReviews;

  ReviewViewModel({
    required this.leaveReview,
    required this.getStoreReviews,
  });

  // Trạng thái tải
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Danh sách đánh giá
  List<Review> _reviews = [];
  List<Review> get reviews => _reviews;

  // Thông báo lỗi
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Gửi đánh giá mới
  Future<void> submitReview({
    required String storeId,
    required int rating,
    String? comment,
    List<String> imagePaths = const [],
    required String token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await leaveReview.call(
        storeId: storeId,
        rating: rating,
        comment: comment,
        imagePaths: imagePaths,
        token: token,
      );

      result.fold(
        (failure) => _errorMessage = _mapFailureToMessage(failure),
        (review) {
          _reviews.add(review); // Thêm đánh giá mới vào danh sách
          _errorMessage = null;
        },
      );
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi không xác định: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy danh sách đánh giá của cửa hàng
  Future<void> fetchStoreReviews({
    required String storeId,
    required int page,
    required String token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await getStoreReviews.call(
        storeId: storeId,
        page: page,
        token: token,
      );

      result.fold(
        (failure) => _errorMessage = _mapFailureToMessage(failure),
        (reviews) {
          if (page == 1) {
            _reviews = reviews; // Đặt lại danh sách nếu là trang đầu
          } else {
            _reviews.addAll(reviews); // Thêm vào danh sách nếu là các trang tiếp theo
          }
          _errorMessage = null;
        },
      );
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi không xác định: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ánh xạ lỗi thành thông báo người dùng
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'Đã xảy ra lỗi không xác định';
  }

  // Xóa thông báo lỗi
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}