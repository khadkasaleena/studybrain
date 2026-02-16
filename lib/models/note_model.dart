import 'package:cloud_firestore/cloud_firestore.dart';

enum NoteType { text, image, pdf, voice }

class NoteModel {
  final String id;
  final String title;
  final String content;
  final String notebookId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final NoteType type;
  final List<String> imageUrls;
  final String? fileUrl;
  final String? fileName;
  final List<String> tags;
  final bool isFavorite;
  final String? summary;
  final int flashcardCount;
  final int quizCount;
  final DateTime? lastStudiedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.notebookId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.type = NoteType.text,
    this.imageUrls = const [],
    this.fileUrl,
    this.fileName,
    this.tags = const [],
    this.isFavorite = false,
    this.summary,
    this.flashcardCount = 0,
    this.quizCount = 0,
    this.lastStudiedAt,
  });

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      notebookId: data['notebookId'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: NoteType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => NoteType.text,
      ),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
      tags: List<String>.from(data['tags'] ?? []),
      isFavorite: data['isFavorite'] ?? false,
      summary: data['summary'],
      flashcardCount: data['flashcardCount'] ?? 0,
      quizCount: data['quizCount'] ?? 0,
      lastStudiedAt: (data['lastStudiedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      notebookId: json['notebookId'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      type: NoteType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NoteType.text,
      ),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      tags: List<String>.from(json['tags'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
      summary: json['summary'],
      flashcardCount: json['flashcardCount'] ?? 0,
      quizCount: json['quizCount'] ?? 0,
      lastStudiedAt: json['lastStudiedAt'] != null 
          ? DateTime.tryParse(json['lastStudiedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'notebookId': notebookId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'type': type.toString().split('.').last,
      'imageUrls': imageUrls,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'tags': tags,
      'isFavorite': isFavorite,
      'summary': summary,
      'flashcardCount': flashcardCount,
      'quizCount': quizCount,
      'lastStudiedAt': lastStudiedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'notebookId': notebookId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'type': type.toString().split('.').last,
      'imageUrls': imageUrls,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'tags': tags,
      'isFavorite': isFavorite,
      'summary': summary,
      'flashcardCount': flashcardCount,
      'quizCount': quizCount,
      'lastStudiedAt': lastStudiedAt != null 
          ? Timestamp.fromDate(lastStudiedAt!)
          : null,
    };
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? notebookId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    NoteType? type,
    List<String>? imageUrls,
    String? fileUrl,
    String? fileName,
    List<String>? tags,
    bool? isFavorite,
    String? summary,
    int? flashcardCount,
    int? quizCount,
    DateTime? lastStudiedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      notebookId: notebookId ?? this.notebookId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      imageUrls: imageUrls ?? this.imageUrls,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      summary: summary ?? this.summary,
      flashcardCount: flashcardCount ?? this.flashcardCount,
      quizCount: quizCount ?? this.quizCount,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
    );
  }

  String get typeIcon {
    switch (type) {
      case NoteType.text:
        return '📝';
      case NoteType.image:
        return '🖼️';
      case NoteType.pdf:
        return '📄';
      case NoteType.voice:
        return '🎤';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case NoteType.text:
        return 'Text Note';
      case NoteType.image:
        return 'Image Note';
      case NoteType.pdf:
        return 'PDF Note';
      case NoteType.voice:
        return 'Voice Note';
    }
  }

  String get formattedCreatedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String get contentPreview {
    if (content.isEmpty) return 'No content';
    const maxLength = 100;
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }

  bool get hasMultimedia => imageUrls.isNotEmpty || fileUrl != null;

  int get totalStudyItems => flashcardCount + quizCount;

  @override
  String toString() {
    return 'NoteModel(id: $id, title: $title, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}