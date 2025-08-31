import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';

class CloudinaryService {
  static const String _cloudName = 'doolej613'; // Replace with your Cloudinary cloud name
  static const String _uploadPreset = 'make-your-meal'; // Replace with your upload preset
  
  static final CloudinaryPublic _cloudinary = CloudinaryPublic(
    _cloudName,
    _uploadPreset,
    cache: false,
  );

  // Upload profile picture
  static Future<String> uploadProfilePicture(File imageFile, String userId) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'make_your_meal/profiles',
          publicId: 'profile_$userId',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  // Upload recipe image
  static Future<String> uploadRecipeImage(File imageFile, String recipeId) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'make_your_meal/recipes',
          publicId: 'recipe_$recipeId',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw 'Failed to upload recipe image: $e';
    }
  }

  // Get optimized image URL
  static String getOptimizedImageUrl(String imageUrl, {int? width, int? height}) {
    if (!imageUrl.contains('cloudinary.com')) return imageUrl;
    
    String transformation = '';
    if (width != null || height != null) {
      transformation = 'w_${width ?? 'auto'},h_${height ?? 'auto'},c_fill,f_auto,q_auto/';
    }
    
    final parts = imageUrl.split('/upload/');
    if (parts.length == 2) {
      return '${parts[0]}/upload/$transformation${parts[1]}';
    }
    
    return imageUrl;
  }
}