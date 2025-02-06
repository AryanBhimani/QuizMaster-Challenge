import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html_unescape/html_unescape.dart';
import 'package:quizmaster_challenge/Screens/Login%20and%20signup/Login.dart';
import 'package:quizmaster_challenge/Services/Colors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HtmlUnescape _htmlUnescape = HtmlUnescape();
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  BannerAd? _bannerAd;

  final String _bannerAdId = 'ca-app-pub-4362785321861304/8408744148'; // Test ID

  @override
  void initState() {
    super.initState();
    _initializeAds();
    _loadQuestions();
  }

  void _initializeAds() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad load failed: $error');
        },
      ),
    )..load();
  }

  Future<void> _loadQuestions() async {
    try {
      final response = await http.get(Uri.parse(
          'https://opentdb.com/api.php?amount=10&category=9&difficulty=medium&type=multiple'));
      final data = json.decode(response.body);

      setState(() {
        _questions = (data['results'] as List)
            .map((q) => Question(
                  question: _htmlUnescape.convert(q['question']),
                  correctAnswer: _htmlUnescape.convert(q['correct_answer']),
                  options: (List<String>.from(q['incorrect_answers'])
                        ..add(q['correct_answer']))
                      .map((e) => _htmlUnescape.convert(e))
                      .toList()
                    ..shuffle(),
                ))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading questions: $e');
    }
  }

  void _handleAnswer(bool isCorrect) {
    setState(() {
      if (isCorrect) _score += 10;
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _endQuiz();
      }
    });
  }

  void _endQuiz() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Text('Final Score: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _loadQuestions();
              });
            },
            child: const Text('Restart'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: green,
        foregroundColor: white,
        title: const Text('QuizMaster Challenge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: (_currentQuestionIndex + 1) / _questions.length,
                      color: green,
                      backgroundColor: white,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Score: $_score',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _questions[_currentQuestionIndex].question,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ..._questions[_currentQuestionIndex]
                                .options
                                .map(
                                  (option) => AnswerButton(
                                    text: option,
                                    onPressed: () => _handleAnswer(
                                        option == _questions[_currentQuestionIndex].correctAnswer),
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                    if (_bannerAd != null)
                      Center(
                        child: SizedBox(
                          height: _bannerAd!.size.height.toDouble(),
                          width: _bannerAd!.size.width.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class Question {
  final String question;
  final String correctAnswer;
  final List<String> options;

  Question({
    required this.question,
    required this.correctAnswer,
    required this.options,
  });
}

class AnswerButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const AnswerButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: white,
          foregroundColor: green,
          side: const BorderSide(color: green),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
