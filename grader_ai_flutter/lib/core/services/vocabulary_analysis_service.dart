import 'dart:math';
import 'package:flutter/material.dart';

class VocabularyAnalysisService {
  // Simple words (A1-A2 level) - should be highlighted in red
  static const Set<String> _simpleWords = {
    'good', 'bad', 'big', 'small', 'nice', 'beautiful', 'ugly', 'happy', 'sad',
    'like', 'love', 'hate', 'want', 'need', 'have', 'get', 'make', 'do', 'go',
    'come', 'see', 'know', 'think', 'say', 'tell', 'ask', 'give', 'take',
    'very', 'really', 'so', 'too', 'much', 'many', 'some', 'any', 'all',
    'thing', 'way', 'time', 'day', 'year', 'people', 'man', 'woman', 'child',
    'house', 'home', 'work', 'school', 'friend', 'family', 'food', 'water',
    'money', 'car', 'book', 'phone', 'computer', 'internet', 'music', 'movie',
    'and', 'but', 'or', 'because', 'if', 'when', 'where', 'how', 'what', 'why',
    'yes', 'no', 'maybe', 'ok', 'okay', 'hello', 'hi', 'thanks', 'please',
    'sorry', 'excuse', 'help', 'can', 'will', 'would', 'could', 'should',
    'must', 'may', 'might', 'shall', 'am', 'is', 'are', 'was', 'were',
    'be', 'been', 'being', 'have', 'has', 'had', 'having', 'do', 'does', 'did',
    'doing', 'done', 'a', 'an', 'the', 'this', 'that', 'these', 'those',
    'i', 'you', 'he', 'she', 'it', 'we', 'they', 'me', 'him', 'her', 'us', 'them',
    'my', 'your', 'his', 'her', 'its', 'our', 'their', 'mine', 'yours', 'ours', 'theirs'
  };

  // Intermediate words (B1-B2 level) - should be highlighted in yellow
  static const Set<String> _intermediateWords = {
    'amazing', 'wonderful', 'fantastic', 'excellent', 'terrible', 'awful',
    'interesting', 'boring', 'exciting', 'surprising', 'disappointing',
    'important', 'necessary', 'useful', 'helpful', 'difficult', 'easy',
    'possible', 'impossible', 'different', 'similar', 'special', 'normal',
    'modern', 'traditional', 'popular', 'famous', 'successful', 'famous',
    'experience', 'opportunity', 'challenge', 'problem', 'solution', 'idea',
    'opinion', 'feeling', 'emotion', 'relationship', 'communication',
    'education', 'information', 'technology', 'environment', 'society',
    'culture', 'tradition', 'custom', 'habit', 'lifestyle', 'career',
    'business', 'company', 'organization', 'government', 'community',
    'development', 'improvement', 'progress', 'change', 'future', 'past',
    'present', 'recent', 'current', 'latest', 'recently', 'usually',
    'sometimes', 'often', 'always', 'never', 'rarely', 'occasionally',
    'probably', 'definitely', 'certainly', 'obviously', 'clearly',
    'especially', 'particularly', 'mainly', 'mostly', 'generally',
    'basically', 'actually', 'really', 'quite', 'rather', 'fairly',
    'absolutely', 'completely', 'totally', 'entirely', 'exactly',
    'approximately', 'roughly', 'about', 'around', 'nearly', 'almost'
  };

  // Advanced words (C1-C2 level) - should be highlighted in green
  static const Set<String> _advancedWords = {
    'sophisticated', 'comprehensive', 'substantial', 'significant',
    'remarkable', 'outstanding', 'exceptional', 'extraordinary',
    'phenomenal', 'incredible', 'tremendous', 'enormous', 'immense',
    'profound', 'intricate', 'complex', 'sophisticated', 'elaborate',
    'comprehensive', 'thorough', 'detailed', 'extensive', 'vast',
    'considerable', 'substantial', 'significant', 'notable', 'prominent',
    'distinguished', 'renowned', 'celebrated', 'acclaimed', 'esteemed',
    'prestigious', 'illustrious', 'eminent', 'outstanding', 'exceptional',
    'extraordinary', 'remarkable', 'noteworthy', 'memorable', 'unforgettable',
    'unprecedented', 'revolutionary', 'groundbreaking', 'innovative',
    'cutting-edge', 'state-of-the-art', 'contemporary', 'modern',
    'sophisticated', 'refined', 'elegant', 'graceful', 'polished',
    'meticulous', 'precise', 'accurate', 'exact', 'specific',
    'particular', 'unique', 'distinctive', 'characteristic', 'typical',
    'representative', 'exemplary', 'model', 'ideal', 'perfect',
    'flawless', 'impeccable', 'pristine', 'immaculate', 'spotless',
    'crystal-clear', 'transparent', 'obvious', 'evident', 'apparent',
    'manifest', 'conspicuous', 'noticeable', 'visible', 'perceptible',
    'discernible', 'recognizable', 'identifiable', 'distinguishable',
    'comprehensible', 'understandable', 'intelligible', 'coherent',
    'logical', 'rational', 'reasonable', 'sensible', 'practical',
    'pragmatic', 'realistic', 'feasible', 'viable', 'achievable',
    'attainable', 'obtainable', 'accessible', 'available', 'obtainable',
    'acquirable', 'procurable', 'securable', 'graspable', 'reachable'
  };

  // Filler words and repetitive phrases - should be highlighted in red
  static const Set<String> _fillerWords = {
    'um', 'uh', 'er', 'ah', 'like', 'you know', 'i mean', 'well', 'so',
    'basically', 'actually', 'literally', 'totally', 'really', 'very',
    'kind of', 'sort of', 'pretty much', 'more or less', 'at the end of the day',
    'to be honest', 'to tell you the truth', 'as a matter of fact',
    'in fact', 'indeed', 'certainly', 'surely', 'obviously', 'clearly'
  };

  static const Map<String, int> _wordFrequency = {};

  static void _updateWordFrequency(String word) {
    final normalizedWord = word.toLowerCase().trim();
    _wordFrequency[normalizedWord] = (_wordFrequency[normalizedWord] ?? 0) + 1;
  }

  static WordComplexity analyzeWord(String word) {
    final normalizedWord = word.toLowerCase().trim();
    
    // Update frequency
    _updateWordFrequency(normalizedWord);
    
    // Check for filler words
    if (_fillerWords.contains(normalizedWord)) {
      return WordComplexity.filler;
    }
    
    // Check for repeated words (appears more than 2 times)
    if (_wordFrequency[normalizedWord]! > 2) {
      return WordComplexity.repeated;
    }
    
    // Check complexity level
    if (_simpleWords.contains(normalizedWord)) {
      return WordComplexity.simple;
    } else if (_intermediateWords.contains(normalizedWord)) {
      return WordComplexity.intermediate;
    } else if (_advancedWords.contains(normalizedWord)) {
      return WordComplexity.advanced;
    }
    
    // Default to intermediate for unknown words
    return WordComplexity.intermediate;
  }

  static void resetFrequency() {
    _wordFrequency.clear();
  }

  static Map<String, int> getWordFrequency() {
    return Map.from(_wordFrequency);
  }

  static List<String> getMostRepeatedWords({int limit = 10}) {
    final sortedWords = _wordFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedWords.take(limit).map((e) => e.key).toList();
  }
}

enum WordComplexity {
  simple,      // Red - basic words, filler words, repeated words
  intermediate, // Yellow - B1-B2 level words
  advanced,    // Green - C1-C2 level words
  repeated,    // Red - words used more than 2 times
  filler,      // Red - filler words like "um", "like", "you know"
}

extension VocabularyAnalysisHelpers on VocabularyAnalysisService {
  static String normalize(String word) {
    final lower = word.toLowerCase();
    return lower.replaceAll(RegExp(r"^[^a-zA-Z']+|[^a-zA-Z']+") , '');
  }

  static bool isFiller(String word) => _fillerWords.contains(word);
  static bool isSimple(String word) => _simpleWords.contains(word);
  static bool isIntermediate(String word) => _intermediateWords.contains(word);
  static bool isAdvanced(String word) => _advancedWords.contains(word);

  // Pure classifier that does NOT mutate internal frequency map.
  static WordComplexity analyzeWithFrequencies(String word, Map<String, int> frequencies) {
    final normalized = normalize(word);
    if (normalized.isEmpty) return WordComplexity.intermediate;
    if (isFiller(normalized)) return WordComplexity.filler;
    if ((frequencies[normalized] ?? 0) > 2) return WordComplexity.repeated;
    if (isAdvanced(normalized)) return WordComplexity.advanced;
    if (isSimple(normalized)) return WordComplexity.simple;
    if (isIntermediate(normalized)) return WordComplexity.intermediate;
    return WordComplexity.intermediate;
  }
}

extension WordComplexityExtension on WordComplexity {
  Color get color {
    switch (this) {
      case WordComplexity.simple:
      case WordComplexity.repeated:
      case WordComplexity.filler:
        return Colors.red;
      case WordComplexity.intermediate:
        return Colors.orange;
      case WordComplexity.advanced:
        return Colors.green;
    }
  }

  String get description {
    switch (this) {
      case WordComplexity.simple:
        return 'Basic vocabulary (A1-A2)';
      case WordComplexity.intermediate:
        return 'Intermediate vocabulary (B1-B2)';
      case WordComplexity.advanced:
        return 'Advanced vocabulary (C1-C2)';
      case WordComplexity.repeated:
        return 'Repeated word';
      case WordComplexity.filler:
        return 'Filler word';
    }
  }
}
