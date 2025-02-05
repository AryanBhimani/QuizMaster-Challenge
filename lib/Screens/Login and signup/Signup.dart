import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quizmaster_challenge/Screens/Home/Home.dart';
import 'package:quizmaster_challenge/Screens/Login%20and%20signup/Login.dart';
import 'package:quizmaster_challenge/Services/Button.dart';
import 'package:quizmaster_challenge/Services/Colors.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController(); // Username controller
  final formKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool isVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;
  String? errorMessage;

  Future addUserDetails(String email, String password, String username) async {
    await FirebaseFirestore.instance.collection('users').add({
      'email': email,
      'password': password,
      'username': username, // Store username in Firestore
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    super.dispose();
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
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ListTile(
                    title: Text(
                      "Register New Account",
                      style: TextStyle(color: green, fontSize: 60, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Username Field
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: green.withOpacity(.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: black, width: 1.5),
                    ),
                    child: TextFormField(
                      controller: usernameController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Username is required";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.account_circle),
                        border: InputBorder.none,
                        hintText: "User Name",
                        iconColor: black,
                      ),
                    ),
                  ),
                  // Email Field
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: green.withOpacity(.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: black, width: 1.5),
                    ),
                    child: TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Email is required";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.email),
                        border: InputBorder.none,
                        hintText: "Email",
                        iconColor: black,
                      ),
                    ),
                  ),
                  // Password Field
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: green.withOpacity(.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: black, width: 1.5),
                    ),
                    child: TextFormField(
                      controller: passwordController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password is required";
                        }
                        return null;
                      },
                      obscureText: !isVisible,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.lock),
                        border: InputBorder.none,
                        hintText: "Password",
                        iconColor: black,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
                        ),
                      ),
                    ),
                  ),
                  // Confirm Password Field
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: green.withOpacity(.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: black, width: 1.5),
                    ),
                    child: TextFormField(
                      controller: confirmPasswordController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Confirm password is required";
                        } else if (passwordController.text != confirmPasswordController.text) {
                          return "Passwords don't match";
                        }
                        return null;
                      },
                      obscureText: !isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.lock),
                        border: InputBorder.none,
                        hintText: "Confirm Password",
                        iconColor: black,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isConfirmPasswordVisible = !isConfirmPasswordVisible;
                            });
                          },
                          icon: Icon(isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // SignUp Button
                  Button(label: "SIGN UP", onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        // ignore: unused_local_variable
                        final credential = await _auth.createUserWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                        await addUserDetails(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                          usernameController.text.trim(), // Pass username
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Signup successful')),
                        );
                        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const Login()));
                        } on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Signup failed: ${e.message}'),
                            ),
                          );
                        }
                      }
                    }
                  ),
                  const SizedBox(height: 15),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context,MaterialPageRoute(builder: (context) => const Login()));
                        },
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(
                            color: green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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