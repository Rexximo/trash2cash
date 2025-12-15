import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trash2cash/models/user_role.dart';

final _fireAuth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  UserRole? _currentUserRole;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserRole? get currentUserRole => _currentUserRole;

  // Method untuk menyimpan user data ke Firestore
  Future<void> _saveUserToFirestore(
    User user, {
    String? displayName,
    required UserRole role, // TAMBAHKAN parameter role
  }) async {
    try {
      print('⚠️ Menyimpan user dengan role: ${role.name}');
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': displayName ?? user.email?.split('@')[0],
        'role': role.name, // TAMBAHKAN field role
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
      print('✅ User berhasil disimpan dengan role: ${role.name}');
    } catch (e) {
      print('❌ Error saving user: $e');
    }
  }

  // Method untuk update last login
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }


  Future<bool> signUp(
    String email,
    String password, {
    String? displayName,
    required UserRole role, // TAMBAHKAN parameter role
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _fireAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _saveUserToFirestore(
          userCredential.user!,
          displayName: displayName,
          role: role, // KIRIM role
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      // ... error handling yang sama ...
      _isLoading = false;
      if (e.code == 'email-already-in-use') {
        _errorMessage = 'Email sudah terdaftar';
      } else if (e.code == 'weak-password') {
        _errorMessage = 'Password terlalu lemah';
      } else {
        _errorMessage = 'Registrasi gagal: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  // UPDATE method signIn untuk ambil role
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _fireAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        final doc = await _firestore.collection('users').doc(uid).get();

        if (!doc.exists) {
          print('⚠️ Data user tidak ada, membuat data baru...');
          // Jika data tidak ada, buat dengan role default customer
          await _saveUserToFirestore(
            userCredential.user!,
            role: UserRole.customer,
          );
          _currentUserRole = UserRole.customer;
        } else {
          // AMBIL ROLE dari Firestore
          final userData = doc.data()!;
          final roleString = userData['role'] as String? ?? 'customer';
          _currentUserRole = UserRole.fromString(roleString);
          print('✅ User role: ${_currentUserRole?.name}');

          // Update last login
          await _updateLastLogin(uid);
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      // ... error handling yang sama ...
      _isLoading = false;
      if (e.code == 'user-not-found') {
        _errorMessage = 'Email tidak ditemukan';
      } else if (e.code == 'wrong-password') {
        _errorMessage = 'Password salah';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'Format email tidak valid';
      } else {
        _errorMessage = 'Login gagal: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  // TAMBAHKAN method untuk get user role
  Future<UserRole?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final roleString = doc.data()?['role'] as String? ?? 'customer';
        return UserRole.fromString(roleString);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user role: $e');
      return null;
    }
  }

  // Method untuk update user profile
  Future<bool> updateUserProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updateData['displayName'] = displayName;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (additionalData != null) updateData.addAll(additionalData);

      await _firestore.collection('users').doc(uid).update(updateData);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
}