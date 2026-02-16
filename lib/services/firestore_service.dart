import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/notebook_model.dart';
import '../models/note_model.dart';
import '../models/flashcard_model.dart';
import '../models/quiz_model.dart';
import '../config/constants.dart';

class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // === USER OPERATIONS ===

  // Create user
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toFirestore());
    } catch (e) {
      debugPrint('Error creating user: $e');
      throw Exception('Failed to create user account');
    }
  }

  // Get user
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user: $e');
      throw Exception('Failed to update user');
    }
  }

  // Update user last login
  Future<void> updateUserLastLogin(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating last login: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      final batch = _firestore.batch();

      // Delete user document
      final userRef = _firestore.collection(AppConstants.usersCollection).doc(userId);
      batch.delete(userRef);

      // Delete user's notebooks
      final notebooksQuery = await _firestore
          .collection(AppConstants.notebooksCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in notebooksQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's notes
      final notesQuery = await _firestore
          .collection(AppConstants.notesCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in notesQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's flashcards
      final flashcardsQuery = await _firestore
          .collection(AppConstants.flashcardsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in flashcardsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's quizzes
      final quizzesQuery = await _firestore
          .collection(AppConstants.quizzesCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in quizzesQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting user: $e');
      throw Exception('Failed to delete user account');
    }
  }

  // === NOTEBOOK OPERATIONS ===

  // Create notebook
  Future<String> createNotebook(NotebookModel notebook) async {
    try {
      _setLoading(true);
      _setError(null);

      final docRef = await _firestore
          .collection(AppConstants.notebooksCollection)
          .add(notebook.toFirestore());

      _setLoading(false);
      return docRef.id;
    } catch (e) {
      _setError('Failed to create notebook');
      _setLoading(false);
      debugPrint('Error creating notebook: $e');
      rethrow;
    }
  }

  // Get user's notebooks
  Stream<List<NotebookModel>> getUserNotebooks(String userId) {
    return _firestore
        .collection(AppConstants.notebooksCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotebookModel.fromFirestore(doc))
            .toList());
  }

  // Get notebook by ID
  Future<NotebookModel?> getNotebook(String notebookId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.notebooksCollection)
          .doc(notebookId)
          .get();

      if (doc.exists) {
        return NotebookModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting notebook: $e');
      return null;
    }
  }

  // Update notebook
  Future<void> updateNotebook(String notebookId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.notebooksCollection)
          .doc(notebookId)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating notebook: $e');
      throw Exception('Failed to update notebook');
    }
  }

  // Delete notebook
  Future<void> deleteNotebook(String notebookId) async {
    try {
      _setLoading(true);
      _setError(null);

      final batch = _firestore.batch();

      // Delete notebook
      final notebookRef = _firestore.collection(AppConstants.notebooksCollection).doc(notebookId);
      batch.delete(notebookRef);

      // Delete all notes in this notebook
      final notesQuery = await _firestore
          .collection(AppConstants.notesCollection)
          .where('notebookId', isEqualTo: notebookId)
          .get();

      for (final doc in notesQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to delete notebook');
      _setLoading(false);
      debugPrint('Error deleting notebook: $e');
      rethrow;
    }
  }

  // === NOTE OPERATIONS ===

  // Create note
  Future<String> createNote(NoteModel note) async {
    try {
      _setLoading(true);
      _setError(null);

      final docRef = await _firestore
          .collection(AppConstants.notesCollection)
          .add(note.toFirestore());

      // Update notebook notes count
      await _updateNotebookNotesCount(note.notebookId);

      _setLoading(false);
      return docRef.id;
    } catch (e) {
      _setError('Failed to create note');
      _setLoading(false);
      debugPrint('Error creating note: $e');
      rethrow;
    }
  }

  // Get notes by notebook
  Stream<List<NoteModel>> getNotebookNotes(String notebookId) {
    return _firestore
        .collection(AppConstants.notesCollection)
        .where('notebookId', isEqualTo: notebookId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromFirestore(doc))
            .toList());
  }

  // Get note by ID
  Future<NoteModel?> getNote(String noteId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .get();

      if (doc.exists) {
        return NoteModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting note: $e');
      return null;
    }
  }

  // Update note
  Future<void> updateNote(String noteId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating note: $e');
      throw Exception('Failed to update note');
    }
  }

  // Delete note
  Future<void> deleteNote(String noteId) async {
    try {
      _setLoading(true);
      _setError(null);

      // Get note to find notebook ID
      final noteDoc = await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .get();

      if (noteDoc.exists) {
        final note = NoteModel.fromFirestore(noteDoc);
        
        // Delete note
        await _firestore
            .collection(AppConstants.notesCollection)
            .doc(noteId)
            .delete();

        // Update notebook notes count
        await _updateNotebookNotesCount(note.notebookId);
      }

      _setLoading(false);
    } catch (e) {
      _setError('Failed to delete note');
      _setLoading(false);
      debugPrint('Error deleting note: $e');
      rethrow;
    }
  }

  // === FLASHCARD OPERATIONS ===

  // Create flashcards
  Future<List<String>> createFlashcards(List<FlashcardModel> flashcards) async {
    try {
      _setLoading(true);
      _setError(null);

      final batch = _firestore.batch();
      final ids = <String>[];

      for (final flashcard in flashcards) {
        final docRef = _firestore.collection(AppConstants.flashcardsCollection).doc();
        batch.set(docRef, flashcard.toFirestore());
        ids.add(docRef.id);
      }

      await batch.commit();

      // Update note flashcard count
      if (flashcards.isNotEmpty) {
        await _updateNoteFlashcardCount(flashcards.first.noteId);
      }

      _setLoading(false);
      return ids;
    } catch (e) {
      _setError('Failed to create flashcards');
      _setLoading(false);
      debugPrint('Error creating flashcards: $e');
      rethrow;
    }
  }

  // Get flashcards by note
  Stream<List<FlashcardModel>> getNoteFlashcards(String noteId) {
    return _firestore
        .collection(AppConstants.flashcardsCollection)
        .where('noteId', isEqualTo: noteId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FlashcardModel.fromFirestore(doc))
            .toList());
  }

  // Get due flashcards for user
  Stream<List<FlashcardModel>> getDueFlashcards(String userId, {int limit = 20}) {
    return _firestore
        .collection(AppConstants.flashcardsCollection)
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .where('nextReviewAt', isLessThanOrEqualTo: Timestamp.now())
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FlashcardModel.fromFirestore(doc))
            .toList());
  }

  // Update flashcard
  Future<void> updateFlashcard(String flashcardId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.flashcardsCollection)
          .doc(flashcardId)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating flashcard: $e');
      throw Exception('Failed to update flashcard');
    }
  }

  // === QUIZ OPERATIONS ===

  // Create quiz
  Future<String> createQuiz(QuizModel quiz) async {
    try {
      _setLoading(true);
      _setError(null);

      final docRef = await _firestore
          .collection(AppConstants.quizzesCollection)
          .add(quiz.toFirestore());

      // Update note quiz count
      await _updateNoteQuizCount(quiz.noteId);

      _setLoading(false);
      return docRef.id;
    } catch (e) {
      _setError('Failed to create quiz');
      _setLoading(false);
      debugPrint('Error creating quiz: $e');
      rethrow;
    }
  }

  // Get quizzes by note
  Stream<List<QuizModel>> getNoteQuizzes(String noteId) {
    return _firestore
        .collection(AppConstants.quizzesCollection)
        .where('noteId', isEqualTo: noteId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuizModel.fromFirestore(doc))
            .toList());
  }

  // Get quiz by ID
  Future<QuizModel?> getQuiz(String quizId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.quizzesCollection)
          .doc(quizId)
          .get();

      if (doc.exists) {
        return QuizModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting quiz: $e');
      return null;
    }
  }

  // Update quiz
  Future<void> updateQuiz(String quizId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.quizzesCollection)
          .doc(quizId)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating quiz: $e');
      throw Exception('Failed to update quiz');
    }
  }

  // === HELPER METHODS ===

  // Update notebook notes count
  Future<void> _updateNotebookNotesCount(String notebookId) async {
    try {
      final notesQuery = await _firestore
          .collection(AppConstants.notesCollection)
          .where('notebookId', isEqualTo: notebookId)
          .get();

      await _firestore
          .collection(AppConstants.notebooksCollection)
          .doc(notebookId)
          .update({
        'notesCount': notesQuery.docs.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating notebook notes count: $e');
    }
  }

  // Update note flashcard count
  Future<void> _updateNoteFlashcardCount(String noteId) async {
    try {
      final flashcardsQuery = await _firestore
          .collection(AppConstants.flashcardsCollection)
          .where('noteId', isEqualTo: noteId)
          .where('isActive', isEqualTo: true)
          .get();

      await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .update({
        'flashcardCount': flashcardsQuery.docs.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating note flashcard count: $e');
    }
  }

  // Update note quiz count
  Future<void> _updateNoteQuizCount(String noteId) async {
    try {
      final quizzesQuery = await _firestore
          .collection(AppConstants.quizzesCollection)
          .where('noteId', isEqualTo: noteId)
          .where('isActive', isEqualTo: true)
          .get();

      await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .update({
        'quizCount': quizzesQuery.docs.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating note quiz count: $e');
    }
  }

  // Get user statistics
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      final notebooks = await _firestore
          .collection(AppConstants.notebooksCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final notes = await _firestore
          .collection(AppConstants.notesCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final flashcards = await _firestore
          .collection(AppConstants.flashcardsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      final quizzes = await _firestore
          .collection(AppConstants.quizzesCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      return {
        'notebooks': notebooks.docs.length,
        'notes': notes.docs.length,
        'flashcards': flashcards.docs.length,
        'quizzes': quizzes.docs.length,
      };
    } catch (e) {
      debugPrint('Error getting user stats: $e');
      return {
        'notebooks': 0,
        'notes': 0,
        'flashcards': 0,
        'quizzes': 0,
      };
    }
  }
}