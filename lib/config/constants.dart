class AppConstants {
  // App Info
  static const String appName = 'StudyBrain';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered study companion';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String notebooksCollection = 'notebooks';

  // AI
  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String aiModel = 'llama-3.1-8b-instant';
  static const String notesCollection = 'notes';
  static const String flashcardsCollection = 'flashcards';
  static const String quizzesCollection = 'quizzes';
  static const String studySessionsCollection = 'study_sessions';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String noteImagesPath = 'note_images';
  static const String noteFilesPath = 'note_files';

  // SharedPreferences Keys
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String userPreferencesKey = 'user_preferences';
  static const String studyStreakKey = 'study_streak';
  static const String lastStudyDateKey = 'last_study_date';
  static const String darkModeKey = 'dark_mode';
  static const String notificationsKey = 'notifications';

  // AI Configuration
  static const String defaultApiUrl = 'https://api.openai.com/v1';
  static const String apiKeyKey = 'ai_api_key';
  static const String apiUrlKey = 'ai_api_url';
  static const String defaultModel = 'gpt-3.5-turbo';

  // Study Configuration
  static const int maxFlashcardsPerSession = 20;
  static const int maxQuizQuestionsPerSession = 10;
  static const int minStudyStreak = 1;
  static const int maxStudyStreak = 365;

  // File Constraints
  static const int maxImageSizeMB = 5;
  static const int maxPdfSizeMB = 10;
  static const List<String> supportedImageTypes = ['jpg', 'jpeg', 'png'];
  static const List<String> supportedDocumentTypes = ['pdf'];

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;

  // Grid Constants
  static const int notebooksGridCrossAxisCount = 2;
  static const double notebooksGridChildAspectRatio = 1.2;
  static const double notebooksGridSpacing = 12.0;

  // Chat Constants
  static const String aiChatInitialMessage = "Hello! I'm your AI study assistant. Ask me anything about your notes, or I can help you understand complex topics. How can I help you today?";
  
  // Error Messages
  static const String networkError = 'Please check your internet connection and try again.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String fileUploadError = 'Failed to upload file. Please try again.';
  static const String ocrError = 'Failed to extract text from image. Please try again.';
  static const String aiError = 'AI service is currently unavailable. Please try again later.';

  // Success Messages
  static const String loginSuccess = 'Welcome back!';
  static const String signupSuccess = 'Account created successfully!';
  static const String noteCreated = 'Note created successfully!';
  static const String notebookCreated = 'Notebook created successfully!';
  static const String flashcardsGenerated = 'Flashcards generated successfully!';
  static const String quizGenerated = 'Quiz generated successfully!';
  static const String studySessionCompleted = 'Great job! Study session completed.';
}