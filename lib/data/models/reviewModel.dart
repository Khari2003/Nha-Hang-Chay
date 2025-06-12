import '../../domain/entities/review.dart';

// Model ánh xạ dữ liệu đánh giá từ/tới JSON, kế thừa từ entity Review
class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.storeId,
    super.comment,
    required super.rating,
    required super.images,
    super.reply,
    required super.date,
  });

  // Chuyển đổi từ JSON sang ReviewModel
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id']?.toString() ?? '', // Đảm bảo _id là chuỗi
      userId: json['user']?.toString() ?? '', // Backend trả về user là ObjectId
      userName: json['userName'] ?? '',
      storeId: json['store']?.toString() ?? '',
      comment: json['comment'],
      rating: (json['rating'] as num).toInt(), // Đảm bảo rating là số nguyên
      images: List<String>.from(json['images'] ?? []),
      reply: json['reply'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Chuyển đổi từ ReviewModel sang JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'userName': userName,
      'store': storeId,
      'comment': comment,
      'rating': rating,
      'images': images,
      'reply': reply,
      'date': date.toIso8601String(),
    };
  }
}