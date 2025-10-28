import 'package:flutter/material.dart';

class GalleryView extends StatelessWidget {
  const GalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Gallery',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Stored images will appear here',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
