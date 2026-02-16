import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../config/constants.dart';

class StorageService extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  // Getters
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;

  void _setUploading(bool uploading) {
    _isUploading = uploading;
    notifyListeners();
  }

  void _setProgress(double progress) {
    _uploadProgress = progress;
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

  // Upload profile image
  Future<String?> uploadProfileImage(String userId, {ImageSource source = ImageSource.gallery}) async {
    try {
      _setUploading(true);
      _setError(null);
      _setProgress(0.0);

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) {
        _setUploading(false);
        return null;
      }

      // Check file size
      final int fileSize = await image.length();
      if (fileSize > AppConstants.maxImageSizeMB * 1024 * 1024) {
        _setError('Image size must be less than ${AppConstants.maxImageSizeMB}MB');
        _setUploading(false);
        return null;
      }

      final String fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${AppConstants.profileImagesPath}/$fileName';

      final Reference storageRef = _storage.ref().child(filePath);
      
      Uint8List imageData;
      if (kIsWeb) {
        imageData = await image.readAsBytes();
      } else {
        imageData = await File(image.path).readAsBytes();
      }

      final UploadTask uploadTask = storageRef.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        _setProgress(progress);
      });

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      _setUploading(false);
      _setProgress(0.0);
      return downloadUrl;
    } catch (e) {
      _setError('Failed to upload profile image');
      _setUploading(false);
      _setProgress(0.0);
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  // Upload note image
  Future<String?> uploadNoteImage(String userId, String noteId, {ImageSource source = ImageSource.gallery}) async {
    try {
      _setUploading(true);
      _setError(null);
      _setProgress(0.0);

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1600,
        imageQuality: 90,
      );

      if (image == null) {
        _setUploading(false);
        return null;
      }

      // Check file size
      final int fileSize = await image.length();
      if (fileSize > AppConstants.maxImageSizeMB * 1024 * 1024) {
        _setError('Image size must be less than ${AppConstants.maxImageSizeMB}MB');
        _setUploading(false);
        return null;
      }

      final String fileName = '${noteId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${AppConstants.noteImagesPath}/$userId/$fileName';

      final Reference storageRef = _storage.ref().child(filePath);
      
      Uint8List imageData;
      if (kIsWeb) {
        imageData = await image.readAsBytes();
      } else {
        imageData = await File(image.path).readAsBytes();
      }

      final UploadTask uploadTask = storageRef.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        _setProgress(progress);
      });

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      _setUploading(false);
      _setProgress(0.0);
      return downloadUrl;
    } catch (e) {
      _setError('Failed to upload image');
      _setUploading(false);
      _setProgress(0.0);
      debugPrint('Error uploading note image: $e');
      return null;
    }
  }

  // Pick and upload multiple images
  Future<List<String>> uploadMultipleImages(String userId, String noteId) async {
    try {
      _setUploading(true);
      _setError(null);
      _setProgress(0.0);

      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1600,
        imageQuality: 90,
      );

      if (images.isEmpty) {
        _setUploading(false);
        return [];
      }

      final List<String> uploadedUrls = [];
      
      for (int i = 0; i < images.length; i++) {
        final XFile image = images[i];
        
        // Check file size
        final int fileSize = await image.length();
        if (fileSize > AppConstants.maxImageSizeMB * 1024 * 1024) {
          _setError('Image ${i + 1} is too large (max ${AppConstants.maxImageSizeMB}MB)');
          continue;
        }

        final String fileName = '${noteId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final String filePath = '${AppConstants.noteImagesPath}/$userId/$fileName';

        final Reference storageRef = _storage.ref().child(filePath);
        
        Uint8List imageData;
        if (kIsWeb) {
          imageData = await image.readAsBytes();
        } else {
          imageData = await File(image.path).readAsBytes();
        }

        final UploadTask uploadTask = storageRef.putData(
          imageData,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        uploadedUrls.add(downloadUrl);

        // Update progress
        _setProgress((i + 1) / images.length);
      }

      _setUploading(false);
      _setProgress(0.0);
      return uploadedUrls;
    } catch (e) {
      _setError('Failed to upload images');
      _setUploading(false);
      _setProgress(0.0);
      debugPrint('Error uploading multiple images: $e');
      return [];
    }
  }

  // Upload PDF file
  Future<Map<String, String>?> uploadPdfFile(String userId, String noteId) async {
    try {
      _setUploading(true);
      _setError(null);
      _setProgress(0.0);

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.supportedDocumentTypes,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        _setUploading(false);
        return null;
      }

      final PlatformFile file = result.files.first;

      // Check file size
      if (file.size > AppConstants.maxPdfSizeMB * 1024 * 1024) {
        _setError('File size must be less than ${AppConstants.maxPdfSizeMB}MB');
        _setUploading(false);
        return null;
      }

      final String fileName = '${noteId}_${DateTime.now().millisecondsSinceEpoch}.${file.extension}';
      final String filePath = '${AppConstants.noteFilesPath}/$userId/$fileName';

      final Reference storageRef = _storage.ref().child(filePath);

      Uint8List fileData;
      if (kIsWeb) {
        fileData = file.bytes!;
      } else {
        fileData = await File(file.path!).readAsBytes();
      }

      final UploadTask uploadTask = storageRef.putData(
        fileData,
        SettableMetadata(contentType: 'application/pdf'),
      );

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        _setProgress(progress);
      });

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      _setUploading(false);
      _setProgress(0.0);
      
      return {
        'url': downloadUrl,
        'name': file.name,
      };
    } catch (e) {
      _setError('Failed to upload PDF');
      _setUploading(false);
      _setProgress(0.0);
      debugPrint('Error uploading PDF: $e');
      return null;
    }
  }

  // Upload image from camera
  Future<String?> captureAndUploadImage(String userId, String noteId) async {
    return uploadNoteImage(userId, noteId, source: ImageSource.camera);
  }

  // Delete file from storage
  Future<bool> deleteFile(String downloadUrl) async {
    try {
      final Reference ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  // Get file metadata
  Future<Map<String, dynamic>?> getFileMetadata(String downloadUrl) async {
    try {
      final Reference ref = _storage.refFromURL(downloadUrl);
      final FullMetadata metadata = await ref.getMetadata();
      
      return {
        'name': ref.name,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated,
        'updated': metadata.updated,
      };
    } catch (e) {
      debugPrint('Error getting file metadata: $e');
      return null;
    }
  }

  // Get download URL from path
  Future<String?> getDownloadUrl(String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error getting download URL: $e');
      return null;
    }
  }

  // Check if file exists
  Future<bool> fileExists(String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper method to validate file type
  bool isValidImageType(String fileName) {
    final String extension = fileName.toLowerCase().split('.').last;
    return AppConstants.supportedImageTypes.contains(extension);
  }

  // Helper method to validate document type
  bool isValidDocumentType(String fileName) {
    final String extension = fileName.toLowerCase().split('.').last;
    return AppConstants.supportedDocumentTypes.contains(extension);
  }

  // Helper method to format file size
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Get storage usage for user
  Future<Map<String, dynamic>> getUserStorageUsage(String userId) async {
    try {
      int totalSize = 0;
      int imageCount = 0;
      int documentCount = 0;

      // Get profile images
      final ListResult profileResult = await _storage
          .ref()
          .child(AppConstants.profileImagesPath)
          .listAll();

      for (final Reference ref in profileResult.items) {
        if (ref.name.contains(userId)) {
          final FullMetadata metadata = await ref.getMetadata();
          totalSize += metadata.size ?? 0;
          imageCount++;
        }
      }

      // Get note images
      final ListResult imageResult = await _storage
          .ref()
          .child('${AppConstants.noteImagesPath}/$userId')
          .listAll();

      for (final Reference ref in imageResult.items) {
        final FullMetadata metadata = await ref.getMetadata();
        totalSize += metadata.size ?? 0;
        imageCount++;
      }

      // Get note documents
      final ListResult documentResult = await _storage
          .ref()
          .child('${AppConstants.noteFilesPath}/$userId')
          .listAll();

      for (final Reference ref in documentResult.items) {
        final FullMetadata metadata = await ref.getMetadata();
        totalSize += metadata.size ?? 0;
        documentCount++;
      }

      return {
        'totalSize': totalSize,
        'formattedSize': formatFileSize(totalSize),
        'imageCount': imageCount,
        'documentCount': documentCount,
        'totalFiles': imageCount + documentCount,
      };
    } catch (e) {
      debugPrint('Error getting storage usage: $e');
      return {
        'totalSize': 0,
        'formattedSize': '0 B',
        'imageCount': 0,
        'documentCount': 0,
        'totalFiles': 0,
      };
    }
  }
}