import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'questions_page.dart';

class CoursesPage extends StatefulWidget {
  final String role;

  const CoursesPage({super.key, required this.role});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final supabase = Supabase.instance.client;

  List courses = [];
  bool loading = true;

  final Color primary = const Color(0xFF2F6FED);

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    setState(() => loading = true);

    try {
      final data = await supabase
          .from('courses')
          .select()
          .order('id', ascending: false);

      setState(() {
        courses = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> openPdf(String url) async {
    try {
      final uri = Uri.parse(url);

      // ✅ فتح مباشر بدون canLaunchUrl
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cannot open file: $e"),
        ),
      );
    }
  }

  void startExam() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QuestionsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: const Text(
          "Courses",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];

                  final title = course['title'] ?? '';
                  final url = course['file_url'];

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
                        ),
                      ],
                    ),
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

                        const SizedBox(height: 14),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            // ✅ PDF BUTTON FIXED
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () async {
                                if (url != null &&
                                    url.toString().isNotEmpty) {
                                  await openPdf(url.toString());
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.red.withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf,
                                      color: Colors.red,
                                      size: 18,
                                    ),

                                    SizedBox(width: 6),

                                    Text(
                                      "PDF",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ✅ START EXAM BUTTON
                            ElevatedButton(
                              onPressed: startExam,
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                              ),
                              child: const Text(
                                "Start Exam",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}