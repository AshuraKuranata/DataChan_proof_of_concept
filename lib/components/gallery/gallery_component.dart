import 'dart:io';
import 'package:flutter/material.dart';
import 'package:proof_of_concept_v1/services/image_storage_service.dart';

/// Gallery component that displays images taken by the camera.
/// Shows a grid of saved images with options to view and delete them.
class GalleryComponent extends StatefulWidget {
  const GalleryComponent({super.key});

  @override
  State<GalleryComponent> createState() => _GalleryComponentState();
}

class _GalleryComponentState extends State<GalleryComponent> {
  late Future<List<File>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  /// Load images from local storage
  void _loadImages() {
    _imagesFuture = ImageStorageService.getSavedImages();
  }

  /// Refresh the gallery by reloading images
  Future<void> _refreshGallery() async {
    setState(() {
      _loadImages();
    });
  }

  /// Delete an image and refresh the gallery
  Future<void> _deleteImage(String imagePath) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ImageStorageService.deleteImage(imagePath);
      if (success && mounted) {
        _refreshGallery();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// View image in full screen
  void _viewImage(String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(imagePath: imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshGallery,
      child: FutureBuilder<List<File>>(
        future: _imagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading images: ${snapshot.error}'),
            );
          }

          final images = snapshot.data ?? [];

          if (images.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No images yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take a picture to get started',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imageFile = images[index];
              return GalleryImageTile(
                imageFile: imageFile,
                onTap: () => _viewImage(imageFile.path),
                onDelete: () => _deleteImage(imageFile.path),
              );
            },
          );
        },
      ),
    );
  }
}

/// A tile widget that displays a single image in the gallery grid.
class GalleryImageTile extends StatelessWidget {
  final File imageFile;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const GalleryImageTile({
    super.key,
    required this.imageFile,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.file(
              imageFile,
              fit: BoxFit.cover,
            ),
            // Delete button overlay
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full screen image viewer
class FullScreenImageView extends StatelessWidget {
  final String imagePath;

  const FullScreenImageView({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}

