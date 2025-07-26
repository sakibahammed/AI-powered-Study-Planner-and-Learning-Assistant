import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_ai/components/mybuttons.dart';
import 'package:study_ai/components/textfields.dart';

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
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );

    Navigator.pop(context);
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
