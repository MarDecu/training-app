import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

import 'questions_admin_page.dart';
import 'exam_submissions_admin.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final supabase = Supabase.instance.client;

  final titleController = TextEditingController();

  PlatformFile? file;
  bool loading = false;

  List<Map<String, dynamic>> courses = [];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    final data =
        await supabase.from('courses').select('id, title, file_url');

    setState(() {
      courses = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null) {
      setState(() => file = result.files.first);
    }
  }

  Future<void> uploadCourse() async {
    if (file == null || titleController.text.trim().isEmpty) return;

    setState(() => loading = true);

    final fileName =
        "courses/course_${DateTime.now().millisecondsSinceEpoch}.pdf";

    await supabase.storage
        .from('courses')
        .uploadBinary(fileName, file!.bytes!);

    final url = supabase.storage.from('courses').getPublicUrl(fileName);

    await supabase.from('courses').insert({
      'title': titleController.text.trim(),
      'file_url': url,
    });

    titleController.clear();
    file = null;

    await fetchCourses();

    setState(() => loading = false);
  }

  Future<void> deleteCourse(int id) async {
    await supabase.from('courses').delete().eq('id', id);
    await fetchCourses();
  }

  // 🚪 CLEAN LOGOUT (FIXED)
  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),

      appBar: AppBar(
        title: const Text(
          "Admin Panel",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,

        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _confirmLogout,
          ),
        ],
      ),

      body: _getBody(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Courses",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: "Questions",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Exams",
          ),
        ],
      ),
    );
  }

  Widget _getBody() {
    if (selectedIndex == 1) return const QuestionsAdminPage();
    if (selectedIndex == 2) return const ExamSubmissionsAdmin();

    return _coursesPage();
  }

  Widget _coursesPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "Courses (${courses.length})",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 245, 242, 242),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text(
                    "Add New Course",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Course Title",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: pickFile,
                          child: const Text("Pick PDF"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: loading ? null : uploadCourse,
                          child: Text(
                            loading ? "Uploading..." : "Upload",
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (file != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(file!.name),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            courses.isEmpty
                ? const Text("No Courses Yet")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf,
                                color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(course['title'] ?? ''),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () =>
                                  deleteCourse(course['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}