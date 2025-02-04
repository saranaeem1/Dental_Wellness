import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersPage extends StatefulWidget {
  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isDoctor', isEqualTo: false)
          .where('id', isNotEqualTo: "0")
          .get();

      setState(() {
        users = snapshot.docs.map((doc) {
          final data = doc.data();
          data['docId'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching users: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _editUser(String docId, String newName) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(docId).update({
        'userName': newName,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User updated successfully")),
      );
      _fetchUsers();
    } catch (error) {
      print("Error editing user: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update user")),
      );
    }
  }

  Future<void> _deleteUser(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User deleted successfully")),
      );
      _fetchUsers();
    } catch (error) {
      print("Error deleting user: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete user")),
      );
    }
  }

  void _showEditDialog(String docId, String currentName) {
    final TextEditingController nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Edit User",
          style: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(fontFamily: "GoogleSans"),
          decoration: const InputDecoration(
            labelText: "User Name",
            labelStyle: TextStyle(color: Colors.blue, fontFamily: "GoogleSans"),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(fontFamily: "GoogleSans", color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editUser(docId, nameController.text);
            },
            child: const Text(
              "Save",
              style: TextStyle(fontFamily: "GoogleSans", color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Delete User",
          style: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to delete this user?",
          style: TextStyle(fontFamily: "GoogleSans"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(fontFamily: "GoogleSans", color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(docId);
            },
            child: const Text(
              "Delete",
              style: TextStyle(fontFamily: "GoogleSans", color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,size: 18,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Manage Users",
          style: TextStyle(fontFamily: "GoogleSans", fontSize: 16, color: Colors.white),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/Images/patients.png',  // Replace with the actual image path
                width: 500,
                height: 250,
              ),
              const SizedBox(height: 16),
              const Text(
                "All Users",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: "GoogleSans",
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "You can see all users here",
                style: TextStyle(fontSize: 16, fontFamily: "GoogleSans"),
              ),
              const SizedBox(height: 16),

              // Table (List of Users)
              users.isEmpty
                  ? const Center(
                child: Text(
                  "No users found",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: "GoogleSans"),
                ),
              )
                  : Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(Icons.person,
                              color: Colors.blue, size: 30),
                        ),
                        title: Text(
                          user['userName'] ?? "No Name",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: "GoogleSans",
                          ),
                        ),
                        subtitle: Text(
                          user['email'] ?? "No Email",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey, fontFamily: "GoogleSans"),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showEditDialog(user['docId'], user['userName'] ?? "");
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteDialog(user['docId']);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
