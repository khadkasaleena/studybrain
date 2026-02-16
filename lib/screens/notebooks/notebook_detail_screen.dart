import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/notebook_model.dart';
import '../../models/note_model.dart';
import '../notes/note_detail_screen.dart';
import '../notes/add_note_screen.dart';

class NotebookDetailScreen extends StatefulWidget {
  final NotebookModel notebook;

  const NotebookDetailScreen({
    super.key,
    required this.notebook,
  });

  @override
  State<NotebookDetailScreen> createState() => _NotebookDetailScreenState();
}

class _NotebookDetailScreenState extends State<NotebookDetailScreen>
    with TickerProviderStateMixin {
  List<NoteModel> _notes = [];
  bool _isLoading = true;
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadNotes();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    
    // Simulate loading from Firestore
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Mock data - replace with actual Firestore query
    _notes = [
      NoteModel(
        id: '1',
        title: 'Quantum Mechanics Basics',
        content: '''# Quantum Mechanics Fundamentals

## Wave-Particle Duality
Light and matter exhibit both wave and particle properties depending on how they are observed.

## Heisenberg Uncertainty Principle
It's impossible to simultaneously know both the exact position and momentum of a particle.

## Schrödinger Equation
The fundamental equation that describes how the quantum state of a physical system changes with time.

### Key Points:
- Quantum states are described by wavefunctions
- Measurement causes wavefunction collapse
- Quantum entanglement connects particles across space

This is a foundational concept in modern physics that revolutionized our understanding of the microscopic world.''',
        notebookId: widget.notebook.id,
        userId: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        type: NoteType.text,
        tags: ['quantum', 'physics', 'theory'],
        flashcardCount: 12,
        quizCount: 5,
        lastStudiedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      NoteModel(
        id: '2',
        title: 'Thermodynamics Laws',
        content: '''# The Four Laws of Thermodynamics

## First Law (Conservation of Energy)
Energy cannot be created or destroyed, only transformed from one form to another.

## Second Law (Entropy)
The entropy of an isolated system always increases over time.

## Third Law (Absolute Zero)
The entropy of a perfect crystal approaches zero as temperature approaches absolute zero.

## Zeroth Law (Thermal Equilibrium)
If two systems are in thermal equilibrium with a third system, they are in thermal equilibrium with each other.

These laws form the foundation of thermal physics and have applications in engines, refrigerators, and all energy transformations.''',
        notebookId: widget.notebook.id,
        userId: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        type: NoteType.text,
        tags: ['thermodynamics', 'physics', 'laws'],
        flashcardCount: 8,
        quizCount: 3,
        lastStudiedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      NoteModel(
        id: '3',
        title: 'Lab Equipment Diagram',
        content: 'Diagram showing various physics lab equipment and their uses in experiments.',
        notebookId: widget.notebook.id,
        userId: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
        type: NoteType.image,
        imageUrls: ['https://example.com/lab-equipment.jpg'],
        tags: ['lab', 'equipment', 'physics'],
        flashcardCount: 0,
        quizCount: 0,
      ),
    ];
    
    setState(() => _isLoading = false);
  }

  Future<void> _refreshNotes() async {
    _refreshController.forward();
    await _loadNotes();
    _refreshController.reset();
  }

  void _deleteNote(NoteModel note) {
    setState(() {
      _notes.removeWhere((n) => n.id == note.id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Note "${note.title}" deleted'),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _notes.add(note);
              _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            });
          },
        ),
      ),
    );
  }

  void _navigateToAddNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddNoteScreen(notebook: widget.notebook),
      ),
    );
    
    if (result == true) {
      _refreshNotes();
    }
  }

  Widget _buildNoteCard(NoteModel note, int index) {
    return Slidable(
      key: ValueKey(note.id),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _deleteNote(note),
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
              builder: (_) => NoteDetailScreen(note: note),
            ),
          );
        },
        child: Container(
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
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _getNoteTypeColor(note.type),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        note.typeIcon,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          note.typeDisplayName,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.lightTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (note.isFavorite)
                    Icon(
                      Icons.favorite,
                      color: AppTheme.secondaryColor,
                      size: 18,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              Text(
                note.contentPreview,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.darkTextColor,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: note.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  if (note.totalStudyItems > 0) ...[
                    _buildStudyIndicator(
                      Icons.flash_on,
                      '${note.flashcardCount}',
                      AppTheme.warningColor,
                    ),
                    const SizedBox(width: 12),
                    _buildStudyIndicator(
                      Icons.quiz,
                      '${note.quizCount}',
                      AppTheme.primaryColor,
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  
                  Text(
                    note.formattedCreatedDate,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                ],
              ),
              
              if (note.lastStudiedAt != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school,
                        size: 12,
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Last studied ${_formatRelativeTime(note.lastStudiedAt!)}',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: index * 100))
          .slideX(begin: 0.2),
      ),
    );
  }

  Widget _buildStudyIndicator(IconData icon, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            count,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getNoteTypeColor(NoteType type) {
    switch (type) {
      case NoteType.text:
        return AppTheme.primaryColor.withOpacity(0.2);
      case NoteType.image:
        return AppTheme.secondaryColor.withOpacity(0.2);
      case NoteType.pdf:
        return AppTheme.warningColor.withOpacity(0.2);
      case NoteType.voice:
        return AppTheme.successColor.withOpacity(0.2);
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notebookColor = Color(int.parse(
      widget.notebook.color.replaceFirst('#', '0xFF')));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshNotes,
        color: notebookColor,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: notebookColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        notebookColor,
                        notebookColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.notebook.icon,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.notebook.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (widget.notebook.description.isNotEmpty)
                                      Text(
                                        widget.notebook.description,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildStatChip(
                                Icons.note,
                                _notes.length.toString(),
                                _notes.length == 1 ? 'Note' : 'Notes',
                              ),
                              const SizedBox(width: 12),
                              if (_notes.isNotEmpty)
                                _buildStatChip(
                                  Icons.access_time,
                                  '',
                                  'Updated ${widget.notebook.formattedCreatedDate}',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Content
            if (_isLoading)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RotationTransition(
                          turns: _refreshController,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: notebookColor,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading notes...',
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
            else if (_notes.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  height: 400,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: notebookColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.note_add_outlined,
                            size: 50,
                            color: notebookColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No notes in this notebook',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first note to get started',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _navigateToAddNote,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Note'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: notebookColor,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(),
              )
            else
              // Notes List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildNoteCard(_notes[index], index),
                  childCount: _notes.length,
                ),
              ),
            
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddNote,
        backgroundColor: notebookColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count.isNotEmpty) ...[
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
          ],
          Text(
            count.isNotEmpty ? '$count $label' : label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}