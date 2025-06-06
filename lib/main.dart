import 'package:flutter/material.dart';
import 'screens/question_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Question Bank App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: QuestionListScreen(),
    );
  }
}
