import 'package:flutter/material.dart';

class IeltsSpeakingTest {
  final String id;
  final String title;
  final String description;
  final List<IeltsSpeakingPart> parts;
  final int totalDuration; // в минутах
  final String difficulty; // Easy, Medium, Hard
  final List<String> tags; // теги для категоризации
  final DateTime createdAt;

  IeltsSpeakingTest({
    required this.id,
    required this.title,
    required this.description,
    required this.parts,
    required this.totalDuration,
    required this.difficulty,
    required this.tags,
    required this.createdAt,
  });

  factory IeltsSpeakingTest.fromJson(Map<String, dynamic> json) {
    return IeltsSpeakingTest(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      parts: (json['parts'] as List?)
          ?.map((p) => IeltsSpeakingPart.fromJson(p))
          .toList() ?? [],
      totalDuration: json['totalDuration'] ?? 15,
      difficulty: json['difficulty'] ?? 'Medium',
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'parts': parts.map((p) => p.toJson()).toList(),
      'totalDuration': totalDuration,
      'difficulty': difficulty,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class IeltsSpeakingPart {
  final int partNumber; // 1, 2, или 3
  final String title;
  final String description;
  final String instructions;
  final int preparationTime; // в секундах (только для Part 2)
  final int speakingTime; // в минутах
  final List<IeltsQuestion> questions;
  final List<String> tips;

  IeltsSpeakingPart({
    required this.partNumber,
    required this.title,
    required this.description,
    required this.instructions,
    required this.preparationTime,
    required this.speakingTime,
    required this.questions,
    required this.tips,
  });

  factory IeltsSpeakingPart.fromJson(Map<String, dynamic> json) {
    return IeltsSpeakingPart(
      partNumber: json['partNumber'] ?? 1,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructions: json['instructions'] ?? '',
      preparationTime: json['preparationTime'] ?? 0,
      speakingTime: json['speakingTime'] ?? 2,
      questions: (json['questions'] as List?)
          ?.map((q) => IeltsQuestion.fromJson(q))
          .toList() ?? [],
      tips: List<String>.from(json['tips'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partNumber': partNumber,
      'title': title,
      'description': description,
      'instructions': instructions,
      'preparationTime': preparationTime,
      'speakingTime': speakingTime,
      'questions': questions.map((q) => q.toJson()).toList(),
      'tips': tips,
    };
  }
}

class IeltsQuestion {
  final String id;
  final String question;
  final String? followUp;
  final List<String>? sampleAnswers;
  final List<String>? vocabulary;
  final String? category;

  IeltsQuestion({
    required this.id,
    required this.question,
    this.followUp,
    this.sampleAnswers,
    this.vocabulary,
    this.category,
  });

  factory IeltsQuestion.fromJson(Map<String, dynamic> json) {
    return IeltsQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      followUp: json['followUp'],
      sampleAnswers: json['sampleAnswers'] != null
          ? List<String>.from(json['sampleAnswers'])
          : null,
      vocabulary: json['vocabulary'] != null
          ? List<String>.from(json['vocabulary'])
          : null,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'followUp': followUp,
      'sampleAnswers': sampleAnswers,
      'vocabulary': vocabulary,
      'category': category,
    };
  }
}

class IeltsCueCard {
  final String id;
  final String topic;
  final String description;
  final List<String> points;
  final List<String> vocabulary;
  final List<String> samplePhrases;
  final String difficulty;

  IeltsCueCard({
    required this.id,
    required this.topic,
    required this.description,
    required this.points,
    required this.vocabulary,
    required this.samplePhrases,
    required this.difficulty,
  });

  factory IeltsCueCard.fromJson(Map<String, dynamic> json) {
    return IeltsCueCard(
      id: json['id'] ?? '',
      topic: json['topic'] ?? '',
      description: json['description'] ?? '',
      points: List<String>.from(json['points'] ?? []),
      vocabulary: json['vocabulary'] != null
          ? List<String>.from(json['vocabulary'])
          : null,
      samplePhrases: List<String>.from(json['samplePhrases'] ?? []),
      difficulty: json['difficulty'] ?? 'Medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic': topic,
      'description': description,
      'points': points,
      'vocabulary': vocabulary,
      'samplePhrases': samplePhrases,
      'difficulty': difficulty,
    };
  }
}
