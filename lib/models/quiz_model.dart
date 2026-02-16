import 'package:cloud_firestore/cloud_firestore.dart';

enum QuizDifficulty { easy, medium, hard }

class QuizOption {
  final String text;
  final bool isCorrect;
  final String? explanation;

  QuizOption({
    required this.text,
    this.isCorrect = false,
    this.explanation,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      text: json['text'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCorrect': isCorrect,
      'explanation': explanation,
    };
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<QuizOption> options;
  final QuizDifficulty difficulty;
  final String? explanation;
  final List<String> tags;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.difficulty = QuizDifficulty.medium,
    this.explanation,
    this.tags = const [],
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => QuizOption.fromJson(e))
              .toList() ??
          [],
      difficulty: QuizDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
        orElse: () => QuizDifficulty.medium,
      ),
      explanation: json['explanation'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options.map((e) => e.toJson()).toList(),
      'difficulty': difficulty.toString().split('.').last,
      'explanation': explanation,
      'tags': tags,
    };
  }

  QuizOption? get correctOption {
    return options.firstWhere(
      (option) => option.isCorrect,
      orElse: () => options.first,
    );
  }

  String get difficultyIcon {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return '🟢';
      case QuizDifficulty.medium:
        return '🟡';
      case QuizDifficulty.hard:
        return '🔴';
    }
  }

  int get correctAnswerIndex {
    return options.indexWhere((option) => option.isCorrect);
  }
}

class QuizResult {
  final String questionId;
  final int selectedOptionIndex;
  final bool isCorrect;
  final DateTime answeredAt;
  final int timeSpentSeconds;

  QuizResult({
    required this.questionId,
    required this.selectedOptionIndex,
    required this.isCorrect,
    required this.answeredAt,
    this.timeSpentSeconds = 0,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      questionId: json['questionId'] ?? '',
      selectedOptionIndex: json['selectedOptionIndex'] ?? 0,
      isCorrect: json['isCorrect'] ?? false,
      answeredAt: DateTime.tryParse(json['answeredAt'] ?? '') ?? DateTime.now(),
      timeSpentSeconds: json['timeSpentSeconds'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedOptionIndex': selectedOptionIndex,
      'isCorrect': isCorrect,
      'answeredAt': answeredAt.toIso8601String(),
      'timeSpentSeconds': timeSpentSeconds,
    };
  }
}

class QuizModel {
  final String id;
  final String noteId;
  final String userId;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final QuizDifficulty difficulty;
  final int timeLimit; // in minutes, 0 = no limit
  final List<String> tags;
  final bool isActive;
  final int attemptCount;
  final double bestScore;
  final DateTime? lastAttemptAt;

  QuizModel({
    required this.id,
    required this.noteId,
    required this.userId,
    required this.title,
    this.description = '',
    required this.questions,
    required this.createdAt,
    required this.updatedAt,
    this.difficulty = QuizDifficulty.medium,
    this.timeLimit = 0,
    this.tags = const [],
    this.isActive = true,
    this.attemptCount = 0,
    this.bestScore = 0.0,
    this.lastAttemptAt,
  });

  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizModel(
      id: doc.id,
      noteId: data['noteId'] ?? '',
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      questions: (data['questions'] as List<dynamic>?)
              ?.map((e) => QuizQuestion.fromJson(e))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      difficulty: QuizDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == data['difficulty'],
        orElse: () => QuizDifficulty.medium,
      ),
      timeLimit: data['timeLimit'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      isActive: data['isActive'] ?? true,
      attemptCount: data['attemptCount'] ?? 0,
      bestScore: (data['bestScore'] ?? 0.0).toDouble(),
      lastAttemptAt: (data['lastAttemptAt'] as Timestamp?)?.toDate(),
    );
  }

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] ?? '',
      noteId: json['noteId'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => QuizQuestion.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      difficulty: QuizDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
        orElse: () => QuizDifficulty.medium,
      ),
      timeLimit: json['timeLimit'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      isActive: json['isActive'] ?? true,
      attemptCount: json['attemptCount'] ?? 0,
      bestScore: (json['bestScore'] ?? 0.0).toDouble(),
      lastAttemptAt: json['lastAttemptAt'] != null 
          ? DateTime.tryParse(json['lastAttemptAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noteId': noteId,
      'userId': userId,
      'title': title,
      'description': description,
      'questions': questions.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'difficulty': difficulty.toString().split('.').last,
      'timeLimit': timeLimit,
      'tags': tags,
      'isActive': isActive,
      'attemptCount': attemptCount,
      'bestScore': bestScore,
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'noteId': noteId,
      'userId': userId,
      'title': title,
      'description': description,
      'questions': questions.map((e) => e.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'difficulty': difficulty.toString().split('.').last,
      'timeLimit': timeLimit,
      'tags': tags,
      'isActive': isActive,
      'attemptCount': attemptCount,
      'bestScore': bestScore,
      'lastAttemptAt': lastAttemptAt != null 
          ? Timestamp.fromDate(lastAttemptAt!)
          : null,
    };
  }

  QuizModel copyWith({
    String? id,
    String? noteId,
    String? userId,
    String? title,
    String? description,
    List<QuizQuestion>? questions,
    DateTime? createdAt,
    DateTime? updatedAt,
    QuizDifficulty? difficulty,
    int? timeLimit,
    List<String>? tags,
    bool? isActive,
    int? attemptCount,
    double? bestScore,
    DateTime? lastAttemptAt,
  }) {
    return QuizModel(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      difficulty: difficulty ?? this.difficulty,
      timeLimit: timeLimit ?? this.timeLimit,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      attemptCount: attemptCount ?? this.attemptCount,
      bestScore: bestScore ?? this.bestScore,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    );
  }

  String get difficultyIcon {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return '🟢';
      case QuizDifficulty.medium:
        return '🟡';
      case QuizDifficulty.hard:
        return '🔴';
    }
  }

  String get difficultyText {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return 'Easy';
      case QuizDifficulty.medium:
        return 'Medium';
      case QuizDifficulty.hard:
        return 'Hard';
    }
  }

  String get questionsCountText {
    if (questions.isEmpty) return 'No questions';
    if (questions.length == 1) return '1 question';
    return '${questions.length} questions';
  }

  String get timeLimitText {
    if (timeLimit == 0) return 'No time limit';
    if (timeLimit == 1) return '1 minute';
    return '$timeLimit minutes';
  }

  String get bestScoreText {
    if (attemptCount == 0) return 'Not attempted';
    return '${bestScore.toStringAsFixed(1)}%';
  }

  double calculateScore(List<QuizResult> results) {
    if (results.isEmpty || questions.isEmpty) return 0.0;
    
    final correctAnswers = results.where((result) => result.isCorrect).length;
    return (correctAnswers / questions.length) * 100;
  }

  @override
  String toString() {
    return 'QuizModel(id: $id, title: $title, questions: ${questions.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}