import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadImage(XFile imageFile, String path) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ User tidak login');
        return null;
      }

      final startTime = DateTime.now();  // ✅ START TIMER
      print('📤 Mulai upload gambar ke $path...');

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('$path/${user.uid}/$fileName');

      print('📷 Reading image bytes...');
      final bytes = await imageFile.readAsBytes();
      print('✅ Image size: ${(bytes.length / 1024).toStringAsFixed(2)} KB');

      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('📊 Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      final duration = DateTime.now().difference(startTime);  // ✅ END TIMER
      print('✅ Upload berhasil! URL: $downloadUrl');
      print('⏱️ Upload time: ${duration.inSeconds} seconds');  // ✅ PRINT TIME
      
      return downloadUrl;

    } on FirebaseException catch (e) {
      print('❌ Firebase Error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('❌ Error upload: $e');
      return null;
    }
  }
  /// Upload profile picture (juga update ke XFile)
  Future<String?> uploadProfilePicture(XFile imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ User tidak login');
        return null;
      }

      print('📤 Mulai upload profile picture...');

      final String fileName = 'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('profile_pictures/${user.uid}/$fileName');

      final bytes = await imageFile.readAsBytes();

      final UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': user.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('📊 Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Upload berhasil! URL: $downloadUrl');
      return downloadUrl;

    } on FirebaseException catch (e) {
      print('❌ Firebase Error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  /// Upload multiple images (juga update)
  Future<List<String>> uploadMultipleImages(List<XFile> imageFiles, String path) async {
    List<String> uploadedUrls = [];

    for (var imageFile in imageFiles) {
      final url = await uploadImage(imageFile, path);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    print('✅ Uploaded ${uploadedUrls.length}/${imageFiles.length} images');
    return uploadedUrls;
  }
  /// Delete image by URL
  Future<bool> deleteImageByUrl(String imageUrl) async {
    try {
      print('🗑️ Menghapus gambar...');
      
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      
      print('✅ Gambar berhasil dihapus');
      return true;
    } on FirebaseException catch (e) {
      print('❌ Firebase Error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('❌ Error delete: $e');
      return false;
    }
  }

  /// Delete all user images in a folder
  Future<bool> deleteUserFolder(String folderPath) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final Reference ref = _storage.ref().child('$folderPath/${user.uid}');
      final ListResult result = await ref.listAll();

      // Delete semua file dalam folder
      for (var item in result.items) {
        await item.delete();
      }

      print('✅ Folder berhasil dihapus');
      return true;
    } catch (e) {
      print('❌ Error delete folder: $e');
      return false;
    }
  }

  /// Get all images URL from a folder
  Future<List<String>> getUserImages(String folderPath) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final Reference ref = _storage.ref().child('$folderPath/${user.uid}');
      final ListResult result = await ref.listAll();

      List<String> urls = [];
      for (var item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }

      print('✅ Found ${urls.length} images');
      return urls;
    } catch (e) {
      print('❌ Error get images: $e');
      return [];
    }
  }

  /// Get file metadata
  Future<FullMetadata?> getFileMetadata(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      final FullMetadata metadata = await ref.getMetadata();
      return metadata;
    } catch (e) {
      print('❌ Error get metadata: $e');
      return null;
    }
  }

  /// Get upload progress stream
  Stream<double> getUploadProgress(UploadTask uploadTask) {
    return uploadTask.snapshotEvents.map((snapshot) {
      return snapshot.bytesTransferred / snapshot.totalBytes;
    });
  }
}