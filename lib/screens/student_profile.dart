import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class StudentProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const StudentProfileScreen({super.key, required this.userData});

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadProfileImage(); // Load saved profile image when app starts
  }

  // Pick Image from Gallery and Save Locally
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _saveProfileImage(pickedFile.path);
    }
  }

  // Save Image Path Locally
  Future<void> _saveProfileImage(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', imagePath);
  }

  // Load Image from Local Storage
  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image');
    if (imagePath != null) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  // Log Out Function
  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/role', (route) => false);
  }

  // Delete Account Function
  Future<void> _deleteAccount(BuildContext context) async {
    try {
      await _auth.currentUser?.delete();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_image'); // Remove stored image on delete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account deleted successfully!")),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/role', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting account: $e")),
      );
    }
  }

  // Show Confirmation Dialog for Deleting Account
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
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
        elevation: 0,
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
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!) as ImageProvider
                          : widget.userData['profileImage'] != null
                              ? NetworkImage(widget.userData['profileImage'])
                              : const AssetImage("assets/profile_placeholder.png"),
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
