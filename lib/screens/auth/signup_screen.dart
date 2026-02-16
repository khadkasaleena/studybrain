import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain letters and numbers';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service and Privacy Policy'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    
    final success = await authService.signUpWithEmailAndPassword(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.signupSuccess),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  Future<void> _signUpWithGoogle() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service and Privacy Policy'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    
    final success = await authService.signInWithGoogle();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.signupSuccess),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service & Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Terms of Service',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'By using StudyBrain, you agree to:\n'
                '• Use the app for educational purposes only\n'
                '• Respect intellectual property rights\n'
                '• Not share your account with others\n'
                '• Follow our community guidelines',
              ),
              SizedBox(height: 16),
              Text(
                'Privacy Policy',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'We respect your privacy and:\n'
                '• Only collect necessary data for app functionality\n'
                '• Never sell your personal information\n'
                '• Use encryption to protect your data\n'
                '• Allow you to delete your account anytime',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),

              // Logo and Welcome Text
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    )
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.elasticOut)
                        .then(delay: 200.ms)
                        .shimmer(duration: 1000.ms),

                    const SizedBox(height: 24),

                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkTextColor,
                          ),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 8),

                    Text(
                      'Join thousands of students improving their study habits',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.lightTextColor,
                          ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Sign Up Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      keyboardType: TextInputType.name,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: _validateName,
                    )
                        .animate()
                        .fadeIn(delay: 800.ms)
                        .slideX(begin: -0.3, end: 0),

                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: _validateEmail,
                    )
                        .animate()
                        .fadeIn(delay: 1000.ms)
                        .slideX(begin: -0.3, end: 0),

                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                      validator: _validatePassword,
                      helperText: 'At least 6 characters with letters and numbers',
                    )
                        .animate()
                        .fadeIn(delay: 1200.ms)
                        .slideX(begin: -0.3, end: 0),

                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                      validator: _validateConfirmPassword,
                    )
                        .animate()
                        .fadeIn(delay: 1400.ms)
                        .slideX(begin: -0.3, end: 0),

                    const SizedBox(height: 24),

                    // Terms and Conditions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreeToTerms = !_agreeToTerms;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: AppTheme.lightTextColor,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: _showTermsDialog,
                                        child: const Text(
                                          'Terms of Service',
                                          style: TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: _showTermsDialog,
                                        child: const Text(
                                          'Privacy Policy',
                                          style: TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 1600.ms),

                    const SizedBox(height: 32),

                    // Sign Up Button
                    Consumer<AuthService>(
                      builder: (context, authService, child) {
                        return CustomButton(
                          text: 'Create Account',
                          onPressed: authService.isLoading ? null : _signUp,
                          isLoading: authService.isLoading,
                          icon: Icons.person_add_rounded,
                        );
                      },
                    )
                        .animate()
                        .fadeIn(delay: 1800.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: AppTheme.lightTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 2000.ms),

                    const SizedBox(height: 24),

                    // Google Sign Up Button
                    Consumer<AuthService>(
                      builder: (context, authService, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: authService.isLoading ? null : _signUpWithGoogle,
                            icon: Image.asset(
                              'assets/images/google_logo.png',
                              height: 20,
                              width: 20,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.account_circle,
                                size: 20,
                              ),
                            ),
                            label: Text(
                              authService.isLoading ? 'Creating account...' : 'Sign up with Google',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                        .animate()
                        .fadeIn(delay: 2200.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 32),

                    // Error Message
                    Consumer<AuthService>(
                      builder: (context, authService, child) {
                        if (authService.errorMessage != null) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.errorColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppTheme.errorColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authService.errorMessage!,
                                    style: TextStyle(
                                      color: AppTheme.errorColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: authService.clearError,
                                  icon: Icon(
                                    Icons.close,
                                    color: AppTheme.errorColor,
                                    size: 18,
                                  ),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: -0.3, end: 0);
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: AppTheme.lightTextColor,
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToLogin,
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 2400.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}