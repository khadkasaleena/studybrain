import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _studyReminders = true;
  String _selectedThemeColor = 'purple';
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  String _selectedModel = 'gpt-3.5-turbo';
  final TextEditingController _apiKeyController = TextEditingController();

  final List<Map<String, dynamic>> _themeColors = [
    {'name': 'purple', 'color': AppTheme.primaryColor, 'label': 'Purple'},
    {'name': 'blue', 'color': Colors.blue, 'label': 'Blue'},
    {'name': 'green', 'color': Colors.green, 'label': 'Green'},
    {'name': 'orange', 'color': Colors.orange, 'label': 'Orange'},
    {'name': 'red', 'color': Colors.red, 'label': 'Red'},
    {'name': 'teal', 'color': Colors.teal, 'label': 'Teal'},
  ];

  final List<String> _aiModels = [
    'gpt-3.5-turbo',
    'gpt-4',
    'gpt-4-turbo',
    'claude-3-sonnet',
    'claude-3-haiku',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    // Load settings from ThemeService and SharedPreferences
    final themeService = Provider.of<ThemeService>(context, listen: false);
    setState(() {
      _darkMode = themeService.isDarkMode;
      _notifications = true;
      _studyReminders = true;
      _selectedThemeColor = themeService.selectedColor;
      _reminderTime = const TimeOfDay(hour: 9, minute: 0);
      _selectedModel = 'gpt-3.5-turbo';
    });
  }

  Future<void> _saveSettings() async {
    // Save settings to SharedPreferences
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully!'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              dayPeriodBorderSide: BorderSide(color: AppTheme.primaryColor),
              dayPeriodColor: AppTheme.primaryColor.withOpacity(0.1),
              dialHandColor: AppTheme.primaryColor,
              dialBackgroundColor: AppTheme.backgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      _saveSettings();
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout? You\'ll need to sign in again to access your data.',
          style: GoogleFonts.inter(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showClearDataConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear Cache',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will clear all cached data including images and temporary files. Your notes and progress will be preserved.',
          style: GoogleFonts.inter(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear cache logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cache cleared successfully'),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningColor),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(35),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 35,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'john.doe@example.com',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Premium Member',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Edit profile
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.3);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.darkTextColor,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.darkTextColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.lightTextColor,
                ),
              )
            : null,
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.lightTextColor,
              size: 16,
            ),
        onTap: onTap,
      ),
    ).animate().fadeIn().slideX(begin: 0.3);
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.darkTextColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.lightTextColor,
                ),
              )
            : null,
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    ).animate().fadeIn().slideX(begin: 0.3);
  }

  Widget _buildThemeColorPicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.palette,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Theme Color',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.darkTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _themeColors.map((colorData) {
                  final isSelected = themeService.selectedColor == colorData['name'];
                  return GestureDetector(
                    onTap: () {
                      themeService.setThemeColor(colorData['name']);
                    },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorData['color'],
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: AppTheme.darkTextColor, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (colorData['color'] as Color).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        )
                      : null,
                ),
                  ).animate().scale(delay: Duration(milliseconds: _themeColors.indexOf(colorData) * 100));
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAIModelSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          'AI Model',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.darkTextColor,
          ),
        ),
        subtitle: Text(
          _selectedModel,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.lightTextColor,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.lightTextColor,
          size: 16,
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select AI Model',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ..._aiModels.map((model) {
                    return ListTile(
                      leading: Icon(
                        Icons.auto_awesome,
                        color: _selectedModel == model 
                            ? AppTheme.primaryColor 
                            : AppTheme.lightTextColor,
                      ),
                      title: Text(model),
                      trailing: _selectedModel == model
                          ? Icon(Icons.check, color: AppTheme.primaryColor)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedModel = model;
                        });
                        _saveSettings();
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            
            // Appearance Section
            _buildSectionTitle('🎨 Appearance'),
            Consumer<ThemeService>(
              builder: (context, themeService, child) {
                return _buildSwitchTile(
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  subtitle: 'Toggle dark theme',
                  value: themeService.isDarkMode,
                  onChanged: (value) {
                    themeService.setDarkMode(value);
                  },
                );
              },
            ),
            _buildThemeColorPicker(),
            
            const SizedBox(height: 16),
            
            // Notifications Section
            _buildSectionTitle('🔔 Notifications'),
            _buildSwitchTile(
              icon: Icons.notifications,
              title: 'Push Notifications',
              subtitle: 'Receive app notifications',
              value: _notifications,
              onChanged: (value) {
                setState(() {
                  _notifications = value;
                });
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              icon: Icons.alarm,
              title: 'Study Reminders',
              subtitle: 'Daily study reminders',
              value: _studyReminders,
              onChanged: (value) {
                setState(() {
                  _studyReminders = value;
                });
                _saveSettings();
              },
            ),
            _buildSettingsTile(
              icon: Icons.schedule,
              title: 'Reminder Time',
              subtitle: '${_reminderTime.format(context)}',
              onTap: _selectReminderTime,
            ),
            
            const SizedBox(height: 16),
            
            // AI Settings Section
            _buildSectionTitle('🤖 AI Settings'),
            _buildSettingsTile(
              icon: Icons.key,
              title: 'API Key',
              subtitle: 'Configure your OpenAI API key',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text(
                      'API Key',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    content: TextField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your API key...',
                        labelText: 'OpenAI API Key',
                      ),
                      obscureText: true,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Save API key
                          Navigator.pop(context);
                          _saveSettings();
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildAIModelSelector(),
            
            const SizedBox(height: 16),
            
            // Data Section
            _buildSectionTitle('📊 Data'),
            _buildSettingsTile(
              icon: Icons.download,
              title: 'Export Data',
              subtitle: 'Download your notes and progress',
              onTap: () {
                // TODO: Export data functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Export started. Check your downloads.'),
                    backgroundColor: AppTheme.successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.cleaning_services,
              title: 'Clear Cache',
              subtitle: 'Free up storage space',
              onTap: _showClearDataConfirmation,
            ),
            _buildSettingsTile(
              icon: Icons.storage,
              title: 'Storage Used',
              subtitle: '124 MB of 5 GB used',
              onTap: () {
                // TODO: Show detailed storage usage
              },
            ),
            
            const SizedBox(height: 16),
            
            // Premium Section
            _buildSectionTitle('💎 Premium'),
            _buildSettingsTile(
              icon: Icons.diamond,
              title: 'Current Plan',
              subtitle: 'Premium - Expires Dec 2024',
              iconColor: Colors.amber,
              onTap: () {
                // TODO: Show subscription details
              },
            ),
            _buildSettingsTile(
              icon: Icons.upgrade,
              title: 'Upgrade Plan',
              subtitle: 'Get unlimited features',
              iconColor: Colors.amber,
              onTap: () {
                // TODO: Show upgrade options
              },
            ),
            
            const SizedBox(height: 16),
            
            // About Section
            _buildSectionTitle('ℹ️ About'),
            _buildSettingsTile(
              icon: Icons.info,
              title: 'Version',
              subtitle: '${AppConstants.appVersion} (Build 1.0.1)',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: AppConstants.appVersion,
                  applicationIcon: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  children: [
                    Text(AppConstants.appDescription),
                  ],
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.star,
              title: 'Rate App',
              subtitle: 'Leave us a review',
              onTap: () {
                // TODO: Open app store rating
                _launchUrl('https://apps.apple.com/app/studybrain');
              },
            ),
            _buildSettingsTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'How we protect your data',
              onTap: () {
                _launchUrl('https://studybrain.app/privacy');
              },
            ),
            _buildSettingsTile(
              icon: Icons.description,
              title: 'Terms of Service',
              subtitle: 'Legal terms and conditions',
              onTap: () {
                _launchUrl('https://studybrain.app/terms');
              },
            ),
            
            const SizedBox(height: 24),
            
            // Logout Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showLogoutConfirmation,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ).animate().fadeIn().slideY(begin: 0.3),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}