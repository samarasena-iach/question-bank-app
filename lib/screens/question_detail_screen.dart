import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question.dart';
import '../widgets/content_renderer.dart';
import 'edit_question_screen.dart';
import '../db/question_database.dart';

class QuestionDetailScreen extends StatelessWidget {
  final Question question;

  const QuestionDetailScreen({Key? key, required this.question})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      backgroundColor: Color(0xFFF8F8FC),
      appBar: AppBar(
        title: Text(
          question.category,
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 4,
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: Icon(Icons.edit_note_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditQuestionScreen(question: question),
                ),
              );
              Navigator.pop(context, true);
            },
          ),
          IconButton(
            tooltip: 'Delete',
            icon: Icon(Icons.delete_outline, color: Colors.red[300]),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Question?'),
                  content: Text(
                    'Are you sure you want to permanently delete this question?',
                  ),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    TextButton(
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await QuestionDatabase.instance.delete(question.id!);
                Navigator.pop(context, {'deleted': true});
              }
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌟 Question Section
            Text(
              'Question',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ContentRenderer(
                  contentBlocks: question.questionContent,
                  zoomable: true,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ✅ Answer Section
            Text(
              'Answer',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.teal[700],
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ContentRenderer(
                  contentBlocks: question.answerContent,
                  zoomable: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
