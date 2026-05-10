import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResultPage extends StatefulWidget {
  final int submissionId;

  const ResultPage({
    super.key,
    required this.submissionId,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final supabase = Supabase.instance.client;

  int score = 0;
  int total = 0;
  bool loading = true;

  final Color primary = const Color(0xFF2F6FED);

  @override
  void initState() {
    super.initState();
    fetchResult();
  }

  Future<void> fetchResult() async {
    try {
      final data = await supabase
          .from('exam_submissions')
          .select('score, total')
          .eq('id', widget.submissionId)
          .single();

      setState(() {
        score = data['score'] ?? 0;
        total = data['total'] ?? 0;
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : (score / total) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: const Text(
          "Result",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      const Text(
                        "Exam Result",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Score
                      Text(
                        "$score / $total",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "${percent.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Divider
                      Container(
                        height: 1,
                        color: Colors.grey.shade200,
                      ),

                      const SizedBox(height: 25),

                      // Small status indicator only (no text phrases)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            percent >= 50
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: percent >= 50
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            percent >= 50 ? "PASS" : "FAIL",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: percent >= 50
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () {
            Navigator.popUntil(
              context,
              (route) => route.isFirst,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            "Back",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}