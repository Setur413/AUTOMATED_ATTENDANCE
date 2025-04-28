import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LecturerProfileScreen extends StatefulWidget {
  const LecturerProfileScreen({super.key});

  @override
  State<LecturerProfileScreen> createState() => _LecturerProfileScreenState();
}

class _LecturerProfileScreenState extends State<LecturerProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? lecturerData;

  @override
  void initState() {
    super.initState();
    _fetchLecturerData();
  }

  Future<void> _fetchLecturerData() async {
    try {
      String userId = _auth.currentUser!.uid;
      DocumentSnapshot doc =
          await _firestore.collection('lecturers').doc(userId).get();

      if (doc.exists) {
        setState(() {
          lecturerData = doc.data() as Map<String, dynamic>;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lecturer profile not found.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching profile: $e")),
      );
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/role', (route) => false);
  }

  void _openTermsAndConditions() {
    // TODO: Navigate or show your T&Cs here.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Terms and Conditions tapped.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Lecturer Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: lecturerData == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage("assets/profile_placeholder.png"),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          lecturerData!['email'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildProfileOption(Icons.email, "Email", lecturerData!['email'] ?? "N/A"),
                _buildProfileOption(Icons.description, "Terms and Conditions", "", onTap: _openTermsAndConditions),
                _buildProfileOption(Icons.logout, "Log Out", "", onTap: _logout),
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
