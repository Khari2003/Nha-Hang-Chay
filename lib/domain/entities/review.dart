import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String storeId;
  final String? comment;
  final int rating;
  final List<String> images;
  final String? reply;
  final DateTime date;

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

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'],
      userId: json['user'],
      userName: json['userName'] ?? '',
      storeId: json['store'],
      comment: json['comment'],
      rating: json['rating'],
      images: List<String>.from(json['images'] ?? []),
      reply: json['reply'],
      date: DateTime.parse(json['date']),
    );
  }

  @override
  List<Object?> get props => [id, userId, userName, storeId, comment, rating, images, reply, date];
}