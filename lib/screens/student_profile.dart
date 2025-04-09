import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StudentProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const StudentProfileScreen({super.key, required this.userData});

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _profileImageUrl = widget.userData['profileImage'];
  }

  // Pick and upload image to Firebase Storage
  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    String userId = _auth.currentUser!.uid;

    try {
      // Create a reference to Firebase Storage
      Reference ref = _storage.ref().child('profile_images/$userId.jpg');
      
      // Upload image to Firebase Storage
      await ref.putFile(imageFile);
      
      // Get the download URL for the image
      String imageUrl = await ref.getDownloadURL();
      
      // Update the Firestore with the profile image URL
      await _firestore.collection('students').doc(userId).update({'profileImage': imageUrl});

      // Update the UI with the new image URL
      setState(() {
        _profileImageUrl = imageUrl;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile image updated")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error uploading image: $e")));
    }
  }

  // Log out
  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/role', (route) => false);
  }

  // Delete Account
  Future<void> _deleteAccount(BuildContext context) async {
    try {
      String userId = _auth.currentUser!.uid;
      
      // Delete profile image from Firebase Storage
      await _storage.ref().child('profile_images/$userId.jpg').delete();
      
      // Delete user data from Firestore
      await _firestore.collection('students').doc(userId).delete();
      
      // Delete the user from Firebase Authentication
      await _auth.currentUser?.delete();
      
      Navigator.pushNamedAndRemoveUntil(context, '/role', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting account: $e")));
    }
  }

  // Confirm delete account action
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : const AssetImage("assets/profile_placeholder.png") as ImageProvider,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.red,
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.userData['name'] ?? "Student",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.userData['email'] ?? "Email not available",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProfileOption(Icons.person, "Name", widget.userData['name'] ?? "N/A"),
          _buildProfileOption(Icons.email, "Email", widget.userData['email'] ?? "N/A"),
          _buildProfileOption(Icons.description, "Terms and Conditions", "", onTap: () {}),
          _buildProfileOption(Icons.delete, "Delete Account", "", onTap: () => _showDeleteConfirmation(context)),
          _buildProfileOption(Icons.logout, "Log Out", "", onTap: () => _logout(context)),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: ListTile(
          leading: Icon(icon, color: Colors.red),
          title: Text(title),
          subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
