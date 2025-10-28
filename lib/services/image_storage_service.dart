import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for managing image storage in the application's local storage.
/// Handles saving, retrieving, and managing images with a maximum size limit of 25 MB.
class ImageStorageService {
  static const int maxStorageSizeMB = 25;
  static const int maxStorageSizeBytes = maxStorageSizeMB * 1024 * 1024;
  static const String imagesDirectoryName = 'captured_images';

  /// Get the directory where images are stored
  static Future<Directory> getImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, imagesDirectoryName));

    // Create directory if it doesn't exist
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    return imagesDir;
  }

  /// Save an image from the camera to local storage
  /// Returns the path to the saved image, or null if save failed
  static Future<String?> saveImage(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);

      // Check if source file exists
      if (!await sourceFile.exists()) {
        debugPrint('Source file does not exist: $sourcePath');
        return null;
      }

      // Get the images directory
      final imagesDir = await getImagesDirectory();

      // Check current storage usage
      final currentSize = await _getDirectorySize(imagesDir);
      final fileSize = await sourceFile.length();

      if (currentSize + fileSize > maxStorageSizeBytes) {
        debugPrint('Storage limit exceeded. Current: $currentSize, File: $fileSize, Max: $maxStorageSizeBytes');
        return null;
      }

      // Generate a unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'IMG_$timestamp.jpg';
      final destinationPath = path.join(imagesDir.path, fileName);

      // Copy the file to the images directory
      final savedFile = await sourceFile.copy(destinationPath);

      debugPrint('Image saved successfully: ${savedFile.path}');
      return savedFile.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  /// Get all saved images from local storage
  static Future<List<File>> getSavedImages() async {
    try {
      final imagesDir = await getImagesDirectory();

      if (!await imagesDir.exists()) {
        return [];
      }

      final files = imagesDir.listSync();
      final imageFiles = files
          .whereType<File>()
          .where((file) => _isImageFile(file.path))
          .toList();

      // Sort by modification time (newest first)
      imageFiles.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      return imageFiles;
    } catch (e) {
      debugPrint('Error retrieving images: $e');
      return [];
    }
  }

  /// Delete an image from local storage
  static Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);

      if (await file.exists()) {
        await file.delete();
        debugPrint('Image deleted: $imagePath');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Get the total size of the images directory
  static Future<int> getStorageUsage() async {
    try {
      final imagesDir = await getImagesDirectory();
      return await _getDirectorySize(imagesDir);
    } catch (e) {
      debugPrint('Error getting storage usage: $e');
      return 0;
    }
  }

  /// Get the remaining storage space
  static Future<int> getRemainingStorage() async {
    final used = await getStorageUsage();
    return maxStorageSizeBytes - used;
  }

  /// Calculate the total size of a directory
  static Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;

    try {
      if (await dir.exists()) {
        final files = dir.listSync(recursive: true);
        for (var file in files) {
          if (file is File) {
            size += await file.length();
          }
        }
      }
    } catch (e) {
      debugPrint('Error calculating directory size: $e');
    }

    return size;
  }

  /// Check if a file is an image based on its extension
  static bool _isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(extension);
  }

  /// Get image metadata (creation date, file size)
  static Future<Map<String, dynamic>?> getImageMetadata(String imagePath) async {
    try {
      final file = File(imagePath);

      if (!await file.exists()) {
        return null;
      }

      final stat = file.statSync();
      final fileName = path.basename(imagePath);

      return {
        'path': imagePath,
        'fileName': fileName,
        'size': stat.size,
        'created': stat.modified,
        'sizeInMB': (stat.size / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      debugPrint('Error getting image metadata: $e');
      return null;
    }
  }
}

