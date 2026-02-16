import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _counterController;
  
  // Mock data - replace with actual data from your backend
  final int _studyStreak = 12;
  final int _totalCards = 156;
  final int _quizzesTaken = 23;
  final double _studyHours = 47.5;
  final double _avgScore = 87.3;
  
  final List<String> _motivationalQuotes = [
    "The expert in anything was once a beginner.",
    "Learning never exhausts the mind. - Leonardo da Vinci",
    "The more that you read, the more things you will know.",
    "Success is the sum of small efforts repeated daily.",
    "Every expert was once a beginner.",
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _counterController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeController.forward();
    _counterController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  Widget _buildStreakSection() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.warningColor,
            Colors.orange.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warningColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: Text(
                '🔥',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _counterController,
                  builder: (context, child) {
                    final currentStreak = (_studyStreak * _counterController.value).round();
                    return Text(
                      '$currentStreak Day${currentStreak == 1 ? '' : 's'}',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                Text(
                  'Study Streak',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep it up! You\'re on fire! 🚀',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.3);
  }

  Widget _buildCalendarHeatMap() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Study Activity',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkTextColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Calendar grid (simplified version - you might want to use a proper calendar package)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 49, // 7 weeks
            itemBuilder: (context, index) {
              // Mock activity levels
              final activity = (index * 0.1) % 1.0;
              Color color = Colors.grey.shade200;
              
              if (activity > 0.7) {
                color = AppTheme.successColor;
              } else if (activity > 0.4) {
                color = AppTheme.successColor.withOpacity(0.6);
              } else if (activity > 0.2) {
                color = AppTheme.successColor.withOpacity(0.3);
              }
              
              return Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).animate(delay: Duration(milliseconds: index * 20))
                .fadeIn()
                .scale();
            },
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Less',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.lightTextColor,
                ),
              ),
              Row(
                children: [
                  _buildActivityLegend(Colors.grey.shade200),
                  const SizedBox(width: 3),
                  _buildActivityLegend(AppTheme.successColor.withOpacity(0.3)),
                  const SizedBox(width: 3),
                  _buildActivityLegend(AppTheme.successColor.withOpacity(0.6)),
                  const SizedBox(width: 3),
                  _buildActivityLegend(AppTheme.successColor),
                ],
              ),
              Text(
                'More',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.lightTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }

  Widget _buildActivityLegend(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Cards',
              _totalCards,
              Icons.flash_on,
              AppTheme.warningColor,
              0,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Quizzes Taken',
              _quizzesTaken,
              Icons.quiz,
              AppTheme.primaryColor,
              100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color, int delay) {
    return Container(
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
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _counterController,
            builder: (context, child) {
              final currentValue = (value * _counterController.value).round();
              return Text(
                currentValue.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkTextColor,
                ),
              );
            },
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.lightTextColor,
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: delay))
      .fadeIn()
      .slideY(begin: 0.3);
  }

  Widget _buildDetailedStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildDetailCard(
              'Study Hours',
              _studyHours.toString(),
              'Total time spent',
              Icons.access_time,
              AppTheme.successColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDetailCard(
              'Average Score',
              '${_avgScore.toInt()}%',
              'Quiz performance',
              Icons.trending_up,
              AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_upward,
                color: AppTheme.successColor,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _counterController,
            builder: (context, child) {
              if (title == 'Study Hours') {
                final currentValue = _studyHours * _counterController.value;
                return Text(
                  currentValue.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTextColor,
                  ),
                );
              } else {
                final currentValue = (_avgScore * _counterController.value).round();
                return Text(
                  '$currentValue%',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTextColor,
                  ),
                );
              }
            },
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.darkTextColor,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.lightTextColor,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }

  Widget _buildWeeklyChart() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week\'s Activity',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkTextColor,
            ),
          ),
          const SizedBox(height: 20),
          
          // Simple bar chart
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar('Mon', 0.3, AppTheme.primaryColor),
                _buildBar('Tue', 0.8, AppTheme.primaryColor),
                _buildBar('Wed', 0.6, AppTheme.primaryColor),
                _buildBar('Thu', 1.0, AppTheme.successColor),
                _buildBar('Fri', 0.4, AppTheme.primaryColor),
                _buildBar('Sat', 0.9, AppTheme.successColor),
                _buildBar('Sun', 0.7, AppTheme.primaryColor),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Study time',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.lightTextColor,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Goal achieved',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.lightTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }

  Widget _buildBar(String day, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedBuilder(
          animation: _counterController,
          builder: (context, child) {
            return Container(
              width: 24,
              height: 80 * height * _counterController.value,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.lightTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildWeakAreas() {
    final weakAreas = [
      {'topic': 'Quantum Mechanics', 'score': 65, 'color': AppTheme.errorColor},
      {'topic': 'Calculus Integration', 'score': 72, 'color': AppTheme.warningColor},
      {'topic': 'Art History Renaissance', 'score': 78, 'color': AppTheme.warningColor},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Areas to Improve',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkTextColor,
            ),
          ),
          const SizedBox(height: 16),
          
          ...weakAreas.asMap().entries.map((entry) {
            final index = entry.key;
            final area = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: area['color'] as Color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      area['topic'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.darkTextColor,
                      ),
                    ),
                  ),
                  Text(
                    '${area['score']}%',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: area['color'] as Color,
                    ),
                  ),
                ],
              ),
            ).animate(delay: Duration(milliseconds: index * 100))
              .fadeIn()
              .slideX(begin: 0.3);
          }).toList(),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'action': 'Completed Quiz', 'subject': 'Physics - Quantum', 'time': '2 hours ago', 'icon': Icons.quiz, 'color': AppTheme.primaryColor},
      {'action': 'Generated Flashcards', 'subject': 'Math - Integration', 'time': '1 day ago', 'icon': Icons.flash_on, 'color': AppTheme.warningColor},
      {'action': 'Studied Notes', 'subject': 'Art History', 'time': '2 days ago', 'icon': Icons.book, 'color': AppTheme.successColor},
      {'action': 'Chat with AI', 'subject': 'Physics Questions', 'time': '3 days ago', 'icon': Icons.chat, 'color': AppTheme.secondaryColor},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkTextColor,
            ),
          ),
          const SizedBox(height: 16),
          
          ...activities.asMap().entries.map((entry) {
            final index = entry.key;
            final activity = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (activity['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      activity['icon'] as IconData,
                      color: activity['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['action'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.darkTextColor,
                          ),
                        ),
                        Text(
                          activity['subject'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.lightTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    activity['time'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                ],
              ),
            ).animate(delay: Duration(milliseconds: index * 100))
              .fadeIn()
              .slideX(begin: 0.3);
          }).toList(),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }

  Widget _buildMotivationalQuote() {
    final quote = _motivationalQuotes[DateTime.now().day % _motivationalQuotes.length];
    
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondaryColor.withOpacity(0.8),
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.format_quote,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 16),
          Text(
            quote,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '💪 Keep pushing forward! 💪',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Your Progress',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStreakSection(),
            _buildCalendarHeatMap(),
            _buildStatsCards(),
            _buildDetailedStats(),
            _buildWeeklyChart(),
            _buildWeakAreas(),
            _buildRecentActivity(),
            _buildMotivationalQuote(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}