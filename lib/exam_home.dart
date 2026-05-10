import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'questions_page.dart';
import 'result_page.dart';

class ExamHome extends StatelessWidget {
  const ExamHome({super.key});

  final Color primary = const Color(0xFF2F6FED);

  Future<void> openLastResult(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      final data = await supabase
          .from('exam_submissions')
          .select('id, score, total, created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No results yet")),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            submissionId: data['id'],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: const Text(
          "Exam Center",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ready for your exam? 🧠",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Test your knowledge and check your results anytime",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Start Exam Card
            _buildCardButton(
              context: context,
              title: "Start Exam",
              subtitle: "Begin your test now",
              icon: Icons.play_arrow_rounded,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuestionsPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            // Results Card
            _buildCardButton(
              context: context,
              title: "View Results",
              subtitle: "Check your last exam score",
              icon: Icons.bar_chart_rounded,
              color: Colors.orange,
              onTap: () => openLastResult(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              child: Icon(icon, color: color, size: 28),
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

            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }
}