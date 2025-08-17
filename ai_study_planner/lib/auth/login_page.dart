import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/widgets/mybuttons.dart';
import '../components/widgets/textfields.dart';
import 'signup_page.dart';
import '../screens/dashboard_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //user login
  void userLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Navigate to dashboard on successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      // Customize message based on Firebase error code
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Try again.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = 'Incorrect email or password.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  //userSignup
  void userSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupPage()),
    );
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                Image.asset(
                  'lib/components/images/book__icon.png',
                  height: 100,
                  width: 100,
                ),

                //welcome
                Text(
                  "Welcome!",
                  style: TextStyle(
                    color: Color(0xFFF6EAD8),
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                //email
                MyTextFields(
                  controller: emailController,
                  hintText: 'Enter email',
                  obscureText: false,
                  alignment: TextAlign.center,
                ),

                const SizedBox(height: 10),

                //password
                MyTextFields(
                  controller: passwordController,
                  hintText: 'Enter password',
                  obscureText: true,
                  alignment: TextAlign.center,
                ),

                const SizedBox(height: 10),

                //forgot password
                Text(
                  'Forgot Password?',
                  style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 15),
                ),

                const SizedBox(height: 15),

                //login
                MyButtons(
                  color: Color(0xFFFF5A58),
                  label: 'Log in',
                  onTap: userLogin,
                ),

                const SizedBox(height: 5),
                Text(
                  'or',
                  style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 20),
                ),
                const SizedBox(height: 5),

                //signup
                MyButtons(
                  color: Color(0xFFC33977),
                  label: 'Sign up',
                  onTap: userSignup,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

