import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/notebook_model.dart';
import '../config/theme.dart';
import '../config/routes.dart';

class NotebookCard extends StatelessWidget {
  final NotebookModel notebook;
  final bool isHorizontal;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const NotebookCard({
    super.key,
    required this.notebook,
    this.isHorizontal = false,
    this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => _navigateToNotebook(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isHorizontal ? _buildHorizontalLayout() : _buildVerticalLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon and more button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getNotebookColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  notebook.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            if (onMoreTap != null)
              IconButton(
                onPressed: onMoreTap,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppTheme.lightTextColor,
                  size: 20,
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Title
        Text(
          notebook.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkTextColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 8),
        
        // Description
        if (notebook.description.isNotEmpty) ...[
          Text(
            notebook.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.lightTextColor,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
        ],
        
        const Spacer(),
        
        // Footer with stats
        Row(
          children: [
            Icon(
              Icons.note_outlined,
              size: 16,
              color: AppTheme.lightTextColor,
            ),
            const SizedBox(width: 4),
            Text(
              notebook.notesCountText,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.lightTextColor,
              ),
            ),
            const Spacer(),
            if (notebook.isFavorite)
              const Icon(
                Icons.favorite,
                size: 16,
                color: AppTheme.secondaryColor,
              ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Last modified
        Text(
          notebook.formattedCreatedDate,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.lightTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon and title
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getNotebookColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  notebook.icon,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                notebook.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Notes count
        Row(
          children: [
            Icon(
              Icons.note_outlined,
              size: 14,
              color: AppTheme.lightTextColor,
            ),
            const SizedBox(width: 4),
            Text(
              notebook.notesCountText,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.lightTextColor,
              ),
            ),
            const Spacer(),
            if (notebook.isFavorite)
              const Icon(
                Icons.favorite,
                size: 14,
                color: AppTheme.secondaryColor,
              ),
          ],
        ),
        
        const Spacer(),
        
        // Last modified
        Text(
          notebook.formattedCreatedDate,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.lightTextColor,
          ),
        ),
      ],
    );
  }

  Color _getNotebookColor() {
    try {
      return Color(int.parse(notebook.color.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppTheme.primaryColor;
    }
  }

  void _navigateToNotebook(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRoutes.notebookDetail,
      arguments: notebook,
    );
  }
}

// Empty state widget for notebooks
class EmptyNotebooksWidget extends StatelessWidget {
  final VoidCallback? onCreatePressed;

  const EmptyNotebooksWidget({
    super.key,
    this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.book_outlined,
              size: 60,
              color: AppTheme.primaryColor,
            ),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .then(delay: 200.ms)
              .shimmer(duration: 1500.ms),
          
          const SizedBox(height: 32),
          
          Text(
            'No notebooks yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkTextColor,
                ),
          )
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 12),
          
          Text(
            'Create your first notebook to start\norganizing your study materials',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTextColor,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 600.ms)
              .slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 32),
          
          ElevatedButton.icon(
            onPressed: onCreatePressed,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Notebook'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 800.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}

// Notebook creation bottom sheet
class CreateNotebookBottomSheet extends StatefulWidget {
  const CreateNotebookBottomSheet({super.key});

  @override
  State<CreateNotebookBottomSheet> createState() => _CreateNotebookBottomSheetState();
}

class _CreateNotebookBottomSheetState extends State<CreateNotebookBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedIcon = '📚';
  Color _selectedColor = AppTheme.primaryColor;

  final List<String> _icons = [
    '📚', '📖', '📝', '🔬', '🧮', '🎨', '🌍', '💡',
    '⚡', '🎵', '🏃', '🍎', '💼', '🎯', '🔥', '⭐',
  ];

  final List<Color> _colors = [
    AppTheme.primaryColor,
    AppTheme.secondaryColor,
    Colors.orange,
    Colors.teal,
    Colors.purple,
    Colors.green,
    Colors.blue,
    Colors.red,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            'Create Notebook',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkTextColor,
                ),
          ),
          
          const SizedBox(height: 24),
          
          // Title input
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Notebook Title',
              hintText: 'Enter notebook title',
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description input
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'Enter notebook description',
              prefixIcon: Icon(Icons.description_outlined),
            ),
            maxLines: 2,
          ),
          
          const SizedBox(height: 24),
          
          // Icon selection
          Text(
            'Choose Icon',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkTextColor,
                ),
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _icons.map((icon) {
              final isSelected = icon == _selectedIcon;
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = icon),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Color selection
          Text(
            'Choose Color',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkTextColor,
                ),
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colors.map((color) {
              final isSelected = color == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Create button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createNotebook,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Create Notebook',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          // Safe area bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _createNotebook() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a notebook title'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final notebook = NotebookModel(
      id: '', // Will be set by Firestore
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      userId: '', // Will be set by the caller
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      icon: _selectedIcon,
      color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
    );

    Navigator.of(context).pop(notebook);
  }
}