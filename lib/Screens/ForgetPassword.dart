import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber/Screens/login.dart';

class ForgetP extends StatefulWidget {
  const ForgetP({super.key});

  @override
  State<ForgetP> createState() => _ForgetPState();
}

class _ForgetPState extends State<ForgetP> {
  final TextEditingController emailController = TextEditingController();
  bool isPressed = false;
  bool isLoading = false; // إضافة متغير للتحكم في إظهار المؤشر

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[100], // تغيير لون الخلفية إلى البرتقالي الفاتح
      appBar: AppBar(
        title: const Text('إعادة تعيين كلمة المرور'),
        backgroundColor: Colors.orange, // اللون البرتقالي
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'الرجاء إدخال بريدك الإلكتروني لإعادة تعيين كلمة المرور',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.email, color: Colors.orange), // تغيير لون الأيقونة
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.orange), // تغيير لون الحدود عند التركيز
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true; // تفعيل المؤشر عند بدء التحميل
                });
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
                  setState(() {
                    isPressed = true;
                  });
                  if (isPressed) {
                    _showSuccessDialog(context);
                  }
                } catch (e) {
                  print('Error sending password reset email: $e');
                } finally {
                  setState(() {
                    isLoading = false; // إيقاف المؤشر بعد انتهاء التحميل
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange, // اللون البرتقالي
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('استمرار', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            if (isLoading) // عرض المؤشر فقط في حالة isLoading
              const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              ),
          ],
        ),
      ),
    );
  }

  // دالة لإظهار حوار النجاح
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تم إرسال رسالة إلى بريدك الإلكتروني لتغيير كلمة المرور'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              child: const Text('حسناً'),
            ),
          ],
        );
      },
    );
  }
}
