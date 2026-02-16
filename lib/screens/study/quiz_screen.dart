import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/quiz_model.dart';
import '../../widgets/quiz_option_widget.dart';

class QuizScreen extends StatefulWidget {
  final QuizModel quiz;

  const QuizScreen({
    super.key,
    required this.quiz,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  List<QuizResult> _results = [];
  bool _isCompleted = false;
  bool _hasAnswered = false;
  int? _selectedOptionIndex;
  Timer? _timer;
  int _timeRemaining = 0; // in seconds
  late AnimationController _progressController;
  late AnimationController _optionController;
  late AnimationController _completionController;
  late ConfettiController _confettiController;
  DateTime _questionStartTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _optionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _completionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Initialize timer if quiz has time limit
    if (widget.quiz.timeLimit > 0) {
      _timeRemaining = widget.quiz.timeLimit * 60; // convert to seconds
      _startTimer();
    }
    
    _questionStartTime = DateTime.now();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _optionController.dispose();
    _completionController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _timeOut();
      }
    });
  }

  void _timeOut() {
    _timer?.cancel();
    
    // Auto-submit current question with no answer
    if (!_hasAnswered && _currentQuestionIndex < widget.quiz.questions.length) {
      _submitAnswer(-1); // -1 indicates timeout
    }
  }

  void _selectOption(int optionIndex) {
    if (_hasAnswered) return;
    
    setState(() {
      _selectedOptionIndex = optionIndex;
    });
  }

  void _submitAnswer(int optionIndex) {
    if (_hasAnswered) return;
    
    final currentQuestion = widget.quiz.questions[_currentQuestionIndex];
    final isCorrect = optionIndex >= 0 && 
                     optionIndex < currentQuestion.options.length &&
                     currentQuestion.options[optionIndex].isCorrect;
    
    final timeSpent = DateTime.now().difference(_questionStartTime).inSeconds;
    
    final result = QuizResult(
      questionId: currentQuestion.id,
      selectedOptionIndex: optionIndex,
      isCorrect: isCorrect,
      answeredAt: DateTime.now(),
      timeSpentSeconds: timeSpent,
    );
    
    _results.add(result);
    
    setState(() {
      _hasAnswered = true;
      if (optionIndex >= 0) {
        _selectedOptionIndex = optionIndex;
      }
    });
    
    _optionController.forward();
    
    // Auto-advance after showing result
    Future.delayed(const Duration(milliseconds: 2000), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _hasAnswered = false;
        _selectedOptionIndex = null;
        _questionStartTime = DateTime.now();
      });
      
      _optionController.reset();
      _progressController.forward();
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    _timer?.cancel();
    
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
    if (_results.isEmpty) return 0.0;
    final correctCount = _results.where((r) => r.isCorrect).length;
    return (correctCount / _results.length) * 100;
  }

  String _getGrade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return AppTheme.successColor;
      case 'B':
        return Colors.blue;
      case 'C':
        return AppTheme.warningColor;
      case 'D':
        return Colors.orange;
      default:
        return AppTheme.errorColor;
    }
  }

  Widget _buildHeader() {
    final progress = (_currentQuestionIndex + 1) / widget.quiz.questions.length;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.lightTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              
              if (widget.quiz.timeLimit > 0) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _timeRemaining < 60 
                        ? AppTheme.errorColor.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _timeRemaining < 60 
                          ? AppTheme.errorColor
                          : AppTheme.primaryColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: _timeRemaining < 60 
                            ? AppTheme.errorColor
                            : AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(_timeRemaining),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _timeRemaining < 60 
                              ? AppTheme.errorColor
                              : AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final question = widget.quiz.questions[_currentQuestionIndex];
    
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  question.difficulty.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                question.difficultyIcon,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Text(
            question.question,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkTextColor,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Options
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final letter = String.fromCharCode(65 + index); // A, B, C, D
            
            QuizOptionState state = QuizOptionState.normal;
            
            if (_hasAnswered) {
              if (option.isCorrect) {
                state = QuizOptionState.correct;
              } else if (index == _selectedOptionIndex) {
                state = QuizOptionState.wrong;
              }
            } else if (index == _selectedOptionIndex) {
              state = QuizOptionState.selected;
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: QuizOptionWidget(
                letter: letter,
                text: option.text,
                state: state,
                onTap: _hasAnswered ? null : () => _selectOption(index),
                animationDelay: Duration(milliseconds: index * 150),
              ),
            );
          }).toList(),
          
          if (_hasAnswered && !_isCompleted) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _results.last.isCorrect ? Icons.check_circle : Icons.cancel,
                    color: _results.last.isCorrect 
                        ? AppTheme.successColor 
                        : AppTheme.errorColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _results.last.isCorrect ? 'Correct!' : 'Incorrect',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _results.last.isCorrect 
                                ? AppTheme.successColor 
                                : AppTheme.errorColor,
                          ),
                        ),
                        if (question.explanation?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            question.explanation!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.lightTextColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (!_hasAnswered && _selectedOptionIndex != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submitAnswer(_selectedOptionIndex!),
                child: const Text('Submit Answer'),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildResultsScreen() {
    final score = _getScore();
    final grade = _getGrade(score);
    final correctCount = _results.where((r) => r.isCorrect).length;
    final totalTime = _results.fold(0, (sum, result) => sum + result.timeSpentSeconds);
    
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          
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
          
          // Score section
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: [
                // Grade circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _getGradeColor(grade),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: _getGradeColor(grade).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        grade,
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${score.toInt()}%',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(delay: 300.ms),
                
                const SizedBox(height: 24),
                
                Text(
                  'Quiz Complete!',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTextColor,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  _getScoreMessage(score),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppTheme.lightTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Correct',
                        correctCount.toString(),
                        AppTheme.successColor,
                        Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Wrong',
                        '${_results.length - correctCount}',
                        AppTheme.errorColor,
                        Icons.cancel,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Time',
                        _formatTime(totalTime),
                        AppTheme.primaryColor,
                        Icons.timer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Avg Time',
                        _formatTime(totalTime ~/ _results.length),
                        AppTheme.warningColor,
                        Icons.speed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Question review
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Question Review',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkTextColor,
                    ),
                  ),
                ),
                
                ...widget.quiz.questions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  final result = _results[index];
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: result.isCorrect 
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: result.isCorrect 
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: result.isCorrect 
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question.question,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.darkTextColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                result.isCorrect ? 'Correct' : 'Incorrect',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: result.isCorrect 
                                      ? AppTheme.successColor
                                      : AppTheme.errorColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          result.isCorrect ? Icons.check_circle : Icons.cancel,
                          color: result.isCorrect 
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          size: 20,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                
                const SizedBox(height: 24),
              ],
            ),
          ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.3),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Share results
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share Results'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Restart quiz
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(quiz: widget.quiz),
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ),
                    const SizedBox(width: 16),
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
          ),
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
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

  String _getScoreMessage(double score) {
    if (score >= 95) return 'Perfect! Outstanding work!';
    if (score >= 90) return 'Excellent! You really know this material!';
    if (score >= 80) return 'Great job! You have a solid understanding!';
    if (score >= 70) return 'Good work! Keep studying to improve further!';
    if (score >= 60) return 'Not bad! Review the material and try again!';
    return 'Keep studying! Practice makes perfect!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.quiz.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          if (!_isCompleted && !_hasAnswered)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Exit Quiz?'),
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
          ? _buildResultsScreen()
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildQuestionCard(),
                ),
              ],
            ),
    );
  }
}