import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizmaster_challenge/Screens/Home/Home.dart';
import 'package:quizmaster_challenge/Screens/Login%20and%20signup/Login.dart';
import 'package:quizmaster_challenge/Screens/Login%20and%20signup/Signup.dart';
import 'package:quizmaster_challenge/Services/Button.dart';
import 'package:quizmaster_challenge/Services/Colors.dart';


class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return  const Home();
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Authentication",
                style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: green),
              ),
              const Text(
                "Authenticate to access your vital information",
                style: TextStyle(color: grey),
              ),
              Expanded(child: Image.asset("assets/domain.png")),
              Button(label: "LOGIN", onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> const Login()));
              }),
              Button(label: "SIGN UP", onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> const Signup()));
              }),
            ],
          ),
        ),
      )),
    );
  }
}