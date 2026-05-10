import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuestionsAdminPage extends StatefulWidget {
  const QuestionsAdminPage({super.key});

  @override
  State<QuestionsAdminPage> createState() =>
      _QuestionsAdminPageState();
}

class _QuestionsAdminPageState extends State<QuestionsAdminPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final data = await supabase
        .from('questions')
        .select()
        .order('id', ascending: false);

    setState(() {
      questions = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> deleteQuestion(int id) async {
    await supabase.from('questions').delete().eq('id', id);
    await fetchQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),

      appBar: AppBar(
        title: const Text(
          "Questions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: const Color.fromARGB(255, 236, 241, 240),
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        child: const Icon(Icons.add),
      ),

      body: questions.isEmpty
          ? const Center(child: Text("No Questions Yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];

                return _postCard(q);
              },
            ),
    );
  }

  // 🧠 POST STYLE CARD
  Widget _postCard(Map q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                child: Icon(Icons.quiz),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  q['type'] == "mcq" ? "MCQ Question" : "Essay Question",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteQuestion(q['id']),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // QUESTION
          Text(
            q['question'] ?? '',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          // OPTIONS
          if (q['type'] == "mcq")
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                (q['options'] as List).length,
                (i) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(q['options'][i]),
                ),
              ),
            ),

          const SizedBox(height: 10),

          if (q['correct_answer'] != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Correct Answer: ${q['correct_answer']}",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ➕ BOTTOM SHEET ADD QUESTION
  void _openAddSheet() {
    final questionController = TextEditingController();
    final option1 = TextEditingController();
    final option2 = TextEditingController();
    final option3 = TextEditingController();
    final option4 = TextEditingController();
    final correct = TextEditingController();

    String type = "essay";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        "New Question",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: questionController,
                        decoration: const InputDecoration(
                          hintText: "Enter question",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: type,
                        items: const [
                          DropdownMenuItem(
                            value: "essay",
                            child: Text("Essay"),
                          ),
                          DropdownMenuItem(
                            value: "mcq",
                            child: Text("MCQ"),
                          ),
                        ],
                        onChanged: (v) =>
                            setModalState(() => type = v!),
                      ),

                      const SizedBox(height: 10),

                      if (type == "mcq") ...[
                        _box(option1, "Option 1"),
                        _box(option2, "Option 2"),
                        _box(option3, "Option 3"),
                        _box(option4, "Option 4"),
                        _box(correct, "Correct Answer"),
                      ],

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            List<String> options = [];

                            if (type == "mcq") {
                              options = [
                                option1.text,
                                option2.text,
                                option3.text,
                                option4.text,
                              ];
                            }

                            await supabase.from('questions').insert({
                              'question': questionController.text,
                              'type': type,
                              'options': options,
                              'correct_answer':
                                  type == "mcq" ? correct.text : null,
                            });

                            Navigator.pop(context);
                            fetchQuestions();
                          },
                          child: const Text("Save Question"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _box(TextEditingController c, String h) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: h,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}