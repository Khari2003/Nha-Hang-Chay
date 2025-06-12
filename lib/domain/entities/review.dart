import 'package:equatable/equatable.dart';

// Entity đại diện cho một đánh giá (review) của người dùng về cửa hàng
class Review extends Equatable {
  final String id; // ID duy nhất của đánh giá
  final String userId; // ID của người dùng gửi đánh giá
  final String userName; // Tên người dùng
  final String storeId; // ID của cửa hàng được đánh giá
  final String? comment; // Bình luận (tùy chọn)
  final int rating; // Điểm số từ 1 đến 5
  final List<String> images; // Danh sách URL hoặc đường dẫn hình ảnh
  final String? reply; // Phản hồi từ chủ cửa hàng (tùy chọn)
  final DateTime date; // Ngày tạo đánh giá

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.storeId,
    this.comment,
    required this.rating,
    required this.images,
    this.reply,
    required this.date,
  });

  @override
  List<Object?> get props => [id, userId, userName, storeId, comment, rating, images, reply, date];
}