import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // GANTI dengan Cloud Name Anda
  static const String cloudName = 'dd8ts7usy';  // ⚠️ GANTI INI
  static const String uploadPreset = 'trash2cash_upload';  // ⚠️ GANTI jika beda
  
  late final CloudinaryPublic cloudinary;

  CloudinaryService() {
    cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
  }

  /// Upload image untuk pickup
  Future<String?> uploadPickupImage(XFile imageFile) async {
    try {
      print('📤 Uploading to Cloudinary...');
      
      final startTime = DateTime.now();
      
      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      print('✅ Image size: ${(bytes.length / 1024).toStringAsFixed(2)} KB');

      // Upload to Cloudinary
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          bytes,
          identifier: imageFile.name,
          folder: 'trash2cash/pickups',  // Folder di Cloudinary
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      final duration = DateTime.now().difference(startTime);
      print('✅ Upload successful!');
      print('📷 Image URL: ${response.secureUrl}');
      print('⏱️ Upload time: ${duration.inSeconds} seconds');

      return response.secureUrl;
      
    } catch (e) {
      print('❌ Cloudinary upload error: $e');
      return null;
    }
  }

  /// Upload profile picture
  Future<String?> uploadProfilePicture(XFile imageFile) async {
    try {
      print('📤 Uploading profile picture to Cloudinary...');
      
      final bytes = await imageFile.readAsBytes();
      
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          bytes,
          identifier: imageFile.name,
          folder: 'trash2cash/profiles',
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      print('✅ Profile picture uploaded: ${response.secureUrl}');
      return response.secureUrl;
      
    } catch (e) {
      print('❌ Error uploading profile picture: $e');
      return null;
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadMultipleImages(List<XFile> imageFiles) async {
    List<String> uploadedUrls = [];

    for (var imageFile in imageFiles) {
      final url = await uploadPickupImage(imageFile);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    print('✅ Uploaded ${uploadedUrls.length}/${imageFiles.length} images');
    return uploadedUrls;
  }

  /// Delete image by public_id (optional)
  Future<bool> deleteImage(String publicId) async {
    try {
      // Note: Deleting requires signed requests (API Secret)
      // Untuk unsigned preset, tidak bisa delete via client
      // Harus delete manual di Cloudinary Dashboard atau via backend
      print('⚠️ Delete harus dilakukan di Cloudinary Dashboard');
      return false;
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }
}