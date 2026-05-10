import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({super.key});

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> questions = [];
  Map<int, dynamic> answers = {};

  bool loading = true;
  bool submitted = false;

  int seconds = 30 * 60;
  Timer? timer;

  final Color primary = const Color(0xFF2F6FED);

  @override
  void initState() {
    super.initState();
    fetchQuestions();
    startTimer();
  }

  Future<void> fetchQuestions() async {
    try {
      final data = await supabase.from('questions').select().order('id');

      setState(() {
        questions = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds <= 0) {
        submitExam();
        t.cancel();
      } else {
        setState(() => seconds--);
      }
    });
  }

  String formatTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return "$m:$sec";
  }

  void setAnswer(int id, dynamic value) {
    answers[id] = value;
  }

  Future<void> submitExam() async {
    if (submitted) return;

    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => submitted = true);
    timer?.cancel();

    try {
      final submission = await supabase
          .from('exam_submissions')
          .insert({
            'user_id': user.id,
            'status': 'pending',
            'total': questions.length,
          })
          .select()
          .single();

      final submissionId = submission['id'];

      final List<Map<String, dynamic>> payload = [];

      for (final q in questions) {
        final qId = q['id'];

        payload.add({
          'user_id': user.id,
          'question_id': qId,
          'submission_id': submissionId,
          'answer': answers[qId]?.toString() ?? '',
        });
      }

      await supabase.from('responses').insert(payload);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Exam submitted. Waiting for review..."),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => submitted = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submit Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: Text(
          "Exam • ${formatTime(seconds)}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final q = questions[index];

                      final id = q['id'];
                      final type = q['type'];
                      final question = q['question'] ?? '';
                      final options =
                          (q['options'] ?? []) as List;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              question,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 12),

                            if (type == 'mcq')
                              Column(
                                children: List.generate(
                                  options.length,
                                  (i) => Container(
                                    margin:
                                        const EdgeInsets.only(bottom: 6),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: RadioListTile(
                                      title: Text(
                                        options[i].toString(),
                                      ),
                                      value: options[i],
                                      groupValue: answers[id],
                                      activeColor: primary,
                                      onChanged: (val) {
                                        setState(() {
                                          setAnswer(id, val);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),

                            if (type == 'essay')
                              TextField(
                                maxLines: 3,
                                onChanged: (val) =>
                                    setAnswer(id, val),
                                decoration: InputDecoration(
                                  hintText: "Write your answer...",
                                  filled: true,
                                  fillColor:
                                      Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitted ? null : submitExam,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Submit Exam",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}