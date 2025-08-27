import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/widgets/mybuttons.dart';
import '../components/widgets/textfields.dart';
import '../auth/verification.dart'; // import verification page
import '../theme/app_colors.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final firstnamecontroller = TextEditingController();
  final lastnamecontroller = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void userSignup() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'firstName': firstnamecontroller.text.trim(),
            'lastName': lastnamecontroller.text.trim(),
            'email': emailController.text.trim(),
          });

      // send email verification
      await userCredential.user!.sendEmailVerification();

      if (!mounted) return;

      // go to verification screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EmailVerificationScreen(user: userCredential.user!),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
              // decorative circles (same as before)
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

              // signup form
              Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'First time?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 31),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Enter your first name',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      MyTextFields(
                        controller: firstnamecontroller,
                        hintText: "",
                        obscureText: false,
                        alignment: TextAlign.left,
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 31),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Enter your last name',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      MyTextFields(
                        controller: lastnamecontroller,
                        hintText: "",
                        obscureText: false,
                        alignment: TextAlign.left,
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 31),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Enter your email',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      MyTextFields(
                        controller: emailController,
                        hintText: "",
                        obscureText: false,
                        alignment: TextAlign.left,
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 31),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Enter your password',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      MyTextFields(
                        controller: passwordController,
                        hintText: "",
                        obscureText: true,
                        alignment: TextAlign.left,
                      ),
                      const SizedBox(height: 15),
                      MyButtons(
                        color: Colors.pink,
                        label: 'Sign Up',
                        onTap: userSignup,
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
