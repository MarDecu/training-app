import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final supabase = Supabase.instance.client;

  static Future<void> logout(BuildContext context) async {
    try {
      await supabase.auth.signOut();

      // ❌ لا نعمل navigation هنا
      // لأن main.dart هو اللي بيراقب session

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout error: $e")),
      );
    }
  }
}