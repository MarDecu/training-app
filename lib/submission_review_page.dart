import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubmissionReviewPage extends StatefulWidget {
  final int submissionId;
  final String userId;

  const SubmissionReviewPage({
    super.key,
    required this.submissionId,
    required this.userId,
  });

  @override
  State<SubmissionReviewPage> createState() =>
      _SubmissionReviewPageState();
}

class _SubmissionReviewPageState
    extends State<SubmissionReviewPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> responses = [];
  bool loading = true;

  int score = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final data = await supabase
          .from('responses')
          .select('''
            id,
            answer,
            is_correct,
            questions (
              question
            )
          ''')
          .eq('submission_id', widget.submissionId);

      setState(() {
        responses = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
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
      await supabase
          .from('exam_submissions')
          .update({
            'score': score,
            'status': 'reviewed',
          })
          .eq('id', widget.submissionId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Result saved")),
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
        title: const Text("Exam Review"),
        actions: [
          IconButton(
            onPressed: saveResult,
            icon: const Icon(Icons.save),
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "Score: $score / ${responses.length}",
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
                                  : Icons.radio_button_unchecked,
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