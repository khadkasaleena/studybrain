import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/notebooks/notebooks_screen.dart';
import 'screens/notebooks/notebook_detail_screen.dart';
import 'screens/notes/note_detail_screen.dart';
import 'screens/notes/add_note_screen.dart';
import 'screens/study/flashcard_screen.dart';
import 'screens/study/quiz_screen.dart';
import 'screens/chat/ai_chat_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'models/notebook_model.dart';
import 'models/note_model.dart';
import 'models/flashcard_model.dart';
import 'models/quiz_model.dart';

class StudyBrainApp extends StatelessWidget {
  const StudyBrainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyBrain',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.splash:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case AppRoutes.onboarding:
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case AppRoutes.signup:
            return MaterialPageRoute(builder: (_) => const SignupScreen());
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case AppRoutes.notebooks:
            return MaterialPageRoute(builder: (_) => const NotebooksScreen());
          case AppRoutes.notebookDetail:
            final notebook = settings.arguments as NotebookModel;
            return MaterialPageRoute(
              builder: (_) => NotebookDetailScreen(notebook: notebook),
            );
          case AppRoutes.noteDetail:
            final note = settings.arguments as NoteModel;
            return MaterialPageRoute(
              builder: (_) => NoteDetailScreen(note: note),
            );
          case AppRoutes.addNote:
            final notebook = settings.arguments as NotebookModel;
            return MaterialPageRoute(
              builder: (_) => AddNoteScreen(notebook: notebook),
            );
          case AppRoutes.flashcards:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => FlashcardScreen(
                flashcards: args['flashcards'] as List<FlashcardModel>,
                title: args['title'] as String? ?? 'Study Flashcards',
              ),
            );
          case AppRoutes.quiz:
            final quiz = settings.arguments as QuizModel;
            return MaterialPageRoute(
              builder: (_) => QuizScreen(quiz: quiz),
            );
          case AppRoutes.aiChat:
            final note = settings.arguments as NoteModel?;
            return MaterialPageRoute(
              builder: (_) => AIChatScreen(note: note),
            );
          case AppRoutes.progress:
            return MaterialPageRoute(builder: (_) => const ProgressScreen());
          case AppRoutes.settings:
            return MaterialPageRoute(builder: (_) => const SettingsScreen());
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
      builder: (context, child) {
        return Consumer<AuthService>(
          builder: (context, auth, _) {
            // Auto navigation based on auth state is handled in SplashScreen
            return child!;
          },
        );
      },
    );
  }
}
