import 'package:cloud_firestore/cloud_firestore.dart';

enum FlashcardDifficulty { easy, medium, hard }

class FlashcardModel {
  final String id;
  final String noteId;
  final String userId;
  final String front;
  final String back;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FlashcardDifficulty difficulty;
  final int reviewCount;
  final int correctCount;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;
  final double easeFactor;
  final int interval;
  final List<String> tags;
  final bool isActive;

  FlashcardModel({
    required this.id,
    required this.noteId,
    required this.userId,
    required this.front,
    required this.back,
    required this.createdAt,
    required this.updatedAt,
    this.difficulty = FlashcardDifficulty.medium,
    this.reviewCount = 0,
    this.correctCount = 0,
    this.lastReviewedAt,
    this.nextReviewAt,
    this.easeFactor = 2.5,
    this.interval = 1,
    this.tags = const [],
    this.isActive = true,
  });

  factory FlashcardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FlashcardModel(
      id: doc.id,
      noteId: data['noteId'] ?? '',
      userId: data['userId'] ?? '',
      front: data['front'] ?? '',
      back: data['back'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      difficulty: FlashcardDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == data['difficulty'],
        orElse: () => FlashcardDifficulty.medium,
      ),
      reviewCount: data['reviewCount'] ?? 0,
      correctCount: data['correctCount'] ?? 0,
      lastReviewedAt: (data['lastReviewedAt'] as Timestamp?)?.toDate(),
      nextReviewAt: (data['nextReviewAt'] as Timestamp?)?.toDate(),
      easeFactor: (data['easeFactor'] ?? 2.5).toDouble(),
      interval: data['interval'] ?? 1,
      tags: List<String>.from(data['tags'] ?? []),
      isActive: data['isActive'] ?? true,
    );
  }

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'] ?? '',
      noteId: json['noteId'] ?? '',
      userId: json['userId'] ?? '',
      front: json['front'] ?? '',
      back: json['back'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      difficulty: FlashcardDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
        orElse: () => FlashcardDifficulty.medium,
      ),
      reviewCount: json['reviewCount'] ?? 0,
      correctCount: json['correctCount'] ?? 0,
      lastReviewedAt: json['lastReviewedAt'] != null 
          ? DateTime.tryParse(json['lastReviewedAt'])
          : null,
      nextReviewAt: json['nextReviewAt'] != null 
          ? DateTime.tryParse(json['nextReviewAt'])
          : null,
      easeFactor: (json['easeFactor'] ?? 2.5).toDouble(),
      interval: json['interval'] ?? 1,
      tags: List<String>.from(json['tags'] ?? []),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noteId': noteId,
      'userId': userId,
      'front': front,
      'back': back,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'difficulty': difficulty.toString().split('.').last,
      'reviewCount': reviewCount,
      'correctCount': correctCount,
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'nextReviewAt': nextReviewAt?.toIso8601String(),
      'easeFactor': easeFactor,
      'interval': interval,
      'tags': tags,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'noteId': noteId,
      'userId': userId,
      'front': front,
      'back': back,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'difficulty': difficulty.toString().split('.').last,
      'reviewCount': reviewCount,
      'correctCount': correctCount,
      'lastReviewedAt': lastReviewedAt != null 
          ? Timestamp.fromDate(lastReviewedAt!)
          : null,
      'nextReviewAt': nextReviewAt != null 
          ? Timestamp.fromDate(nextReviewAt!)
          : null,
      'easeFactor': easeFactor,
      'interval': interval,
      'tags': tags,
      'isActive': isActive,
    };
  }

  FlashcardModel copyWith({
    String? id,
    String? noteId,
    String? userId,
    String? front,
    String? back,
    DateTime? createdAt,
    DateTime? updatedAt,
    FlashcardDifficulty? difficulty,
    int? reviewCount,
    int? correctCount,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
    double? easeFactor,
    int? interval,
    List<String>? tags,
    bool? isActive,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      userId: userId ?? this.userId,
      front: front ?? this.front,
      back: back ?? this.back,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      difficulty: difficulty ?? this.difficulty,
      reviewCount: reviewCount ?? this.reviewCount,
      correctCount: correctCount ?? this.correctCount,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
    );
  }

  double get accuracyPercentage {
    if (reviewCount == 0) return 0.0;
    return (correctCount / reviewCount) * 100;
  }

  String get difficultyIcon {
    switch (difficulty) {
      case FlashcardDifficulty.easy:
        return '🟢';
      case FlashcardDifficulty.medium:
        return '🟡';
      case FlashcardDifficulty.hard:
        return '🔴';
    }
  }

  String get difficultyText {
    switch (difficulty) {
      case FlashcardDifficulty.easy:
        return 'Easy';
      case FlashcardDifficulty.medium:
        return 'Medium';
      case FlashcardDifficulty.hard:
        return 'Hard';
    }
  }

  bool get isDueForReview {
    if (nextReviewAt == null) return true;
    return DateTime.now().isAfter(nextReviewAt!);
  }

  String get frontPreview {
    const maxLength = 50;
    if (front.length <= maxLength) return front;
    return '${front.substring(0, maxLength)}...';
  }

  String get backPreview {
    const maxLength = 50;
    if (back.length <= maxLength) return back;
    return '${back.substring(0, maxLength)}...';
  }

  // Spaced repetition algorithm (simplified SM-2)
  FlashcardModel updateAfterReview({required bool isCorrect, int? quality}) {
    final now = DateTime.now();
    final newReviewCount = reviewCount + 1;
    final newCorrectCount = correctCount + (isCorrect ? 1 : 0);
    
    // SM-2 algorithm parameters
    const minimumEaseFactor = 1.3;
    const maximumEaseFactor = 2.5;
    final q = quality ?? (isCorrect ? 5 : 2); // 0-5 scale
    
    double newEaseFactor = easeFactor;
    int newInterval = interval;
    
    if (isCorrect) {
      if (reviewCount == 0) {
        newInterval = 1;
      } else if (reviewCount == 1) {
        newInterval = 6;
      } else {
        newInterval = (interval * easeFactor).round();
      }
      
      newEaseFactor = easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
      newEaseFactor = newEaseFactor.clamp(minimumEaseFactor, maximumEaseFactor);
    } else {
      newInterval = 1;
      newEaseFactor = (easeFactor - 0.2).clamp(minimumEaseFactor, maximumEaseFactor);
    }
    
    final nextReview = now.add(Duration(days: newInterval));

    return copyWith(
      reviewCount: newReviewCount,
      correctCount: newCorrectCount,
      lastReviewedAt: now,
      nextReviewAt: nextReview,
      easeFactor: newEaseFactor,
      interval: newInterval,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'FlashcardModel(id: $id, front: $frontPreview, accuracy: ${accuracyPercentage.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlashcardModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}