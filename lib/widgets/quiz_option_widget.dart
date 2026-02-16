import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

enum QuizOptionState { normal, selected, correct, wrong }

class QuizOptionWidget extends StatefulWidget {
  final String letter;
  final String text;
  final QuizOptionState state;
  final VoidCallback? onTap;
  final Duration animationDelay;

  const QuizOptionWidget({
    super.key,
    required this.letter,
    required this.text,
    this.state = QuizOptionState.normal,
    this.onTap,
    this.animationDelay = Duration.zero,
  });

  @override
  State<QuizOptionWidget> createState() => _QuizOptionWidgetState();
}

class _QuizOptionWidgetState extends State<QuizOptionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: AppTheme.primaryColor.withOpacity(0.1),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(QuizOptionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.state != oldWidget.state) {
      if (widget.state == QuizOptionState.correct || 
          widget.state == QuizOptionState.wrong) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  Color _getBackgroundColor() {
    switch (widget.state) {
      case QuizOptionState.normal:
        return Colors.white;
      case QuizOptionState.selected:
        return AppTheme.primaryColor.withOpacity(0.1);
      case QuizOptionState.correct:
        return AppTheme.successColor.withOpacity(0.1);
      case QuizOptionState.wrong:
        return AppTheme.errorColor.withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    switch (widget.state) {
      case QuizOptionState.normal:
        return Colors.grey.shade300;
      case QuizOptionState.selected:
        return AppTheme.primaryColor;
      case QuizOptionState.correct:
        return AppTheme.successColor;
      case QuizOptionState.wrong:
        return AppTheme.errorColor;
    }
  }

  Color _getLetterBackgroundColor() {
    switch (widget.state) {
      case QuizOptionState.normal:
        return AppTheme.backgroundColor;
      case QuizOptionState.selected:
        return AppTheme.primaryColor;
      case QuizOptionState.correct:
        return AppTheme.successColor;
      case QuizOptionState.wrong:
        return AppTheme.errorColor;
    }
  }

  Color _getLetterTextColor() {
    switch (widget.state) {
      case QuizOptionState.normal:
        return AppTheme.darkTextColor;
      case QuizOptionState.selected:
      case QuizOptionState.correct:
      case QuizOptionState.wrong:
        return Colors.white;
    }
  }

  Color _getTextColor() {
    switch (widget.state) {
      case QuizOptionState.normal:
      case QuizOptionState.selected:
        return AppTheme.darkTextColor;
      case QuizOptionState.correct:
        return AppTheme.successColor;
      case QuizOptionState.wrong:
        return AppTheme.errorColor;
    }
  }

  IconData? _getStateIcon() {
    switch (widget.state) {
      case QuizOptionState.correct:
        return Icons.check_circle;
      case QuizOptionState.wrong:
        return Icons.cancel;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getBorderColor(),
                  width: 2,
                ),
                boxShadow: widget.state != QuizOptionState.normal
                    ? [
                        BoxShadow(
                          color: _getBorderColor().withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  // Letter circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getLetterBackgroundColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        widget.letter,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getLetterTextColor(),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Option text
                  Expanded(
                    child: Text(
                      widget.text,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: widget.state == QuizOptionState.selected ||
                                   widget.state == QuizOptionState.correct ||
                                   widget.state == QuizOptionState.wrong
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: _getTextColor(),
                      ),
                    ),
                  ),
                  
                  // State icon
                  if (_getStateIcon() != null) ...[
                    const SizedBox(width: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _getStateIcon(),
                        color: widget.state == QuizOptionState.correct
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        size: 24,
                      ),
                    ).animate().scale(delay: 100.ms).shake(hz: 2),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    ).animate(delay: widget.animationDelay)
      .fadeIn(duration: 300.ms)
      .slideX(begin: 0.3, duration: 400.ms);
  }
}