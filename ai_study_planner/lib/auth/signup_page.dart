import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/widgets/mybuttons.dart';
import '../components/widgets/textfields.dart';
import '../screens/dashboard_screen.dart';

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

  // User signup
  void userSignup() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Save user info in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'firstName': firstnamecontroller.text.trim(),
            'lastName': lastnamecontroller.text.trim(),
            'email': emailController.text.trim(),
          });

      // Navigate to dashboard after successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF6D6B), Color(0xFFF89247), Color(0xFFF6EAD8)],
            stops: [0.0, 0.41, 0.82],
          ),
        ),
        child: SafeArea(
          child: Center(
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
                  // First name
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
                  // Last name
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
                  // Email
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
                  // Password
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
                  // Sign up button
                  MyButtons(
                    color: const Color(0xFFC33977),
                    label: 'Sign Up',
                    onTap: userSignup,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

