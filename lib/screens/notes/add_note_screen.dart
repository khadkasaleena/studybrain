import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/notebook_model.dart';
import '../../models/note_model.dart';

enum InputMethod { camera, gallery, pdf, manual }

class AddNoteScreen extends StatefulWidget {
  final NotebookModel notebook;

  const AddNoteScreen({
    super.key,
    required this.notebook,
  });

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen>
    with TickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  InputMethod? _selectedMethod;
  List<XFile> _selectedImages = [];
  PlatformFile? _selectedPdf;
  bool _isProcessingOCR = false;
  bool _isSaving = false;
  String _extractedText = '';
  late AnimationController _processingController;
  late AnimationController _cardAnimationController;

  @override
  void initState() {
    super.initState();
    _processingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Start card animations
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _processingController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedMethod = InputMethod.camera;
          _selectedImages = [image];
        });
        _processImage(image);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture image. Please try again.');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _selectedMethod = InputMethod.gallery;
          _selectedImages = images;
        });
        
        // Process all images for OCR
        for (final image in images) {
          await _processImage(image);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select images. Please try again.');
    }
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Check file size
        if (file.size > AppConstants.maxPdfSizeMB * 1024 * 1024) {
          _showErrorSnackBar('PDF file is too large. Maximum size is ${AppConstants.maxPdfSizeMB}MB.');
          return;
        }
        
        setState(() {
          _selectedMethod = InputMethod.pdf;
          _selectedPdf = file;
        });
        
        _processPDF(file);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select PDF. Please try again.');
    }
  }

  Future<void> _processImage(XFile image) async {
    setState(() {
      _isProcessingOCR = true;
    });
    
    _processingController.repeat();
    
    try {
      // Simulate OCR processing
      await Future.delayed(const Duration(seconds: 3));
      
      // Mock OCR result - replace with actual OCR service
      String mockOCRText = '''Quantum Mechanics - Chapter 3

The wave function ψ(x,t) is a fundamental concept in quantum mechanics that contains all the information about a quantum system.

Key Principles:
• Wave-particle duality
• Heisenberg uncertainty principle  
• Superposition of states
• Quantum entanglement

The Schrödinger equation describes how the wave function evolves over time:
iℏ ∂ψ/∂t = Ĥψ

Where ĥ is the Hamiltonian operator and ℏ is the reduced Planck constant.''';
      
      setState(() {
        _extractedText = mockOCRText;
        _contentController.text = _extractedText;
        _isProcessingOCR = false;
        if (_titleController.text.isEmpty) {
          _titleController.text = 'Quantum Mechanics Notes';
        }
      });
      
      _processingController.stop();
      _processingController.reset();
      
    } catch (e) {
      setState(() {
        _isProcessingOCR = false;
      });
      _processingController.stop();
      _processingController.reset();
      _showErrorSnackBar('Failed to extract text from image. Please try again.');
    }
  }

  Future<void> _processPDF(PlatformFile pdfFile) async {
    setState(() {
      _isProcessingOCR = true;
    });
    
    _processingController.repeat();
    
    try {
      // Simulate PDF text extraction
      await Future.delayed(const Duration(seconds: 4));
      
      // Mock PDF text extraction result
      String mockPDFText = '''Physics Lecture Notes - Thermodynamics

First Law of Thermodynamics:
The first law of thermodynamics states that energy cannot be created or destroyed, only transformed from one form to another.

ΔU = Q - W

Where:
- ΔU is the change in internal energy
- Q is the heat added to the system
- W is the work done by the system

Second Law of Thermodynamics:
The entropy of an isolated system always increases over time.

Applications:
- Heat engines
- Refrigerators
- Power plants
- Biological systems

The efficiency of a heat engine is limited by the Carnot efficiency:
η = 1 - T_cold/T_hot''';
      
      setState(() {
        _extractedText = mockPDFText;
        _contentController.text = _extractedText;
        _isProcessingOCR = false;
        if (_titleController.text.isEmpty) {
          _titleController.text = 'Thermodynamics - ${pdfFile.name}';
        }
      });
      
      _processingController.stop();
      _processingController.reset();
      
    } catch (e) {
      setState(() {
        _isProcessingOCR = false;
      });
      _processingController.stop();
      _processingController.reset();
      _showErrorSnackBar('Failed to extract text from PDF. Please try again.');
    }
  }

  void _selectManualInput() {
    setState(() {
      _selectedMethod = InputMethod.manual;
    });
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a note title.');
      return;
    }

    if (_contentController.text.trim().isEmpty && 
        _selectedImages.isEmpty && 
        _selectedPdf == null) {
      _showErrorSnackBar('Please add some content to your note.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Simulate saving to Firestore
      await Future.delayed(const Duration(seconds: 2));
      
      // Create note model (in real implementation, this would save to Firestore)
      final newNote = NoteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        notebookId: widget.notebook.id,
        userId: 'user1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        type: _getNoteType(),
        imageUrls: _selectedImages.isNotEmpty 
          ? ['https://example.com/uploaded_image.jpg'] 
          : [],
        fileUrl: _selectedPdf != null 
          ? 'https://example.com/uploaded_file.pdf' 
          : null,
        fileName: _selectedPdf?.name,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note "${newNote.title}" saved successfully!'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      // Return to previous screen with success result
      Navigator.pop(context, true);
      
    } catch (e) {
      _showErrorSnackBar('Failed to save note. Please try again.');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  NoteType _getNoteType() {
    if (_selectedImages.isNotEmpty) return NoteType.image;
    if (_selectedPdf != null) return NoteType.pdf;
    return NoteType.text;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildInputMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int index,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
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
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: index * 150))
        .fadeIn()
        .slideX(begin: 0.3)
        .then()
        .shimmer(delay: Duration(milliseconds: 1000 + index * 200)),
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          RotationTransition(
            turns: _processingController,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedMethod == InputMethod.pdf ? 'Extracting text from PDF...' : 'Extracting text from image...',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few moments',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.lightTextColor,
            ),
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            backgroundColor: AppTheme.backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1500.ms),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(int.parse(widget.notebook.color.replaceFirst('#', '0xFF'))),
                  Color(int.parse(widget.notebook.color.replaceFirst('#', '0xFF')))
                    .withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getMethodIcon(),
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _getMethodTitle(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview images/PDF
                if (_selectedImages.isNotEmpty) ...[
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_selectedImages[index].path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                if (_selectedPdf != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          color: AppTheme.errorColor,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedPdf!.name,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.darkTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${(_selectedPdf!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.lightTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Title field
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Note Title',
                    hintText: 'Enter a title for your note...',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Content field
                TextField(
                  controller: _contentController,
                  maxLines: 12,
                  decoration: InputDecoration(
                    labelText: 'Note Content',
                    hintText: _selectedMethod == InputMethod.manual 
                      ? 'Start typing your note...'
                      : 'Extracted text will appear here...',
                    alignLabelWithHint: true,
                  ),
                ),
                
                if (_extractedText.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.successColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Text extracted successfully! You can edit it above.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
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
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }

  IconData _getMethodIcon() {
    switch (_selectedMethod!) {
      case InputMethod.camera:
        return Icons.camera_alt;
      case InputMethod.gallery:
        return Icons.photo_library;
      case InputMethod.pdf:
        return Icons.picture_as_pdf;
      case InputMethod.manual:
        return Icons.edit;
    }
  }

  String _getMethodTitle() {
    switch (_selectedMethod!) {
      case InputMethod.camera:
        return 'Camera Capture';
      case InputMethod.gallery:
        return 'Gallery Images';
      case InputMethod.pdf:
        return 'PDF Document';
      case InputMethod.manual:
        return 'Manual Input';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Add Note',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          if (_selectedMethod != null)
            TextButton(
              onPressed: _isSaving ? null : _saveNote,
              child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
            ),
        ],
      ),
      body: _selectedMethod == null
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
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
                                widget.notebook.color.replaceFirst('#', '0xFF'))),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                widget.notebook.icon,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Adding to ${widget.notebook.title}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.lightTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'How would you like to add your note?',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose your preferred input method',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideX(begin: -0.3),
                
                const SizedBox(height: 32),
                
                // Input method cards
                _buildInputMethodCard(
                  title: 'Take Photo',
                  subtitle: 'Capture text with camera',
                  icon: Icons.camera_alt,
                  color: AppTheme.primaryColor,
                  onTap: _pickFromCamera,
                  index: 0,
                ),
                
                _buildInputMethodCard(
                  title: 'Choose from Gallery',
                  subtitle: 'Select images from gallery',
                  icon: Icons.photo_library,
                  color: AppTheme.secondaryColor,
                  onTap: _pickFromGallery,
                  index: 1,
                ),
                
                _buildInputMethodCard(
                  title: 'Upload PDF',
                  subtitle: 'Extract text from document',
                  icon: Icons.picture_as_pdf,
                  color: AppTheme.warningColor,
                  onTap: _pickPDF,
                  index: 2,
                ),
                
                _buildInputMethodCard(
                  title: 'Type Manually',
                  subtitle: 'Write your own notes',
                  icon: Icons.edit,
                  color: AppTheme.successColor,
                  onTap: _selectManualInput,
                  index: 3,
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          )
        : _isProcessingOCR
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildProcessingIndicator(),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildPreviewSection(),
                  const SizedBox(height: 100), // Space for save button
                ],
              ),
            ),
    );
  }
}