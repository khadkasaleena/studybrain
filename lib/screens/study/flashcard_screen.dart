import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/flashcard_model.dart';
import '../../widgets/flashcard_widget.dart';

class FlashcardScreen extends StatefulWidget {
  final List<FlashcardModel> flashcards;
  final String title;

  const FlashcardScreen({
    super.key,
    required this.flashcards,
    this.title = 'Study Flashcards',
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  List<bool> _knownCards = [];
  List<FlashcardModel> _missedCards = [];
  bool _isCompleted = false;
  bool _showingBack = false;
  late AnimationController _swipeController;
  late AnimationController _progressController;
  late AnimationController _completionController;
  late AnimationController _glowController;
  late ConfettiController _confettiController;
  
  double _swipeOffset = 0;
  String? _swipeDirection;

  @override
  void initState() {
    super.initState();
    _knownCards = List.filled(widget.flashcards.length, false);
    
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _completionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _progressController.dispose();
    _completionController.dispose();
    _glowController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isCompleted) return;
    
    setState(() {
      _swipeOffset += details.delta.dx;
      
      // Determine swipe direction and add visual feedback
      if (_swipeOffset > 50) {
        _swipeDirection = 'right';
      } else if (_swipeOffset < -50) {
        _swipeDirection = 'left';
      } else {
        _swipeDirection = null;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isCompleted) return;
    
    const threshold = 100.0;
    
    if (_swipeOffset > threshold) {
      _answerCard(true); // Know it
    } else if (_swipeOffset < -threshold) {
      _answerCard(false); // Don't know it
    } else {
      // Snap back
      _swipeController.forward().then((_) {
        setState(() {
          _swipeOffset = 0;
          _swipeDirection = null;
        });
        _swipeController.reset();
      });
    }
  }

  void _answerCard(bool known) {
    _knownCards[_currentIndex] = known;
    
    if (!known) {
      _missedCards.add(widget.flashcards[_currentIndex]);
    }
    
    // Glow effect
    _glowController.forward().then((_) {
      _glowController.reverse();
    });
    
    // Move to next card or complete
    if (_currentIndex < widget.flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _showingBack = false;
        _swipeOffset = 0;
        _swipeDirection = null;
      });
      _progressController.forward();
    } else {
      _completeSession();
    }
  }

  void _completeSession() {
    setState(() {
      _isCompleted = true;
    });
    
    _completionController.forward();
    
    // Show confetti if score is good
    final score = _getScore();
    if (score > 80) {
      _confettiController.play();
    }
  }

  double _getScore() {
    if (_knownCards.isEmpty) return 0;
    final knownCount = _knownCards.where((known) => known).length;
    return (knownCount / _knownCards.length) * 100;
  }

  void _reviewMissedCards() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardScreen(
          flashcards: _missedCards,
          title: 'Review Missed Cards',
        ),
      ),
    );
  }

  void _restartSession() {
    setState(() {
      _currentIndex = 0;
      _knownCards = List.filled(widget.flashcards.length, false);
      _missedCards.clear();
      _isCompleted = false;
      _showingBack = false;
      _swipeOffset = 0;
      _swipeDirection = null;
    });
    
    _progressController.reset();
    _completionController.reset();
  }

  Widget _buildProgressBar() {
    final progress = _currentIndex / widget.flashcards.length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Card ${_currentIndex + 1} of ${widget.flashcards.length}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.lightTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            minHeight: 6,
          ).animate()
            .scaleX(duration: 300.ms, curve: Curves.easeInOut),
        ],
      ),
    );
  }

  Widget _buildSwipeInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: AppTheme.errorColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Don\'t Know',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      Text(
                        'Swipe left',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            width: 1,
            height: 30,
            color: Colors.grey.shade300,
          ),
          
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Know It',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.successColor,
                        ),
                      ),
                      Text(
                        'Swipe right',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard() {
    final flashcard = widget.flashcards[_currentIndex];
    
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..translate(_swipeOffset)
          ..rotateZ(_swipeOffset * 0.001),
        child: Stack(
          children: [
            // Glow effect
            if (_swipeDirection != null)
              Container(
                margin: const EdgeInsets.all(20),
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _swipeDirection == 'right'
                          ? AppTheme.successColor.withOpacity(0.6)
                          : AppTheme.errorColor.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            
            // Flashcard
            Container(
              margin: const EdgeInsets.all(24),
              child: FlashcardWidget(
                front: flashcard.front,
                back: flashcard.back,
                isFlipped: _showingBack,
                onTap: () {
                  setState(() {
                    _showingBack = !_showingBack;
                  });
                },
              ),
            ),
            
            // Swipe indicators
            if (_swipeDirection == 'right')
              Positioned(
                right: 40,
                top: 80,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 32,
                  ),
                ).animate().scale().shake(),
              ),
            
            if (_swipeDirection == 'left')
              Positioned(
                left: 40,
                top: 80,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 32,
                  ),
                ).animate().scale().shake(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final score = _getScore();
    final knownCount = _knownCards.where((known) => known).length;
    final totalCount = _knownCards.length;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 60),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppTheme.primaryColor,
                AppTheme.secondaryColor,
                AppTheme.successColor,
                AppTheme.warningColor,
              ],
            ),
          ),
          
          // Score circle
          Container(
            width: 200,
            height: 200,
            margin: const EdgeInsets.symmetric(vertical: 32),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      score > 80
                          ? AppTheme.successColor
                          : score > 60
                              ? AppTheme.warningColor
                              : AppTheme.errorColor,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${score.toInt()}%',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkTextColor,
                      ),
                    ),
                    Text(
                      _getScoreText(score),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().scale(delay: 300.ms),
          
          // Stats
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: [
                Text(
                  'Session Complete!',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Known',
                        knownCount.toString(),
                        AppTheme.successColor,
                        Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Missed',
                        '${totalCount - knownCount}',
                        AppTheme.errorColor,
                        Icons.cancel,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Column(
                  children: [
                    if (_missedCards.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _reviewMissedCards,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Review Missed Cards'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.warningColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _restartSession,
                            icon: const Icon(Icons.replay),
                            label: const Text('Restart'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.check),
                            label: const Text('Done'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.3),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreText(double score) {
    if (score >= 90) return 'Excellent!';
    if (score >= 80) return 'Great job!';
    if (score >= 70) return 'Good work!';
    if (score >= 60) return 'Keep practicing!';
    return 'Review needed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          if (!_isCompleted)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Exit Study Session?'),
                    content: const Text('Your progress will be lost.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Exit'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: _isCompleted
          ? _buildCompletionScreen()
          : Column(
              children: [
                _buildProgressBar(),
                if (!_showingBack) _buildSwipeInstructions(),
                
                Expanded(
                  child: Center(
                    child: _buildFlashcard(),
                  ),
                ),
                
                // Tap to flip hint
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Tap card to flip • Swipe to answer',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.lightTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}