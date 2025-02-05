import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quizmaster_challenge/Screens/Login%20and%20signup/ForgotPassword.dart';
import 'package:quizmaster_challenge/Screens/Home/Home.dart';
import 'package:quizmaster_challenge/Screens/Login%20and%20signup/Signup.dart';
import 'package:quizmaster_challenge/Services/Button.dart';
import 'package:quizmaster_challenge/Services/Colors.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isVisible = false;
  bool isLoading = false;
  String? errorMessage;

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userSnapshot = await userDoc.get();

        if (!userSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Image.asset("assets/domain.png", height: 240),
                  const Text(
                    "Login",
                    style: TextStyle(color: green, fontSize: 40 ,fontWeight: FontWeight.bold),
                  ),
                  // Image.asset("assets/foodie.png"),
                  // Image.asset("assets/foodie.png", height: 240),
                  const SizedBox(height: 15),
                  _buildTextFormField(
                    controller: emailController,
                    hintText: "Email",
                    icon: Icons.email,
                    validator: (value) {
                      if (value!.isEmpty) return "Email is required";
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) return "Enter a valid email";
                      return null;
                    },
                  ),
                  _buildPasswordField(passwordController, "Password"),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,MaterialPageRoute(builder: (context) => const ForgotPassword()));
                          },
                          child: const Text(
                            'Forget password',
                            style: TextStyle(
                              color: Color(0xff000004),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Email Login Button
                  Button(label: "LOGIN", onPressed: () {
                    FocusScope.of(context).unfocus();
                    if (formKey.currentState!.validate()) {
                      login();
                    }
                  }),
                  const SizedBox(height: 15),
                  // Google Sign-In Button
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * .9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: white,
                      border: Border.all(color:grey),
                    ),
                    child: TextButton.icon(
                      onPressed: isLoading ? null : signInWithGoogle,
                      icon: Image.asset(
                        "assets/google.png",
                        height: 24,
                      ),
                      label: const Text(
                        "Sign in with Google",
                        style: TextStyle(color: black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context,MaterialPageRoute(builder: (context) => const Signup()));
                        },
                        child: const Text(
                          'SIGN UP',
                          style: TextStyle(
                            color: green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: green.withOpacity(.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: black, width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          icon: Icon(icon),
          iconColor: black,
          border: InputBorder.none,
          hintText: hintText,
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String hintText,
  ) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: green.withOpacity(.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: black, width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$hintText is required";
          }
          return null; 
        },
        decoration: InputDecoration(
          icon: const Icon(Icons.lock),
          border: InputBorder.none,
          hintText: hintText,
          iconColor: black,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                isVisible = !isVisible;
              });
            },
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
            ),
          ),
        ),
      ),
    );
  }
}  