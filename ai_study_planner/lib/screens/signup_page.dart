import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'components/mybuttons.dart';
import 'components/textfields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  //user signup
void userSignup() async {
  final first = firstnamecontroller.text.trim();
  final last  = lastnamecontroller.text.trim();
  final email = emailController.text.trim();
  final pass  = passwordController.text;
try {
  final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: pass,
  );
  final uid = cred.user!.uid;

  await FirebaseFirestore.instance.collection('users').doc(uid).set({
    'firstName': first,
    'lastName': last,
    'email': email.toLowerCase(),
    'createdAt': FieldValue.serverTimestamp(),
  });

  if (mounted) Navigator.pop(context);
} on FirebaseAuthException catch (e) {
  debugPrint('Auth error: ${e.code} ${e.message}');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.message ?? 'Sign up failed')),
  );
} on FirebaseException catch (e) {
  debugPrint('Firestore error: ${e.code} ${e.message}');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Database error: ${e.message}')),
  );
} catch (e) {
  debugPrint('Other error: $e');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Something went wrong: $e')),
  );
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
            colors: [Color(0xFFFF6D6B), Color(0xFFF89247), Color(0xFFF6EAD8)],
            stops: [0.0, 0.41, 0.82],
          ),
        ),

        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //first time
                  Text(
                    'First time?',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 20),
                  //first name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 31),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Enter your first name',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 7),
                  MyTextFields(
                    controller: firstnamecontroller,
                    hintText: "",
                    obscureText: false,
                    alignment: TextAlign.left,
                  ),
                  SizedBox(height: 15),

                  //last name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 31),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Enter your last name',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 7),
                  MyTextFields(
                    controller: lastnamecontroller,
                    hintText: "",
                    obscureText: false,
                    alignment: TextAlign.left,
                  ),
                  SizedBox(height: 15),

                  //email
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 31),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Enter your email',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 7),
                  MyTextFields(
                    controller: emailController,
                    hintText: "",
                    obscureText: false,
                    alignment: TextAlign.left,
                  ),
                  SizedBox(height: 15),

                  //password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 31),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Enter your password',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 7),
                  MyTextFields(
                    controller: passwordController,
                    hintText: "",
                    obscureText: true,
                    alignment: TextAlign.left,
                  ),
                  SizedBox(height: 15),

                  //sign up button
                  MyButtons(
                    color: Color(0xFFC33977),
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