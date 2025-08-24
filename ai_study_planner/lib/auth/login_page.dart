import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/widgets/mybuttons.dart';
import '../components/widgets/textfields.dart';
import '../auth/signup_page.dart';
import '../auth/verification.dart';
import '../screens/dashboard_screen.dart';
import '../theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void userLogin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      User user = userCredential.user!;

      if (!user.emailVerified) {
        // if email not verified, go to verification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(user: user),
          ),
        );
      } else {
        // if verified, go to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
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

  void userSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
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
              // decorative circles
              Positioned(
                top: -50,
                left: -50,
                child: _buildCircle(120, Colors.pinkAccent.withOpacity(0.3)),
              ),
              Positioned(
                bottom: -60,
                right: -40,
                child: _buildCircle(
                  150,
                  Colors.deepOrangeAccent.withOpacity(0.3),
                ),
              ),
              Positioned(
                top: 200,
                right: -70,
                child: _buildCircle(100, Colors.white.withOpacity(0.15)),
              ),
              Positioned(
                bottom: 120,
                left: -50,
                child: _buildCircle(80, Colors.pink.withOpacity(0.2)),
              ),
              Positioned(
                top: 100,
                left: 200,
                child: _buildCircle(
                  60,
                  Colors.deepOrangeAccent.withOpacity(0.2),
                ),
              ),
              Positioned(
                bottom: 250,
                right: 150,
                child: _buildCircle(90, Colors.pinkAccent.withOpacity(0.25)),
              ),
              Positioned(
                top: 300,
                left: 50,
                child: _buildCircle(50, Colors.white.withOpacity(0.1)),
              ),
              Positioned(
                bottom: 50,
                left: 100,
                child: _buildCircle(
                  70,
                  Colors.deepOrangeAccent.withOpacity(0.15),
                ),
              ),
              Positioned(
                top: 400,
                right: 50,
                child: _buildCircle(60, Colors.pinkAccent.withOpacity(0.2)),
              ),
              Positioned(
                bottom: 180,
                left: 220,
                child: _buildCircle(50, Colors.white.withOpacity(0.1)),
              ),
              Positioned(
                top: 50,
                right: 150,
                child: _buildCircle(
                  80,
                  Colors.deepOrangeAccent.withOpacity(0.15),
                ),
              ),
              Positioned(
                bottom: 300,
                left: 30,
                child: _buildCircle(100, Colors.pinkAccent.withOpacity(0.25)),
              ),

              // login form
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/components/images/book__icon.png',
                      height: 80,
                      width: 80,
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      "Study smart, not hard.",
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Welcome!",
                      style: TextStyle(
                        color: Color(0xFFF6EAD8),
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 10),
                    MyTextFields(
                      controller: emailController,
                      hintText: 'Enter email',
                      obscureText: false,
                      alignment: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    MyTextFields(
                      controller: passwordController,
                      hintText: 'Enter password',
                      obscureText: true,
                      alignment: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    const SizedBox(height: 15),
                    MyButtons(
                      color: Colors.pink,
                      label: 'Log in',
                      onTap: userLogin,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'or',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 5),
                    MyButtons(
                      color: Colors.pink,
                      label: 'Sign up',
                      onTap: userSignup,
                    ),
                  ],
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
