import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../auth/signup_page.dart'; // make sure this path is correct
import '../theme/app_colors.dart';

class EmailVerificationScreen extends StatefulWidget {
  final User user;
  const EmailVerificationScreen({super.key, required this.user});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool canResendEmail = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // Auto-check email verification every 3 seconds
    timer = Timer.periodic(const Duration(seconds: 3), (t) async {
      await widget.user.reload();
      User? updatedUser = FirebaseAuth.instance.currentUser;
      if (updatedUser != null && updatedUser.emailVerified) {
        t.cancel();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> resendVerificationEmail() async {
    try {
      await widget.user.sendEmailVerification();
      if (!mounted) return;
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 30));
      if (!mounted) return;
      setState(() => canResendEmail = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending email: $e')));
    }
  }

  void goBackToSignup() async {
    await FirebaseAuth.instance.signOut(); // optional: log out current user
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pinkAccent,
              Colors.deepOrangeAccent,
              AppColors.background,
            ],
            stops: [0.0, 0.41, 0.82],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative Circles (same as login/signup)
              Positioned(
                top: -50,
                left: -50,
                child: _buildCircle(
                  120,
                  Colors.pinkAccent.withValues(alpha: 0.3),
                ),
              ),
              Positioned(
                bottom: -60,
                right: -40,
                child: _buildCircle(
                  150,
                  Colors.deepOrangeAccent.withValues(alpha: 0.3),
                ),
              ),
              Positioned(
                top: 200,
                right: -70,
                child: _buildCircle(100, Colors.white.withValues(alpha: 0.15)),
              ),
              Positioned(
                bottom: 120,
                left: -50,
                child: _buildCircle(80, Colors.pink.withValues(alpha: 0.2)),
              ),
              Positioned(
                top: 100,
                left: 200,
                child: _buildCircle(
                  60,
                  Colors.deepOrangeAccent.withValues(alpha: 0.2),
                ),
              ),
              Positioned(
                bottom: 250,
                right: 150,
                child: _buildCircle(
                  90,
                  Colors.pinkAccent.withValues(alpha: 0.25),
                ),
              ),
              Positioned(
                top: 300,
                left: 50,
                child: _buildCircle(50, Colors.white.withValues(alpha: 0.1)),
              ),
              Positioned(
                bottom: 50,
                left: 100,
                child: _buildCircle(
                  70,
                  Colors.deepOrangeAccent.withValues(alpha: 0.15),
                ),
              ),
              Positioned(
                top: 400,
                right: 50,
                child: _buildCircle(
                  60,
                  Colors.pinkAccent.withValues(alpha: 0.2),
                ),
              ),
              Positioned(
                bottom: 180,
                left: 220,
                child: _buildCircle(50, Colors.white.withValues(alpha: 0.1)),
              ),
              Positioned(
                top: 50,
                right: 150,
                child: _buildCircle(
                  80,
                  Colors.deepOrangeAccent.withValues(alpha: 0.15),
                ),
              ),
              Positioned(
                bottom: 300,
                left: 30,
                child: _buildCircle(
                  100,
                  Colors.pinkAccent.withValues(alpha: 0.25),
                ),
              ),

              // Main Content
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'A verification link has been sent to your email.\n'
                        'Check your spam folder and click the link to verify your account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          await widget.user.reload();
                          User? updatedUser = FirebaseAuth.instance.currentUser;
                          if (updatedUser != null &&
                              updatedUser.emailVerified) {
                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DashboardScreen(),
                                ),
                              );
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Email not verified yet. Check your inbox.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'I have verified',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        onPressed: canResendEmail
                            ? resendVerificationEmail
                            : null,
                        child: const Text(
                          'Resend email',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        onPressed: goBackToSignup,
                        child: const Text(
                          'Change Email / Go Back',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
