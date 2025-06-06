import 'dart:io';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../db/question_database.dart';
import 'package:image_picker/image_picker.dart';

class AddQuestionScreen extends StatefulWidget {
  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _categoryController = TextEditingController();
  List<ContentBlock> _questionContent = [];
  List<ContentBlock> _answerContent = [];

  final ImagePicker _picker = ImagePicker();

  void _addContent(
    List<ContentBlock> target,
    ContentType type, [
    String? value,
  ]) {
    setState(() {
      target.add(ContentBlock(type: type, value: value ?? ''));
    });
  }

  // <-- CHANGED: replaced FilePicker with ImagePicker
  Future<void> _pickImage(List<ContentBlock> target) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          target.add(
            ContentBlock(type: ContentType.image, value: pickedFile.path),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _saveQuestion() async {
    if (_categoryController.text.trim().isEmpty ||
        _questionContent.isEmpty ||
        _answerContent.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final newQuestion = Question(
      category: _categoryController.text.trim(),
      questionContent: _questionContent,
      answerContent: _answerContent,
      createdAt: DateTime.now(),
    );

    await QuestionDatabase.instance.create(newQuestion);
    Navigator.pop(context);
  }

  Widget _buildContentEditor(String label, List<ContentBlock> contentList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
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
                  labelText: block.type == ContentType.code
                      ? 'Code Block'
                      : 'Text',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () =>
                        setState(() => contentList.removeAt(index)),
                  ),
                ),
                onChanged: (val) => block.value = val,
              );
              break;
            case ContentType.image:
              editor = ListTile(
                title: Text('Image: ${block.value.split('/').last}'),
                subtitle: Image.file(File(block.value)),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => setState(() => contentList.removeAt(index)),
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
            ElevatedButton.icon(
              icon: Icon(Icons.text_fields),
              label: Text("Text"),
              onPressed: () => _addContent(contentList, ContentType.text),
            ),
            SizedBox(width: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.code),
              label: Text("Code"),
              onPressed: () => _addContent(contentList, ContentType.code),
            ),
            SizedBox(width: 8),
            ElevatedButton.icon(
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
      appBar: AppBar(title: Text('Add New Question')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 16),
            _buildContentEditor('Question Content:', _questionContent),
            _buildContentEditor('Answer Content:', _answerContent),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveQuestion,
              child: Text('Save Question'),
            ),
          ],
        ),
      ),
    );
  }
}
