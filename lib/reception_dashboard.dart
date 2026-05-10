import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'courses_page.dart';
import 'exam_home.dart';

class ReceptionDashboard extends StatefulWidget {
  const ReceptionDashboard({super.key});

  @override
  State<ReceptionDashboard> createState() => _ReceptionDashboardState();
}

class _ReceptionDashboardState extends State<ReceptionDashboard> {
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }

  // 🎨 Colors Theme
  final Color primary = const Color(0xFF2F6FED);
  final Color background = const Color(0xFFF3F6FB);
  final Color card = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout, color: Colors.white),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary,
                    const Color(0xFF5B8CFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Back 👋",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Manage courses & exams easily",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _buildTile(
              icon: Icons.menu_book_rounded,
              title: "Courses",
              subtitle: "View & manage all courses",
              color: primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const CoursesPage(role: 'reception'),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            _buildTile(
              icon: Icons.quiz_rounded,
              title: "Exams",
              subtitle: "Check exams & submissions",
              color: const Color(0xFF7C4DFF),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExamHome(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}