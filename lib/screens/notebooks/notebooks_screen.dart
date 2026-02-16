import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/notebook_model.dart';
import '../../widgets/notebook_card.dart';
import 'notebook_detail_screen.dart';

enum SortOption { recent, alphabetical, mostNotes }

class NotebooksScreen extends StatefulWidget {
  const NotebooksScreen({super.key});

  @override
  State<NotebooksScreen> createState() => _NotebooksScreenState();
}

class _NotebooksScreenState extends State<NotebooksScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<NotebookModel> _notebooks = [];
  List<NotebookModel> _filteredNotebooks = [];
  SortOption _selectedSortOption = SortOption.recent;
  bool _isLoading = true;
  late AnimationController _fabAnimationController;
  late AnimationController _searchAnimationController;
  
  // Color picker options
  final List<String> _colorOptions = [
    '#6C63FF', '#FF6584', '#4ECDC4', '#45B7D1', 
    '#F9CA24', '#F0932B', '#EB4D4B', '#6C5CE7',
    '#00B894', '#FDCB6E', '#E84393', '#74B9FF'
  ];
  
  // Icon picker options  
  final List<String> _iconOptions = [
    '📚', '📖', '📝', '📊', '🔬', '🎨', '💡', '🏆',
    '🌟', '🎯', '🔥', '💎', '🚀', '⚡', '🎓', '📐'
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _loadNotebooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadNotebooks() async {
    setState(() => _isLoading = true);
    
    // Simulate loading from Firestore
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock data - replace with actual Firestore query
    _notebooks = [
      NotebookModel(
        id: '1',
        title: 'Physics Notes',
        description: 'Quantum mechanics and thermodynamics',
        userId: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        color: '#6C63FF',
        icon: '🔬',
        notesCount: 15,
        tags: ['physics', 'science'],
      ),
      NotebookModel(
        id: '2',
        title: 'Mathematics',
        description: 'Calculus and linear algebra concepts',
        userId: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        color: '#FF6584',
        icon: '📐',
        notesCount: 23,
        tags: ['math', 'calculus'],
      ),
      NotebookModel(
        id: '3',
        title: 'Art History',
        description: 'Renaissance to modern art movements',
        userId: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        color: '#4ECDC4',
        icon: '🎨',
        notesCount: 8,
        tags: ['art', 'history'],
      ),
    ];
    
    _filterAndSortNotebooks();
    setState(() => _isLoading = false);
  }

  void _filterAndSortNotebooks() {
    String query = _searchController.text.toLowerCase();
    
    _filteredNotebooks = _notebooks.where((notebook) {
      return notebook.title.toLowerCase().contains(query) ||
             notebook.description.toLowerCase().contains(query) ||
             notebook.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
    
    // Sort notebooks
    switch (_selectedSortOption) {
      case SortOption.recent:
        _filteredNotebooks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case SortOption.alphabetical:
        _filteredNotebooks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.mostNotes:
        _filteredNotebooks.sort((a, b) => b.notesCount.compareTo(a.notesCount));
        break;
    }
  }

  void _onSearchChanged() {
    setState(() {
      _filterAndSortNotebooks();
    });
  }

  Future<void> _refreshNotebooks() async {
    await _loadNotebooks();
  }

  void _showCreateNotebookDialog() {
    String title = '';
    String description = '';
    String selectedColor = _colorOptions.first;
    String selectedIcon = _iconOptions.first;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppTheme.primaryColor.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(int.parse(selectedColor.replaceFirst('#', '0xFF'))),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          selectedIcon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Create New Notebook',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkTextColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Title field
                TextField(
                  onChanged: (value) => title = value,
                  decoration: const InputDecoration(
                    labelText: 'Notebook Title',
                    hintText: 'Enter notebook title...',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description field
                TextField(
                  onChanged: (value) => description = value,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Brief description of this notebook...',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Color picker
                Text(
                  'Choose Color',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _colorOptions.map((color) {
                    bool isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = color),
                      child: AnimatedContainer(
                        duration: AppConstants.shortAnimation,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected 
                            ? Border.all(color: AppTheme.darkTextColor, width: 3)
                            : null,
                          boxShadow: isSelected ? AppTheme.cardShadow : null,
                        ),
                        child: isSelected 
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                
                // Icon picker
                Text(
                  'Choose Icon',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _iconOptions.map((icon) {
                    bool isSelected = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedIcon = icon),
                      child: AnimatedContainer(
                        duration: AppConstants.shortAnimation,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? AppTheme.primaryColor.withOpacity(0.2)
                            : AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected 
                            ? Border.all(color: AppTheme.primaryColor, width: 2)
                            : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            icon,
                            style: TextStyle(
                              fontSize: 20,
                              color: isSelected ? AppTheme.primaryColor : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: title.isEmpty ? null : () {
                          _createNotebook(title, description, selectedColor, selectedIcon);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(int.parse(selectedColor.replaceFirst('#', '0xFF'))),
                        ),
                        child: const Text('Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => _fabAnimationController.reverse());
  }

  void _createNotebook(String title, String description, String color, String icon) {
    final newNotebook = NotebookModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      userId: 'user1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      color: color,
      icon: icon,
    );
    
    setState(() {
      _notebooks.insert(0, newNotebook);
      _filterAndSortNotebooks();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notebook "$title" created successfully!'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _deleteNotebook(NotebookModel notebook) {
    setState(() {
      _notebooks.removeWhere((n) => n.id == notebook.id);
      _filterAndSortNotebooks();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notebook "${notebook.title}" deleted'),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _notebooks.add(notebook);
              _filterAndSortNotebooks();
            });
          },
        ),
      ),
    );
  }

  void _showSortOptions() {
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
              'Sort Notebooks',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Most Recent'),
              trailing: _selectedSortOption == SortOption.recent
                ? const Icon(Icons.check, color: AppTheme.primaryColor)
                : null,
              onTap: () {
                setState(() {
                  _selectedSortOption = SortOption.recent;
                  _filterAndSortNotebooks();
                });
                Navigator.pop(context);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Alphabetical'),
              trailing: _selectedSortOption == SortOption.alphabetical
                ? const Icon(Icons.check, color: AppTheme.primaryColor)
                : null,
              onTap: () {
                setState(() {
                  _selectedSortOption = SortOption.alphabetical;
                  _filterAndSortNotebooks();
                });
                Navigator.pop(context);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.notes),
              title: const Text('Most Notes'),
              trailing: _selectedSortOption == SortOption.mostNotes
                ? const Icon(Icons.check, color: AppTheme.primaryColor)
                : null,
              onTap: () {
                setState(() {
                  _selectedSortOption = SortOption.mostNotes;
                  _filterAndSortNotebooks();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshNotebooks,
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              snap: true,
              backgroundColor: AppTheme.backgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.1),
                        AppTheme.backgroundColor,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'My Notebooks',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkTextColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _showSortOptions,
                        icon: const Icon(Icons.sort),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.darkTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _onSearchChanged(),
                  decoration: InputDecoration(
                    hintText: 'Search notebooks...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged();
                          },
                        )
                      : null,
                  ),
                ).animate().fadeIn().slideX(begin: -0.2),
              ),
            ),
            
            // Content
            if (_isLoading)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 400,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading your notebooks...',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppTheme.lightTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_filteredNotebooks.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  height: 400,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.library_books_outlined,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _searchController.text.isEmpty 
                          ? 'No notebooks yet' 
                          : 'No notebooks found',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchController.text.isEmpty
                          ? 'Create your first notebook to get started'
                          : 'Try adjusting your search terms',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                      if (_searchController.text.isEmpty) ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showCreateNotebookDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Notebook'),
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn().scale(),
              )
            else
              // Notebooks Grid
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  itemBuilder: (context, index) {
                    final notebook = _filteredNotebooks[index];
                    return Slidable(
                      key: ValueKey(notebook.id),
                      endActionPane: ActionPane(
                        motion: const StretchMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => _deleteNotebook(notebook),
                            backgroundColor: AppTheme.errorColor,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NotebookDetailScreen(notebook: notebook),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
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
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color(int.parse(
                                        notebook.color.replaceFirst('#', '0xFF'))),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        notebook.icon,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (notebook.isFavorite)
                                    Icon(
                                      Icons.favorite,
                                      color: AppTheme.secondaryColor,
                                      size: 20,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                notebook.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.darkTextColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (notebook.description.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  notebook.description,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppTheme.lightTextColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.note,
                                    size: 16,
                                    color: AppTheme.lightTextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    notebook.notesCountText,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.lightTextColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    notebook.formattedCreatedDate,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: AppTheme.lightTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: Duration(milliseconds: index * 100))
                          .slideY(begin: 0.2),
                      ),
                    );
                  },
                  childCount: _filteredNotebooks.length,
                ),
              ),
          ],
        ),
      ),
      
      // Floating Action Button
      floatingActionButton: ScaleTransition(
        scale: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            _fabAnimationController.forward();
            _showCreateNotebookDialog();
          },
          icon: const Icon(Icons.add),
          label: const Text('New Notebook'),
          backgroundColor: AppTheme.primaryColor,
        ),
      ),
    );
  }
}