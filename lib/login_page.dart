import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final supabase = Supabase.instance.client;

  bool loading = false;

  Future<void> login() async {
    if (loading) return;

    setState(() => loading = true);

    try {
      final res = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = res.user;

      if (user == null) {
        setState(() => loading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Failed")),
        );
        return;
      }

      final profile = await supabase
          .from('users_profile')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      final role = profile?['role'] ?? 'reception';

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Success")),
      );

      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/courses');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 235, 35),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 20),

                // 🧪 HEADER (LOGO + TITLE)
                Stack(
                  children: [
                    // LOGO TOP LEFT
                    Align(
                      alignment: Alignment.topLeft,
                      child: Image.asset(
                        'assets/logo.png',
                        height: 250,
                      ),
                    ),

                    // TITLE CENTER SLIGHTLY DOWN
                    const Padding(
                      padding: EdgeInsets.only(top: 250),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          "Login Training Ansary Labs",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 📧 EMAIL
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔒 PASSWORD
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // 🚀 LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: loading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      loading ? "Logging in..." : "LOGIN",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}