import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  final String schoolId;

  const HomeScreen({super.key, required this.schoolId});

  Future<String> getSchoolName() async {
    final doc = await FirebaseFirestore.instance.collection('schools').doc(schoolId).get();
    if (doc.exists) {
      return doc['name'];
    } else {
      return "Unknown School";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getSchoolName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Error loading school name")),
          );
        }

        final schoolName = snapshot.data ?? "School";

        return Scaffold(
          appBar: AppBar(
            title: Text(
              schoolName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.blueAccent,
          ),
          backgroundColor: Colors.blue[50],
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('schools')
                .doc(schoolId)
                .collection('students')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No students found",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                );
              }

              final students = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index].data() as Map<String, dynamic>;
                  final name = student['name'] ?? 'Unknown';
                  final roll = student['roll_no']?.toString() ?? '-';
                  final sClass = student['class'] ?? 'N/A';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      subtitle: Text("Class: $sClass\nRoll No: $roll"),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
