// lib/screens/question_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../models/question.dart';
import '../widgets/content_renderer.dart';

class QuestionDetailScreen extends StatelessWidget {
  final Question question;

  const QuestionDetailScreen({Key? key, required this.question})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Question Detail')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category: ${question.category}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Question:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ContentRenderer(contentBlocks: question.questionContent),
            SizedBox(height: 24),
            Text(
              'Answer:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ContentRenderer(
              contentBlocks: question.answerContent,
              zoomable: true,
            ),
          ],
        ),
      ),
    );
  }
}
