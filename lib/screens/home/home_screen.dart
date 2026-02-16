import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/notebook_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/notebook_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStudyStreak();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _checkStudyStreak() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.userModel?.shouldUpdateStreak == true) {
      authService.updateStudyStreak();
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          HomeDashboard(),
          NotebooksPage(),
          ProgressPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.surfaceColor,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.lightTextColor,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book_rounded),
              label: 'Notebooks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_outlined),
              activeIcon: Icon(Icons.trending_up_rounded),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(context),
            const SizedBox(height: 24),

            // Study Streak Card
            _buildStudyStreakCard(context),
            const SizedBox(height: 32),

            // Quick Actions
            _buildQuickActions(context),
            const SizedBox(height: 32),

            // Recent Notebooks
            _buildRecentNotebooks(context),
            const SizedBox(height: 32),

            // Study Tips or Motivational Quote
            _buildMotivationalCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.userModel;
        final name = user?.name ?? 'Student';
        final firstName = name.split(' ').first;

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.lightTextColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    firstName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkTextColor,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(25),
                boxShadow: AppTheme.cardShadow,
              ),
              child: user?.profileImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        user!.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, color: Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.3, end: 0);
      },
    );
  }

  Widget _buildStudyStreakCard(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.userModel;
        final streak = user?.studyStreak ?? 0;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.cardShadow,
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
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Study Streak',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$streak ${streak == 1 ? 'day' : 'days'}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      streak > 0 
                          ? 'Keep up the great work! 🔥'
                          : 'Start your learning journey today!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .slideX(begin: -0.3, end: 0);
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkTextColor,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              context,
              icon: Icons.add_photo_alternate_rounded,
              title: 'Upload Notes',
              subtitle: 'Photo or PDF',
              color: AppTheme.primaryColor,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.addNote),
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.quiz_rounded,
              title: 'Flashcards',
              subtitle: 'Study & Review',
              color: AppTheme.secondaryColor,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.flashcards),
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.help_outline_rounded,
              title: 'Quiz',
              subtitle: 'Test Knowledge',
              color: Colors.orange,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.quiz),
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.psychology_rounded,
              title: 'AI Tutor',
              subtitle: 'Get Help',
              color: Colors.teal,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.aiChat),
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkTextColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTextColor,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentNotebooks(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.user == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Notebooks',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkTextColor,
                      ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.notebooks),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: Consumer<FirestoreService>(
                builder: (context, firestoreService, child) {
                  return StreamBuilder<List<NotebookModel>>(
                    stream: firestoreService.getUserNotebooks(authService.user!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading notebooks',
                            style: TextStyle(color: AppTheme.errorColor),
                          ),
                        );
                      }

                      final notebooks = snapshot.data ?? [];

                      if (notebooks.isEmpty) {
                        return _buildEmptyNotebooks(context);
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: notebooks.take(5).length,
                        itemBuilder: (context, index) {
                          final notebook = notebooks[index];
                          return Container(
                            width: 160,
                            margin: EdgeInsets.only(
                              right: index < notebooks.length - 1 ? 16 : 0,
                            ),
                            child: NotebookCard(
                              notebook: notebook,
                              isHorizontal: true,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildEmptyNotebooks(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 48,
            color: AppTheme.lightTextColor,
          ),
          const SizedBox(height: 12),
          Text(
            'No notebooks yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.darkTextColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first notebook to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTextColor,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton.outlined(
            text: 'Create Notebook',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.notebooks),
            icon: Icons.add_rounded,
            width: 250,
            height: 45,
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalCard(BuildContext context) {
    final tips = [
      '💡 Break your study sessions into 25-minute focused blocks',
      '🎯 Set specific learning goals for each study session',
      '📝 Teach someone else what you\'ve learned to reinforce it',
      '🔄 Review your notes within 24 hours of creating them',
      '🌟 Celebrate small wins to stay motivated',
      '📚 Use multiple senses when studying for better retention',
      '⏰ Find your optimal study time and stick to it',
      '🎵 Use background music or silence - whatever works for you',
    ];

    final randomTip = tips[DateTime.now().day % tips.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondaryColor.withOpacity(0.8),
            AppTheme.secondaryColor,
          ],
        ),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Study Tip of the Day',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            randomTip,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }
}

// Placeholder pages for bottom navigation
class NotebooksPage extends StatelessWidget {
  const NotebooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Notebooks Page - Will be implemented'),
    );
  }
}

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Progress Page - Will be implemented'),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings Page - Will be implemented'),
    );
  }
}