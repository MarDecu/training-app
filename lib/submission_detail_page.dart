import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubmissionDetailPage extends StatefulWidget {
  final int submissionId;
  final String userId;

  const SubmissionDetailPage({
    super.key,
    required this.submissionId,
    required this.userId,
  });

  @override
  State<SubmissionDetailPage> createState() =>
      _SubmissionDetailPageState();
}

class _SubmissionDetailPageState
    extends State<SubmissionDetailPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> responses = [];
  bool loading = true;

  int score = 0;
  int total = 0;

  @override
  void initState() {
    super.initState();
    fetchResponses();
  }

  Future<void> fetchResponses() async {
    try {
      final data = await supabase
          .from('responses')
          .select('''
            id,
            answer,
            questions(question)
          ''')
          .eq('submission_id', widget.submissionId)
          .order('id');

      final list = List<Map<String, dynamic>>.from(data);

      setState(() {
        responses = list;
        total = list.length;
        loading = false;
      });
    } catch (e) {
      debugPrint("Detail error: $e");
      setState(() => loading = false);
    }
  }

  void toggleCorrect(int index) {
    setState(() {
      final current = responses[index]['is_correct'] ?? false;
      responses[index]['is_correct'] = !current;

      score = responses
          .where((r) => r['is_correct'] == true)
          .length;
    });
  }

  Future<void> saveResult() async {
    try {
      // 1️⃣ update submission
      await supabase.from('exam_submissions').update({
        'score': score,
        'total': total,
        'status': 'reviewed',
      }).eq('id', widget.submissionId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Result saved successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Correction"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveResult,
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "Score: $score / $total",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: responses.length,
                    itemBuilder: (context, index) {
                      final r = responses[index];

                      final isCorrect =
                          r['is_correct'] ?? false;

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(
                            r['questions']?['question'] ??
                                'Question',
                          ),
                          subtitle: Text(
                            "Answer: ${r['answer']}",
                          ),

                          trailing: IconButton(
                            icon: Icon(
                              isCorrect
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: isCorrect
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            onPressed: () =>
                                toggleCorrect(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}