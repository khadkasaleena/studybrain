import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard_model.dart';
import '../models/quiz_model.dart';
import '../config/constants.dart';
import '../models/note_model.dart';

class AiService extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _apiKey;
  String _apiUrl = AppConstants.defaultApiUrl;
  String _model = AppConstants.defaultModel;
  bool _isConfigured = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isConfigured => _isConfigured;
  String get apiUrl => _apiUrl;
  String get model => _model;

  AiService() {
    _loadConfiguration();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load AI configuration from shared preferences
  Future<void> _loadConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _apiKey = prefs.getString(AppConstants.apiKeyKey);
      _apiUrl = prefs.getString(AppConstants.apiUrlKey) ?? AppConstants.defaultApiUrl;
      _model = prefs.getString('ai_model') ?? AppConstants.defaultModel;
      _isConfigured = _apiKey != null && _apiKey!.isNotEmpty;
      // Auto-configure with Groq if not set
      if (!_isConfigured) {
        _apiKey = AppConstants.groqApiKey;
        _apiUrl = AppConstants.groqBaseUrl;
        _model = AppConstants.aiModel;
        _isConfigured = true;
        final prefs2 = await SharedPreferences.getInstance();
        await prefs2.setString(AppConstants.apiKeyKey, _apiKey!);
        await prefs2.setString(AppConstants.apiUrlKey, _apiUrl);
        await prefs2.setString('ai_model', _model);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading AI configuration: $e');
    }
  }

  // Save AI configuration
  Future<void> saveConfiguration({
    required String apiKey,
    String? apiUrl,
    String? model,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _apiKey = apiKey;
      if (apiUrl != null) _apiUrl = apiUrl;
      if (model != null) _model = model;
      
      await prefs.setString(AppConstants.apiKeyKey, apiKey);
      await prefs.setString(AppConstants.apiUrlKey, _apiUrl);
      await prefs.setString('ai_model', _model);
      
      _isConfigured = apiKey.isNotEmpty;
      notifyListeners();
    } catch (e) {
      _setError('Failed to save AI configuration');
      debugPrint('Error saving AI configuration: $e');
    }
  }

  // Clear configuration
  Future<void> clearConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.apiKeyKey);
      await prefs.remove(AppConstants.apiUrlKey);
      await prefs.remove('ai_model');
      
      _apiKey = null;
      _apiUrl = AppConstants.defaultApiUrl;
      _model = AppConstants.defaultModel;
      _isConfigured = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing AI configuration: $e');
    }
  }

  // Make API request to AI service
  Future<Map<String, dynamic>?> _makeApiRequest(List<Map<String, dynamic>> messages, {double temperature = 0.7}) async {
    if (!_isConfigured) {
      _setError('AI service is not configured. Please add your API key in settings.');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': temperature,
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        _setError('Invalid API key. Please check your configuration.');
        return null;
      } else if (response.statusCode == 429) {
        _setError('Rate limit exceeded. Please try again later.');
        return null;
      } else {
        _setError('AI service error: ${response.statusCode}');
        debugPrint('AI API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        _setError('Network error. Please check your internet connection.');
      } else {
        _setError('Failed to connect to AI service.');
      }
      debugPrint('AI Service Error: $e');
      return null;
    }
  }

  // Generate flashcards from text
  Future<List<FlashcardModel>> generateFlashcards(NoteModel note, {int count = 10}) async {
    if (!_isConfigured) {
      // Return mock flashcards if not configured
      return _generateMockFlashcards(note, count);
    }

    try {
      _setLoading(true);
      _setError(null);

      final messages = [
        {
          'role': 'system',
          'content': '''You are an expert educational content creator. Generate exactly $count flashcards from the provided text. 

Return a JSON array where each object has:
- "front": The question or prompt (concise, clear)
- "back": The answer or explanation (detailed but focused)

Focus on key concepts, definitions, important facts, and relationships. Make questions that test understanding, not just memorization. Vary question types (what, how, why, when, where).

Format: [{"front": "Question here?", "back": "Answer here."}, ...]'''
        },
        {
          'role': 'user',
          'content': 'Generate flashcards from this content:\n\nTitle: ${note.title}\n\nContent: ${note.content}'
        }
      ];

      final response = await _makeApiRequest(messages);
      
      if (response == null) {
        _setLoading(false);
        return _generateMockFlashcards(note, count);
      }

      final content = response['choices']?[0]?['message']?['content'];
      if (content == null) {
        _setError('Invalid response from AI service');
        _setLoading(false);
        return _generateMockFlashcards(note, count);
      }

      // Parse JSON response
      final flashcards = <FlashcardModel>[];
      try {
        final jsonData = jsonDecode(content) as List;
        
        for (int i = 0; i < jsonData.length && i < count; i++) {
          final item = jsonData[i];
          if (item['front'] != null && item['back'] != null) {
            flashcards.add(FlashcardModel(
              id: '', // Will be set by Firestore
              noteId: note.id,
              userId: note.userId,
              front: item['front'].toString().trim(),
              back: item['back'].toString().trim(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));
          }
        }
      } catch (e) {
        debugPrint('Error parsing flashcards JSON: $e');
        _setError('Failed to parse AI response');
        _setLoading(false);
        return _generateMockFlashcards(note, count);
      }

      _setLoading(false);
      return flashcards;
    } catch (e) {
      _setError('Failed to generate flashcards');
      _setLoading(false);
      debugPrint('Error generating flashcards: $e');
      return _generateMockFlashcards(note, count);
    }
  }

  // Generate quiz from text
  Future<QuizModel> generateQuiz(NoteModel note, {int questionCount = 5, String difficulty = 'medium'}) async {
    if (!_isConfigured) {
      // Return mock quiz if not configured
      return _generateMockQuiz(note, questionCount, difficulty);
    }

    try {
      _setLoading(true);
      _setError(null);

      final messages = [
        {
          'role': 'system',
          'content': '''You are an expert quiz creator. Generate exactly $questionCount multiple choice questions from the provided text at $difficulty difficulty level.

Return a JSON object with:
- "title": A descriptive quiz title
- "questions": Array of question objects

Each question object should have:
- "id": Unique identifier (use numbers: "1", "2", etc.)
- "question": The question text
- "options": Array of 4 answer options (objects with "text" and "isCorrect" boolean)
- "explanation": Brief explanation of the correct answer
- "difficulty": "$difficulty"

Ensure exactly one option per question is marked as correct. Mix question types and focus on understanding, not memorization.

Format: {"title": "Quiz Title", "questions": [...]}'''
        },
        {
          'role': 'user',
          'content': 'Generate a quiz from this content:\n\nTitle: ${note.title}\n\nContent: ${note.content}'
        }
      ];

      final response = await _makeApiRequest(messages);
      
      if (response == null) {
        _setLoading(false);
        return _generateMockQuiz(note, questionCount, difficulty);
      }

      final content = response['choices']?[0]?['message']?['content'];
      if (content == null) {
        _setError('Invalid response from AI service');
        _setLoading(false);
        return _generateMockQuiz(note, questionCount, difficulty);
      }

      // Parse JSON response
      try {
        final jsonData = jsonDecode(content);
        
        final questions = <QuizQuestion>[];
        final questionsData = jsonData['questions'] as List;
        
        for (final questionData in questionsData) {
          final options = <QuizOption>[];
          final optionsData = questionData['options'] as List;
          
          for (final optionData in optionsData) {
            options.add(QuizOption(
              text: optionData['text'].toString().trim(),
              isCorrect: optionData['isCorrect'] == true,
              explanation: optionData['explanation']?.toString().trim(),
            ));
          }

          questions.add(QuizQuestion(
            id: questionData['id'].toString(),
            question: questionData['question'].toString().trim(),
            options: options,
            difficulty: QuizDifficulty.values.firstWhere(
              (d) => d.toString().split('.').last == difficulty,
              orElse: () => QuizDifficulty.medium,
            ),
            explanation: questionData['explanation']?.toString().trim(),
          ));
        }

        final quiz = QuizModel(
          id: '', // Will be set by Firestore
          noteId: note.id,
          userId: note.userId,
          title: jsonData['title']?.toString().trim() ?? '${note.title} Quiz',
          description: 'Generated from note: ${note.title}',
          questions: questions,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          difficulty: QuizDifficulty.values.firstWhere(
            (d) => d.toString().split('.').last == difficulty,
            orElse: () => QuizDifficulty.medium,
          ),
        );

        _setLoading(false);
        return quiz;
      } catch (e) {
        debugPrint('Error parsing quiz JSON: $e');
        _setError('Failed to parse AI response');
        _setLoading(false);
        return _generateMockQuiz(note, questionCount, difficulty);
      }
    } catch (e) {
      _setError('Failed to generate quiz');
      _setLoading(false);
      debugPrint('Error generating quiz: $e');
      return _generateMockQuiz(note, questionCount, difficulty);
    }
  }

  // Generate summary from text
  Future<String> generateSummary(NoteModel note) async {
    if (!_isConfigured) {
      return _generateMockSummary(note);
    }

    try {
      _setLoading(true);
      _setError(null);

      final messages = [
        {
          'role': 'system',
          'content': '''You are an expert at creating concise, informative summaries. Create a well-structured summary of the provided content that:

1. Captures the main ideas and key points
2. Is organized with clear sections or bullet points
3. Uses simple, clear language
4. Highlights important concepts and relationships
5. Is about 150-300 words depending on source length

Focus on what a student would need to remember for studying.'''
        },
        {
          'role': 'user',
          'content': 'Summarize this content:\n\nTitle: ${note.title}\n\nContent: ${note.content}'
        }
      ];

      final response = await _makeApiRequest(messages, temperature: 0.3);
      
      if (response == null) {
        _setLoading(false);
        return _generateMockSummary(note);
      }

      final content = response['choices']?[0]?['message']?['content'];
      if (content == null) {
        _setError('Invalid response from AI service');
        _setLoading(false);
        return _generateMockSummary(note);
      }

      _setLoading(false);
      return content.trim();
    } catch (e) {
      _setError('Failed to generate summary');
      _setLoading(false);
      debugPrint('Error generating summary: $e');
      return _generateMockSummary(note);
    }
  }

  // Chat with AI about notes
  Future<String> chatWithAI(String userMessage, {List<NoteModel>? contextNotes}) async {
    if (!_isConfigured) {
      return _generateMockChatResponse(userMessage);
    }

    try {
      _setLoading(true);
      _setError(null);

      String systemMessage = '''You are an intelligent study assistant. Help students understand their notes and study materials. You should:

1. Answer questions clearly and helpfully
2. Explain concepts in simple terms
3. Provide examples when helpful
4. Ask follow-up questions to ensure understanding
5. Be encouraging and supportive

Keep responses conversational and helpful for studying.''';

      if (contextNotes != null && contextNotes.isNotEmpty) {
        systemMessage += '\n\nHere are some relevant notes from the student:\n\n';
        for (final note in contextNotes) {
          systemMessage += '**${note.title}**:\n${note.content}\n\n';
        }
      }

      final messages = [
        {
          'role': 'system',
          'content': systemMessage,
        },
        {
          'role': 'user',
          'content': userMessage,
        }
      ];

      final response = await _makeApiRequest(messages);
      
      if (response == null) {
        _setLoading(false);
        return _generateMockChatResponse(userMessage);
      }

      final content = response['choices']?[0]?['message']?['content'];
      if (content == null) {
        _setError('Invalid response from AI service');
        _setLoading(false);
        return _generateMockChatResponse(userMessage);
      }

      _setLoading(false);
      return content.trim();
    } catch (e) {
      _setError('Failed to get AI response');
      _setLoading(false);
      debugPrint('Error chatting with AI: $e');
      return _generateMockChatResponse(userMessage);
    }
  }

  // Mock methods for fallback when AI is not configured

  List<FlashcardModel> _generateMockFlashcards(NoteModel note, int count) {
    final flashcards = <FlashcardModel>[];
    
    // Generate basic flashcards from note content
    final words = note.content.split(' ');
    final sentences = note.content.split('.');
    
    for (int i = 0; i < count && i < sentences.length; i++) {
      final sentence = sentences[i].trim();
      if (sentence.isNotEmpty) {
        flashcards.add(FlashcardModel(
          id: '',
          noteId: note.id,
          userId: note.userId,
          front: 'What is the key concept in this statement?',
          back: sentence,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
    }

    // Add a few more generic ones if needed
    if (flashcards.length < count) {
      flashcards.add(FlashcardModel(
        id: '',
        noteId: note.id,
        userId: note.userId,
        front: 'What is the main topic of "${note.title}"?',
        back: 'The main topic relates to ${note.title.toLowerCase()} and covers key concepts from your notes.',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    return flashcards.take(count).toList();
  }

  QuizModel _generateMockQuiz(NoteModel note, int questionCount, String difficulty) {
    final questions = <QuizQuestion>[];
    
    // Generate basic questions
    questions.add(QuizQuestion(
      id: '1',
      question: 'What is the main topic of "${note.title}"?',
      options: [
        QuizOption(text: note.title, isCorrect: true),
        QuizOption(text: 'Something else entirely'),
        QuizOption(text: 'Not covered in the notes'),
        QuizOption(text: 'Multiple unrelated topics'),
      ],
      explanation: 'This is the title and main focus of your note.',
    ));

    if (questionCount > 1) {
      questions.add(QuizQuestion(
        id: '2',
        question: 'Which of the following best describes the content?',
        options: [
          QuizOption(text: 'Educational material for studying', isCorrect: true),
          QuizOption(text: 'Entertainment content'),
          QuizOption(text: 'Random information'),
          QuizOption(text: 'Advertising material'),
        ],
        explanation: 'Your notes contain educational content designed for studying.',
      ));
    }

    // Fill remaining questions with generic ones
    while (questions.length < questionCount) {
      questions.add(QuizQuestion(
        id: (questions.length + 1).toString(),
        question: 'This is a sample question ${questions.length + 1}',
        options: [
          QuizOption(text: 'Correct answer', isCorrect: true),
          QuizOption(text: 'Option 2'),
          QuizOption(text: 'Option 3'),
          QuizOption(text: 'Option 4'),
        ],
        explanation: 'This is a sample explanation. Configure AI service for better questions.',
      ));
    }

    return QuizModel(
      id: '',
      noteId: note.id,
      userId: note.userId,
      title: '${note.title} Quiz (Sample)',
      description: 'Sample quiz - configure AI service for better questions',
      questions: questions,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String _generateMockSummary(NoteModel note) {
    if (note.content.length < 100) {
      return note.content;
    }

    // Simple extractive summary - take first few sentences
    final sentences = note.content.split('.');
    final summaryParts = <String>[];
    int charCount = 0;

    for (final sentence in sentences) {
      if (charCount + sentence.length > 200) break;
      if (sentence.trim().isNotEmpty) {
        summaryParts.add(sentence.trim());
        charCount += sentence.length;
      }
    }

    return summaryParts.join('. ') + (summaryParts.isNotEmpty ? '.' : '') + 
           '\n\n📝 Configure AI service in settings for better summaries.';
  }

  String _generateMockChatResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'Hello! I\'m your AI study assistant. I\'d love to help you with your studies, but I need to be configured first. Please add your AI API key in the settings to enable full AI features. For now, I can provide basic responses.';
    }
    
    if (lowerMessage.contains('help') || lowerMessage.contains('how')) {
      return 'I\'m here to help you study! However, to provide detailed assistance with your notes and answer complex questions, please configure the AI service in your settings. Add your OpenAI or compatible API key to unlock full AI capabilities.';
    }
    
    if (lowerMessage.contains('quiz') || lowerMessage.contains('test')) {
      return 'I can help create quizzes from your notes! But first, please set up the AI service in settings by adding your API key. This will allow me to generate personalized quizzes based on your study material.';
    }
    
    return 'Thanks for your message! I\'m designed to be a powerful study assistant, but I need to be configured first. Please go to Settings and add your AI API key (OpenAI or compatible service) to unlock features like:\n\n• Intelligent flashcard generation\n• Custom quiz creation\n• Content summarization\n• Study guidance\n\nOnce configured, I\'ll be able to provide much more helpful responses!';
  }

  // Test AI connection
  Future<bool> testConnection() async {
    if (!_isConfigured) {
      _setError('AI service is not configured');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      final messages = [
        {
          'role': 'system',
          'content': 'You are a helpful assistant. Respond with exactly: "Connection successful"'
        },
        {
          'role': 'user',
          'content': 'Test connection'
        }
      ];

      final response = await _makeApiRequest(messages);
      
      if (response != null) {
        final content = response['choices']?[0]?['message']?['content'];
        _setLoading(false);
        return content != null;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }
}