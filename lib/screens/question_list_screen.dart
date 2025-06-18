import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../db/question_database.dart';
import '../models/question.dart';
import 'add_question_screen.dart';
import 'question_detail_screen.dart';

class QuestionListScreen extends StatefulWidget {
  @override
  _QuestionListScreenState createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  List<Question> _allQuestions = [];
  List<Question> _filteredQuestions = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final questions = await QuestionDatabase.instance.readAllQuestions();
    setState(() {
      _allQuestions = questions;
      _filteredQuestions = questions;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredQuestions = query.isEmpty
          ? _allQuestions
          : _allQuestions.where((q) {
              final categoryMatch =
                  q.category.toLowerCase().contains(query);
              final questionMatch = q.questionContent.any(
                (b) => b.value.toLowerCase().contains(query),
              );
              final answerMatch = q.answerContent.any(
                (b) => b.value.toLowerCase().contains(query),
              );
              return categoryMatch || questionMatch || answerMatch;
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      backgroundColor: Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text(
          'Bits & Blocks',
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search questions...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),

          Expanded(
            child: _filteredQuestions.isEmpty
                ? Center(
                    child: Text(
                      'No questions found.',
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    itemCount: _filteredQuestions.length,
                    itemBuilder: (context, index) {
                      final question = _filteredQuestions[index];

                      final preview = question.questionContent
                          .where((b) =>
                              b.type == ContentType.text ||
                              b.type == ContentType.code)
                          .map((b) => b.value)
                          .join(' ');

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          title: Text(
                            preview,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            question.category,
                            style: GoogleFonts.openSans(
                              fontSize: 13,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w700
                            ),
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    QuestionDetailScreen(question: question),
                              ),
                            );

                            if (result == true ||
                                (result is Map && result['deleted'] == true)) {
                              _loadQuestions();
                            }
                          },
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddQuestionScreen()),
          );

          if (added == true) {
            _loadQuestions();
          }
        },
        label: Text('Add Question'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.white70,
      ),
    );
  }
}
