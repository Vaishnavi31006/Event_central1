import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registration_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    // Show welcome popup AFTER first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      final name = user?.email ?? 'User';

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Welcome'),
          content: Text('Welcome, $name 👋'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  void openPage(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrationPage(title: title),
      ),
    );
  }

  Widget sectionButton(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: () => openPage(context, title),
        child: Container(
          height: 90,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            sectionButton(context, 'GDGC'),
            sectionButton(context, 'IEEE'),
            sectionButton(context, 'TINKERHUB'),
            sectionButton(context, 'IEDC'),
            sectionButton(context, 'NSDC'),
          ],
        ),
      ),
    );
  }
}
