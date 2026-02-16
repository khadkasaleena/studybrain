import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/note_model.dart';
import '../../models/flashcard_model.dart';
import '../../models/quiz_model.dart';
import '../study/flashcard_screen.dart';
import '../study/quiz_screen.dart';
import '../chat/ai_chat_screen.dart';

class NoteDetailScreen extends StatefulWidget {
  final NoteModel note;

  const NoteDetailScreen({
    super.key,
    required this.note,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isGeneratingFlashcards = false;
  bool _isGeneratingQuiz = false;
  bool _isSummarizing = false;
  String _summary = '';
  List<FlashcardModel> _flashcards = [];
  List<QuizModel> _quizzes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadExistingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    // Simulate loading existing flashcards, quizzes, and summary
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mock data - replace with actual Firestore queries
    if (widget.note.flashcardCount > 0) {
      _flashcards = [
        FlashcardModel(
          id: '1',
          noteId: widget.note.id,
          userId: 'user1',
          front: 'What is the Heisenberg Uncertainty Principle?',
          back: 'It states that it\'s impossible to simultaneously know both the exact position and momentum of a particle with perfect precision.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          difficulty: FlashcardDifficulty.medium,
        ),
        FlashcardModel(
          id: '2',
          noteId: widget.note.id,
          userId: 'user1',
          front: 'What is wave-particle duality?',
          back: 'Light and matter exhibit both wave and particle properties depending on how they are observed.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          difficulty: FlashcardDifficulty.easy,
        ),
      ];
    }
    
    if (widget.note.quizCount > 0) {
      _quizzes = [
        QuizModel(
          id: '1',
          noteId: widget.note.id,
          userId: 'user1',
          title: 'Quantum Mechanics Quiz',
          questions: [
            QuizQuestion(
              id: '1',
              question: 'Which principle states the impossibility of knowing both position and momentum precisely?',
              options: [
                QuizOption(text: 'Heisenberg Uncertainty', isCorrect: true),
                QuizOption(text: 'Pauli Exclusion', isCorrect: false),
                QuizOption(text: 'Superposition', isCorrect: false),
                QuizOption(text: 'Entanglement', isCorrect: false),
              ],
              explanation: 'The Heisenberg Uncertainty Principle is fundamental to quantum mechanics.',
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    }
    
    if (widget.note.summary?.isNotEmpty == true) {
      _summary = widget.note.summary!;
    }
    
    setState(() {});
  }

  Future<void> _generateFlashcards() async {
    setState(() => _isGeneratingFlashcards = true);
    
    try {
      // Simulate AI generation with realistic delay
      await Future.delayed(const Duration(seconds: 3));
      
      // Mock generated flashcards - replace with actual AI service call
      final newFlashcards = [
        FlashcardModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          noteId: widget.note.id,
          userId: 'user1',
          front: 'What describes how quantum states change over time?',
          back: 'The Schrödinger Equation is the fundamental equation that describes how the quantum state of a physical system changes with time.',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          difficulty: FlashcardDifficulty.medium,
        ),
        FlashcardModel(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          noteId: widget.note.id,
          userId: 'user1',
          front: 'What connects particles across space?',
          back: 'Quantum entanglement is a phenomenon where particles become interconnected and instantly affect each other regardless of distance.',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          difficulty: FlashcardDifficulty.hard,
        ),
      ];
      
      setState(() {
        _flashcards.addAll(newFlashcards);
      });
      
      _showGenerationResult(
        'Flashcards Generated!',
        '${newFlashcards.length} new flashcards have been created from your note.',
        Icons.flash_on,
        AppTheme.warningColor,
      );
      
    } catch (e) {
      _showErrorSnackBar('Failed to generate flashcards. Please try again.');
    } finally {
      setState(() => _isGeneratingFlashcards = false);
    }
  }

  Future<void> _generateQuiz() async {
    setState(() => _isGeneratingQuiz = true);
    
    try {
      await Future.delayed(const Duration(seconds: 4));
      
      // Mock generated quiz
      final newQuiz = QuizModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        noteId: widget.note.id,
        userId: 'user1',
        title: '${widget.note.title} Quiz',
        questions: [
          QuizQuestion(
            id: '1',
            question: 'What causes wavefunction collapse in quantum mechanics?',
            options: [
              QuizOption(text: 'Measurement', isCorrect: true),
              QuizOption(text: 'Time', isCorrect: false),
              QuizOption(text: 'Temperature', isCorrect: false),
              QuizOption(text: 'Pressure', isCorrect: false),
            ],
            explanation: 'Measurement is what causes the wavefunction to collapse into a definite state.',
          ),
          QuizQuestion(
            id: '2',
            question: 'What type of duality do light and matter exhibit?',
            options: [
              QuizOption(text: 'Mass-energy', isCorrect: false),
              QuizOption(text: 'Wave-particle', isCorrect: true),
              QuizOption(text: 'Space-time', isCorrect: false),
              QuizOption(text: 'Matter-antimatter', isCorrect: false),
            ],
            explanation: 'Wave-particle duality is a fundamental property of quantum objects.',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      setState(() {
        _quizzes.add(newQuiz);
      });
      
      _showGenerationResult(
        'Quiz Generated!',
        'A new quiz with ${newQuiz.questions.length} questions has been created.',
        Icons.quiz,
        AppTheme.primaryColor,
      );
      
    } catch (e) {
      _showErrorSnackBar('Failed to generate quiz. Please try again.');
    } finally {
      setState(() => _isGeneratingQuiz = false);
    }
  }

  Future<void> _generateSummary() async {
    setState(() => _isSummarizing = true);
    
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock generated summary
      _summary = '''**Key Concepts Summary:**

• **Wave-Particle Duality**: Fundamental property where quantum objects exhibit both wave and particle characteristics depending on observation method

• **Heisenberg Uncertainty Principle**: Impossibility of simultaneously determining exact position and momentum of a particle

• **Schrödinger Equation**: Mathematical framework describing quantum state evolution over time

• **Quantum Entanglement**: Phenomenon connecting particles across any distance instantaneously

• **Wavefunction Collapse**: Process where quantum superposition resolves into definite state upon measurement

**Applications**: These principles form the foundation of quantum computing, quantum cryptography, and advanced materials science.''';
      
      setState(() {});
      
      _showGenerationResult(
        'Summary Generated!',
        'A comprehensive summary of your note has been created.',
        Icons.summarize,
        AppTheme.successColor,
      );
      
    } catch (e) {
      _showErrorSnackBar('Failed to generate summary. Please try again.');
    } finally {
      setState(() => _isSummarizing = false);
    }
  }

  void _showGenerationResult(String title, String message, IconData icon, Color color) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.lightTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: color),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required List<Color> gradientColors,
    bool isLoading = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLoading 
                ? [Colors.grey.shade300, Colors.grey.shade400]
                : gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isLoading ? null : [
              BoxShadow(
                color: gradientColors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ).animate(target: isLoading ? 1 : 0)
        .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.note.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AIChatScreen(note: widget.note),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
          ),
          IconButton(
            onPressed: () {
              // TODO: Share note
            },
            icon: const Icon(Icons.share_outlined),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Content'),
            Tab(text: 'Flashcards'),
            Tab(text: 'Quiz'),
            Tab(text: 'Summary'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.lightTextColor,
          indicatorColor: AppTheme.primaryColor,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Content Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.note.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.note.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '#$tag',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      MarkdownBody(
                        data: widget.note.content,
                        styleSheet: MarkdownStyleSheet(
                          h1: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkTextColor,
                          ),
                          h2: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkTextColor,
                          ),
                          h3: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkTextColor,
                          ),
                          p: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppTheme.darkTextColor,
                            height: 1.6,
                          ),
                          listBullet: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppTheme.darkTextColor,
                          ),
                          code: GoogleFonts.sourceCodePro(
                            fontSize: 14,
                            backgroundColor: AppTheme.backgroundColor,
                          ),
                        ),
                      ).animate().fadeIn(),
                      
                      if (widget.note.imageUrls.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        ...widget.note.imageUrls.map((url) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                url,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 200,
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
                
                // Flashcards Tab
                _flashcards.isEmpty
                    ? _buildEmptyState(
                        'No flashcards yet',
                        'Generate flashcards from this note',
                        Icons.flash_on,
                        AppTheme.warningColor,
                        () => _generateFlashcards(),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _flashcards.length,
                        itemBuilder: (context, index) {
                          final flashcard = _flashcards[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Q:',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getDifficultyColor(flashcard.difficulty),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        flashcard.difficultyText,
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  flashcard.front,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppTheme.darkTextColor,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'A:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.successColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  flashcard.back,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppTheme.darkTextColor,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ).animate(delay: Duration(milliseconds: index * 100))
                            .fadeIn()
                            .slideY(begin: 0.2);
                        },
                      ),
                
                // Quiz Tab
                _quizzes.isEmpty
                    ? _buildEmptyState(
                        'No quizzes yet',
                        'Generate a quiz from this note',
                        Icons.quiz,
                        AppTheme.primaryColor,
                        () => _generateQuiz(),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _quizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = _quizzes[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizScreen(quiz: quiz),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppTheme.cardShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.quiz,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          quiz.title,
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      _buildQuizStat(
                                        '${quiz.questions.length}',
                                        'Questions',
                                      ),
                                      const SizedBox(width: 24),
                                      _buildQuizStat(
                                        '~${quiz.questions.length * 30}s',
                                        'Duration',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ).animate(delay: Duration(milliseconds: index * 100))
                              .fadeIn()
                              .slideX(begin: 0.2),
                          );
                        },
                      ),
                
                // Summary Tab
                _summary.isEmpty
                    ? _buildEmptyState(
                        'No summary yet',
                        'Generate a summary of this note',
                        Icons.summarize,
                        AppTheme.successColor,
                        () => _generateSummary(),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: MarkdownBody(
                            data: _summary,
                            styleSheet: MarkdownStyleSheet(
                              h1: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkTextColor,
                              ),
                              h2: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.darkTextColor,
                              ),
                              p: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.darkTextColor,
                                height: 1.6,
                              ),
                              listBullet: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.darkTextColor,
                              ),
                            ),
                          ),
                        ).animate().fadeIn(),
                      ),
              ],
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildActionButton(
                  label: 'Generate\nFlashcards',
                  icon: Icons.flash_on,
                  onPressed: _generateFlashcards,
                  gradientColors: [AppTheme.warningColor, Colors.orange],
                  isLoading: _isGeneratingFlashcards,
                ),
                _buildActionButton(
                  label: 'Generate\nQuiz',
                  icon: Icons.quiz,
                  onPressed: _generateQuiz,
                  gradientColors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
                  isLoading: _isGeneratingQuiz,
                ),
                _buildActionButton(
                  label: 'Summarize',
                  icon: Icons.summarize,
                  onPressed: _generateSummary,
                  gradientColors: [AppTheme.successColor, Colors.teal],
                  isLoading: _isSummarizing,
                ),
                _buildActionButton(
                  label: 'Ask AI',
                  icon: Icons.chat_bubble_outline,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AIChatScreen(note: widget.note),
                      ),
                    );
                  },
                  gradientColors: [AppTheme.secondaryColor, Colors.pinkAccent],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              icon,
              size: 40,
              color: color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.lightTextColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: const Text('Generate Now'),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildQuizStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(FlashcardDifficulty difficulty) {
    switch (difficulty) {
      case FlashcardDifficulty.easy:
        return AppTheme.successColor;
      case FlashcardDifficulty.medium:
        return AppTheme.warningColor;
      case FlashcardDifficulty.hard:
        return AppTheme.errorColor;
    }
  }
}