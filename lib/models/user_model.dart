import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final int studyStreak;
  final DateTime? lastStudyDate;
  final Map<String, dynamic> preferences;
  final bool isPremium;
  final DateTime? premiumExpiryDate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.studyStreak = 0,
    this.lastStudyDate,
    this.preferences = const {},
    this.isPremium = false,
    this.premiumExpiryDate,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      studyStreak: data['studyStreak'] ?? 0,
      lastStudyDate: (data['lastStudyDate'] as Timestamp?)?.toDate(),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      isPremium: data['isPremium'] ?? false,
      premiumExpiryDate: (data['premiumExpiryDate'] as Timestamp?)?.toDate(),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastLoginAt: DateTime.tryParse(json['lastLoginAt'] ?? '') ?? DateTime.now(),
      studyStreak: json['studyStreak'] ?? 0,
      lastStudyDate: json['lastStudyDate'] != null 
          ? DateTime.tryParse(json['lastStudyDate'])
          : null,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      isPremium: json['isPremium'] ?? false,
      premiumExpiryDate: json['premiumExpiryDate'] != null 
          ? DateTime.tryParse(json['premiumExpiryDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'studyStreak': studyStreak,
      'lastStudyDate': lastStudyDate?.toIso8601String(),
      'preferences': preferences,
      'isPremium': isPremium,
      'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'studyStreak': studyStreak,
      'lastStudyDate': lastStudyDate != null 
          ? Timestamp.fromDate(lastStudyDate!)
          : null,
      'preferences': preferences,
      'isPremium': isPremium,
      'premiumExpiryDate': premiumExpiryDate != null 
          ? Timestamp.fromDate(premiumExpiryDate!)
          : null,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? studyStreak,
    DateTime? lastStudyDate,
    Map<String, dynamic>? preferences,
    bool? isPremium,
    DateTime? premiumExpiryDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      studyStreak: studyStreak ?? this.studyStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      preferences: preferences ?? this.preferences,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
    );
  }

  bool get hasActiveSubscription {
    if (!isPremium) return false;
    if (premiumExpiryDate == null) return true;
    return DateTime.now().isBefore(premiumExpiryDate!);
  }

  bool get shouldUpdateStreak {
    if (lastStudyDate == null) return true;
    final now = DateTime.now();
    final lastStudy = lastStudyDate!;
    final difference = now.difference(lastStudy).inDays;
    return difference >= 1;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, studyStreak: $studyStreak)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}