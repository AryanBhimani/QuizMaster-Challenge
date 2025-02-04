import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html_unescape/html_unescape.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  
  final HtmlUnescape _htmlUnescape = HtmlUnescape();
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // ignore: unused_field
  final String _adAppId = 'ca-app-pub-3940256099942544~3347511713';
  final String _bannerAdId = 'ca-app-pub-3940256099942544/6300978111';
  final String _interstitialAdId = 'ca-app-pub-3940256099942544/1033173712';
  final String _rewardedAdId = 'ca-app-pub-3940256099942544/5224354917';

  @override
  void initState() {
    super.initState();
    _initializeAds();
    _loadQuestions();
  }

  void _initializeAds() {
    // Banner Ad
    _bannerAd = BannerAd(
      adUnitId: _bannerAdId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();

    // Interstitial Ad
    InterstitialAd.load(
      adUnitId: _interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => print('Interstitial failed: $error'),
      ),
    );

    // Rewarded Ad
    RewardedAd.load(
      adUnitId: _rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => print('Rewarded failed: $error'),
      ),
    );
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
                  options: List<String>.from(q['incorrect_answers'])
                    ..add(q['correct_answer'])
                    ..map((e) => _htmlUnescape.convert(e))
                    ..shuffle(),
                ))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading questions: $e');
    }
  }

  void _showRewardedAd() {
    _rewardedAd?.show(onUserEarnedReward: (_, reward) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('+1 Hint Granted!')),
      );
    });
  }

  void _handleAnswer(bool isCorrect) {
    setState(() {
      if (isCorrect) _score += 10;
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _showInterstitialAd();
        _endQuiz();
      }
    });
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null && _currentQuestionIndex % 3 == 0) {
      _interstitialAd?.show();
    }
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
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 88, 226, 60),

        title: const Text('QuizMaster Challenge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showRewardedAd,
            tooltip: 'QuizMaster Challenge',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (_bannerAd != null)
                  SizedBox(
                    height: _bannerAd!.size.height.toDouble(),
                    width: _bannerAd!.size.width.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Score: $_score',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              _questions[_currentQuestionIndex].question,
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            ..._questions[_currentQuestionIndex]

                            .options.map((option) => AnswerButton(
                              text: option,
                              onPressed: () => _handleAnswer(option == _questions[_currentQuestionIndex].correctAnswer),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 40),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        side: const BorderSide(color: Colors.blue),
      ),
      child: Text(text),
    );
  }
}