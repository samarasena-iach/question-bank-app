import 'package:flutter/material.dart';
import '../db/question_database.dart';
import '../models/question.dart';
import '../widgets/content_renderer.dart';
import 'add_question_screen.dart';
import 'question_detail_screen.dart';

class QuestionListScreen extends StatefulWidget {
  @override
  _QuestionListScreenState createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  late Future<List<Question>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    _questionsFuture = QuestionDatabase.instance.readAllQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Question Bank')),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text('No questions added.'));

          final questions = snapshot.data!;
          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(q.category),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Question:'),
                      ContentRenderer(contentBlocks: q.questionContent),
                      SizedBox(height: 8),
                      Text('Answer:'),
                      ContentRenderer(contentBlocks: q.answerContent),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuestionDetailScreen(question: q),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddQuestionScreen()),
          );
          setState(_loadQuestions);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
