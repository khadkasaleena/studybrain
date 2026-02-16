import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';

class StudyReminderScreen extends StatefulWidget {
  const StudyReminderScreen({super.key});

  @override
  State<StudyReminderScreen> createState() => _StudyReminderScreenState();
}

class _StudyReminderScreenState extends State<StudyReminderScreen> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  Set<int> _selectedDays = {1, 2, 3, 4, 5}; // Monday to Friday
  bool _remindersEnabled = true;

  final List<String> _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Study Reminders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Stay on Track',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set up study reminders to build a consistent learning habit',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Enable/Disable Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      _remindersEnabled ? Icons.notifications : Icons.notifications_off,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Study Reminders',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Get daily notifications to study',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.lightTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _remindersEnabled,
                      onChanged: (value) {
                        setState(() {
                          _remindersEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            if (_remindersEnabled) ...[
              const SizedBox(height: 32),

              // Time Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminder Time',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectTime(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: AppTheme.primaryColor),
                              const SizedBox(width: 16),
                              Text(
                                _selectedTime.format(context),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              const Icon(Icons.keyboard_arrow_right),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Days Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminder Days',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(7, (index) {
                          final dayIndex = index + 1;
                          final isSelected = _selectedDays.contains(dayIndex);
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedDays.remove(dayIndex);
                                } else {
                                  _selectedDays.add(dayIndex);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? AppTheme.primaryColor 
                                    : Colors.transparent,
                                border: Border.all(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  _dayNames[index],
                                  style: TextStyle(
                                    color: isSelected 
                                        ? Colors.white 
                                        : AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedDays = {1, 2, 3, 4, 5, 6, 7};
                              });
                            },
                            child: const Text('Select All'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedDays = {1, 2, 3, 4, 5};
                              });
                            },
                            child: const Text('Weekdays'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedDays.clear();
                              });
                            },
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Save Button
            CustomButton(
              text: _remindersEnabled ? 'Save Reminders' : 'Turn Off Reminders',
              onPressed: _saveReminders,
              icon: _remindersEnabled ? Icons.save : Icons.notifications_off,
            ),
            const SizedBox(height: 16),

            // Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can always change these settings later in the app settings.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveReminders() {
    // TODO: Implement actual notification scheduling
    // For now, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _remindersEnabled 
              ? 'Reminders saved! You\'ll get notifications at ${_selectedTime.format(context)}'
              : 'Reminders turned off',
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    Navigator.pop(context);
  }
}