import 'dart:convert';

enum ContentType { text, code, table, image }

ContentType contentTypeFromString(String value) {
  return ContentType.values.firstWhere(
    (e) => e.toString().split('.').last == value,
  );
}

String contentTypeToString(ContentType type) {
  return type.toString().split('.').last;
}

class ContentBlock {
  final ContentType type;
  String value; // Can be raw text, code, table (HTML), or image base64/path

  ContentBlock({required this.type, required this.value});

  factory ContentBlock.fromMap(Map<String, dynamic> map) {
    return ContentBlock(
      type: contentTypeFromString(map['type']),
      value: map['value'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'type': contentTypeToString(type), 'value': value};
  }
}

class Question {
  final int? id;
  final List<ContentBlock> questionContent;
  final List<ContentBlock> answerContent;
  final String category;
  final DateTime createdAt;

  Question({
    this.id,
    required this.questionContent,
    required this.answerContent,
    required this.category,
    required this.createdAt,
  });

  Question copyWith({
    int? id,
    List<ContentBlock>? questionContent,
    List<ContentBlock>? answerContent,
    String? category,
    DateTime? createdAt,
  }) {
    return Question(
      id: id ?? this.id,
      questionContent: questionContent ?? this.questionContent,
      answerContent: answerContent ?? this.answerContent,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      questionContent: (json.decode(map['questionContent']) as List)
          .map((e) => ContentBlock.fromMap(e))
          .toList(),
      answerContent: (json.decode(map['answerContent']) as List)
          .map((e) => ContentBlock.fromMap(e))
          .toList(),
      category: map['category'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'questionContent': json.encode(
        questionContent.map((e) => e.toMap()).toList(),
      ),
      'answerContent': json.encode(
        answerContent.map((e) => e.toMap()).toList(),
      ),
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };

    if (id != null) {
      map['id'] =
          id; // This should be fine as id is int? and map is Map<String, dynamic>
    }

    return map;
  }
}
