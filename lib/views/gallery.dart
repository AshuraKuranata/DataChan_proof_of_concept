import 'package:flutter/material.dart';
import 'package:proof_of_concept_v1/components/gallery/gallery_component.dart';

/// Gallery view that displays all images captured by the camera.
/// Shows images in a grid layout with options to view and delete them.
class GalleryView extends StatelessWidget {
  const GalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryComponent();
  }
}
