import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question.dart';
import '../db/question_database.dart';
import 'package:image_picker/image_picker.dart';

class AddQuestionScreen extends StatefulWidget {
  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _categoryController = TextEditingController();
  final _picker = ImagePicker();

  List<ContentBlock> _questionContent = [];
  List<ContentBlock> _answerContent = [];

  void _addContent(List<ContentBlock> target, ContentType type, [String? value]) {
    setState(() {
      target.add(ContentBlock(type: type, value: value ?? ''));
    });
  }

  Future<void> _pickImage(List<ContentBlock> target) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          target.add(ContentBlock(type: ContentType.image, value: pickedFile.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _saveQuestion() async {
    if (_categoryController.text.trim().isEmpty ||
        _questionContent.isEmpty ||
        _answerContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final newQuestion = Question(
      category: _categoryController.text.trim(),
      questionContent: _questionContent,
      answerContent: _answerContent,
      createdAt: DateTime.now(),
    );

    await QuestionDatabase.instance.create(newQuestion);
    Navigator.pop(context, true);
  }

  Widget _buildContentEditor(String label, List<ContentBlock> contentList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        ...contentList.asMap().entries.map((entry) {
          int index = entry.key;
          ContentBlock block = entry.value;

          Widget editor;
          switch (block.type) {
            case ContentType.text:
            case ContentType.code:
              editor = TextFormField(
                initialValue: block.value,
                maxLines: block.type == ContentType.code ? 5 : 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: block.type == ContentType.code ? 'Code Block' : 'Text',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => setState(() => contentList.removeAt(index)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (val) => block.value = val,
              );
              break;

            case ContentType.image:
              editor = Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text('Image: ${block.value.split('/').last}'),
                  subtitle: Image.file(File(block.value)),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => setState(() => contentList.removeAt(index)),
                  ),
                ),
              );
              break;

            default:
              editor = SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: editor,
          );
        }),
        Row(
          children: [
            OutlinedButton.icon(
              icon: Icon(Icons.text_fields),
              label: Text("Text"),
              onPressed: () => _addContent(contentList, ContentType.text),
            ),
            SizedBox(width: 8),
            OutlinedButton.icon(
              icon: Icon(Icons.code),
              label: Text("Code"),
              onPressed: () => _addContent(contentList, ContentType.code),
            ),
            SizedBox(width: 8),
            OutlinedButton.icon(
              icon: Icon(Icons.image),
              label: Text("Image"),
              onPressed: () => _pickImage(contentList),
            ),
          ],
        ),
        SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Add New Question',
          style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Category Input
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.label_important),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 20),
            _buildContentEditor('Question Content:', _questionContent),
            const SizedBox(height: 8),
            _buildContentEditor('Answer Content:', _answerContent),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Save Question'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.white70,
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _saveQuestion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
