import 'package:cloud_firestore/cloud_firestore.dart';

class NotebookModel {
  final String id;
  final String title;
  final String description;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String color;
  final String icon;
  final int notesCount;
  final List<String> tags;
  final bool isFavorite;
  final DateTime? lastAccessedAt;

  NotebookModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.color = '#6C63FF',
    this.icon = '📚',
    this.notesCount = 0,
    this.tags = const [],
    this.isFavorite = false,
    this.lastAccessedAt,
  });

  factory NotebookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotebookModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      color: data['color'] ?? '#6C63FF',
      icon: data['icon'] ?? '📚',
      notesCount: data['notesCount'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      isFavorite: data['isFavorite'] ?? false,
      lastAccessedAt: (data['lastAccessedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory NotebookModel.fromJson(Map<String, dynamic> json) {
    return NotebookModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      color: json['color'] ?? '#6C63FF',
      icon: json['icon'] ?? '📚',
      notesCount: json['notesCount'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
      lastAccessedAt: json['lastAccessedAt'] != null 
          ? DateTime.tryParse(json['lastAccessedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'color': color,
      'icon': icon,
      'notesCount': notesCount,
      'tags': tags,
      'isFavorite': isFavorite,
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'color': color,
      'icon': icon,
      'notesCount': notesCount,
      'tags': tags,
      'isFavorite': isFavorite,
      'lastAccessedAt': lastAccessedAt != null 
          ? Timestamp.fromDate(lastAccessedAt!)
          : null,
    };
  }

  NotebookModel copyWith({
    String? id,
    String? title,
    String? description,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? color,
    String? icon,
    int? notesCount,
    List<String>? tags,
    bool? isFavorite,
    DateTime? lastAccessedAt,
  }) {
    return NotebookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      notesCount: notesCount ?? this.notesCount,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
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

  String get notesCountText {
    if (notesCount == 0) return 'No notes';
    if (notesCount == 1) return '1 note';
    return '$notesCount notes';
  }

  @override
  String toString() {
    return 'NotebookModel(id: $id, title: $title, notesCount: $notesCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotebookModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}