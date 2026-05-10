import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'submission_detail_page.dart';

class ExamSubmissionsAdmin extends StatefulWidget {
  const ExamSubmissionsAdmin({super.key});

  @override
  State<ExamSubmissionsAdmin> createState() =>
      _ExamSubmissionsAdminState();
}

class _ExamSubmissionsAdminState
    extends State<ExamSubmissionsAdmin> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> submissions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  Future<void> fetchSubmissions() async {
    final data = await supabase
        .from('exam_submissions')
        .select()
        .order('created_at', ascending: false);

    setState(() {
      submissions = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  int safeInt(dynamic v) =>
      v == null ? 0 : int.tryParse(v.toString()) ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 242, 246),

      appBar: AppBar(
        title: const Text(
          "Exam Submissions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: const Color.fromARGB(255, 223, 115, 115),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchSubmissions,
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? const Center(child: Text("No submissions yet"))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: submissions.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final sub = submissions[index];

                    final score = safeInt(sub['score']);
                    final total = safeInt(sub['total']);
                    final status = sub['status'] ?? 'pending';

                    return _submissionCard(sub, score, total, status);
                  },
                ),
    );
  }

  // 🧠 MODERN CARD
  Widget _submissionCard(
    Map sub,
    int score,
    int total,
    String status,
  ) {
    double progress = total == 0 ? 0 : score / total;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubmissionDetailPage(
              userId: sub['user_id'],
              submissionId: sub['id'],
            ),
          ),
        ).then((_) => fetchSubmissions());
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "User: ${sub['user_id']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                _statusChip(status),
              ],
            ),

            const SizedBox(height: 12),

            // SCORE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Score: $score / $total",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Text(
                  "${(progress * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // PROGRESS BAR
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🟢 STATUS CHIP
  Widget _statusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'reviewed':
        color = Colors.green;
        text = "Reviewed";
        break;
      case 'pending':
      default:
        color = Colors.orange;
        text = "Pending";
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}