import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';
import '../../core/services/learning_progress_service.dart';

class InteractiveExercisePage extends StatefulWidget {
  final String exerciseType;
  final String topic;
  final Map<String, dynamic>? exerciseData;

  const InteractiveExercisePage({
    super.key,
    required this.exerciseType,
    required this.topic,
    this.exerciseData,
  });

  @override
  State<InteractiveExercisePage> createState() => _InteractiveExercisePageState();
}

class _InteractiveExercisePageState extends State<InteractiveExercisePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isCompleted = false;
  List<ExerciseQuestion> _questions = [];
  final Map<int, String> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateQuestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateQuestions() {
    switch (widget.exerciseType) {
      case 'vocabulary':
        _questions = _generateVocabularyQuestions();
        break;
      case 'grammar':
        _questions = _generateGrammarQuestions();
        break;
      case 'fluency':
        _questions = _generateFluencyQuestions();
        break;
      case 'pronunciation':
        _questions = _generatePronunciationQuestions();
        break;
      default:
        _questions = _generateMixedQuestions();
    }
  }

  List<ExerciseQuestion> _generateVocabularyQuestions() {
    return [
      // Basic Vocabulary
      ExerciseQuestion(
        question: 'Choose the most appropriate word for: "The weather was _____ today"',
        options: ['terrible', 'awful', 'horrible', 'all of the above'],
        correctAnswer: 3,
        explanation: 'All three words are appropriate synonyms for bad weather.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete the collocation: "make a _____"',
        options: ['decision', 'choice', 'selection', 'all of the above'],
        correctAnswer: 3,
        explanation: 'All three words can be used with "make a".',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'What is the opposite of "generous"?',
        options: ['selfish', 'mean', 'stingy', 'all of the above'],
        correctAnswer: 3,
        explanation: 'All three words are antonyms of generous.',
        type: QuestionType.multipleChoice,
      ),
      
      // Word Families
      ExerciseQuestion(
        question: 'Which word is NOT in the same family as "education"?',
        options: ['educate', 'educational', 'educator', 'edible'],
        correctAnswer: 3,
        explanation: 'Edible means "safe to eat" and is not related to education.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "The _____ of the building was impressive"',
        options: ['construct', 'construction', 'constructive', 'constructor'],
        correctAnswer: 1,
        explanation: 'Construction is the noun form needed here.',
        type: QuestionType.multipleChoice,
      ),
      
      // Collocations
      ExerciseQuestion(
        question: 'Which collocation is correct?',
        options: ['make a research', 'do a research', 'conduct research', 'both B and C'],
        correctAnswer: 3,
        explanation: 'We "do research" or "conduct research", not "make research".',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "She _____ a great impression on the interviewer"',
        options: ['made', 'did', 'gave', 'took'],
        correctAnswer: 0,
        explanation: 'We "make an impression" on someone.',
        type: QuestionType.multipleChoice,
      ),
      
      // Academic Vocabulary
      ExerciseQuestion(
        question: 'What does "significant" mean in academic context?',
        options: ['important', 'large', 'meaningful', 'all of the above'],
        correctAnswer: 3,
        explanation: 'Significant can mean important, large, or meaningful depending on context.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Which word is more formal: "big" or "substantial"?',
        options: ['big', 'substantial', 'both are equally formal', 'neither is formal'],
        correctAnswer: 1,
        explanation: 'Substantial is more formal and academic than "big".',
        type: QuestionType.multipleChoice,
      ),
      
      // Topic-specific Vocabulary
      ExerciseQuestion(
        question: 'What is a synonym for "environment" in environmental topics?',
        options: ['surroundings', 'ecosystem', 'habitat', 'all of the above'],
        correctAnswer: 3,
        explanation: 'All three words can be used as synonyms for environment in different contexts.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "The _____ of technology has changed our lives"',
        options: ['advancement', 'advance', 'advancing', 'advanced'],
        correctAnswer: 0,
        explanation: 'Advancement is the noun form needed here.',
        type: QuestionType.multipleChoice,
      ),
      
      // Idioms and Phrases
      ExerciseQuestion(
        question: 'What does "break the ice" mean?',
        options: ['to start a conversation', 'to end a relationship', 'to solve a problem', 'to make friends'],
        correctAnswer: 0,
        explanation: 'Break the ice means to start a conversation, especially in a social situation.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "It\'s raining cats and _____"',
        options: ['dogs', 'cats', 'birds', 'fish'],
        correctAnswer: 0,
        explanation: 'The idiom is "raining cats and dogs" meaning raining heavily.',
        type: QuestionType.multipleChoice,
      ),
      
      // Advanced Vocabulary
      ExerciseQuestion(
        question: 'What does "ubiquitous" mean?',
        options: ['everywhere', 'nowhere', 'somewhere', 'anywhere'],
        correctAnswer: 0,
        explanation: 'Ubiquitous means present everywhere or very common.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Which word means "to make something better"?',
        options: ['enhance', 'deteriorate', 'maintain', 'preserve'],
        correctAnswer: 0,
        explanation: 'Enhance means to improve or make something better.',
        type: QuestionType.multipleChoice,
      ),
      
      // Business Vocabulary
      ExerciseQuestion(
        question: 'What does "revenue" mean in business?',
        options: ['expenses', 'income', 'profit', 'loss'],
        correctAnswer: 1,
        explanation: 'Revenue is the total income generated by a business.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "The company needs to _____ its costs"',
        options: ['increase', 'reduce', 'maintain', 'all are possible'],
        correctAnswer: 3,
        explanation: 'All three options are grammatically correct, depending on the context.',
        type: QuestionType.multipleChoice,
      ),
      
      // Health Vocabulary
      ExerciseQuestion(
        question: 'What does "chronic" mean in medical context?',
        options: ['temporary', 'permanent', 'severe', 'mild'],
        correctAnswer: 1,
        explanation: 'Chronic means lasting for a long time or recurring frequently.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "Regular exercise can _____ your health"',
        options: ['improve', 'worsen', 'maintain', 'both A and C'],
        correctAnswer: 3,
        explanation: 'Exercise can both improve and maintain health.',
        type: QuestionType.multipleChoice,
      ),
      
      // Technology Vocabulary
      ExerciseQuestion(
        question: 'What does "innovative" mean?',
        options: ['old-fashioned', 'creative', 'expensive', 'simple'],
        correctAnswer: 1,
        explanation: 'Innovative means featuring new methods or ideas; creative.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "The new software is very _____"',
        options: ['user-friendly', 'user-unfriendly', 'user-difficult', 'user-hard'],
        correctAnswer: 0,
        explanation: 'User-friendly means easy to use.',
        type: QuestionType.multipleChoice,
      ),
    ];
  }

  List<ExerciseQuestion> _generateGrammarQuestions() {
    return [
      // Tenses
      ExerciseQuestion(
        question: 'Choose the correct tense: "I _____ English for 5 years"',
        options: ['study', 'am studying', 'have been studying', 'studied'],
        correctAnswer: 2,
        explanation: 'Present perfect continuous is used for actions that started in the past and continue to the present.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Which sentence is grammatically correct?',
        options: [
          'If I would have time, I will help you',
          'If I have time, I will help you',
          'If I had time, I will help you',
          'If I will have time, I will help you'
        ],
        correctAnswer: 1,
        explanation: 'First conditional: If + present simple, will + infinitive.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "The book _____ I read yesterday was very interesting"',
        options: ['which', 'that', 'who', 'both A and B'],
        correctAnswer: 3,
        explanation: 'Both "which" and "that" can be used as relative pronouns for things.',
        type: QuestionType.multipleChoice,
      ),
      
      // Conditionals
      ExerciseQuestion(
        question: 'Complete: "If I _____ you, I would study harder"',
        options: ['am', 'was', 'were', 'will be'],
        correctAnswer: 2,
        explanation: 'Second conditional uses "were" for all persons in the if-clause.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Which is correct: "If I had known, I _____ come"',
        options: ['would', 'would have', 'will', 'will have'],
        correctAnswer: 1,
        explanation: 'Third conditional: If + past perfect, would have + past participle.',
        type: QuestionType.multipleChoice,
      ),
      
      // Passive Voice
      ExerciseQuestion(
        question: 'Change to passive: "They built this house in 1990"',
        options: [
          'This house was built in 1990',
          'This house is built in 1990',
          'This house has been built in 1990',
          'This house will be built in 1990'
        ],
        correctAnswer: 0,
        explanation: 'Past simple passive: was/were + past participle.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "The letter _____ by the secretary"',
        options: ['writes', 'is writing', 'is written', 'has written'],
        correctAnswer: 2,
        explanation: 'Present simple passive: is/are + past participle.',
        type: QuestionType.multipleChoice,
      ),
      
      // Reported Speech
      ExerciseQuestion(
        question: 'Reported speech: "I am happy" → He said _____',
        options: ['he is happy', 'he was happy', 'he will be happy', 'he has been happy'],
        correctAnswer: 1,
        explanation: 'Present simple changes to past simple in reported speech.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Reported speech: "I will come tomorrow" → She said _____',
        options: ['she will come tomorrow', 'she would come tomorrow', 'she comes tomorrow', 'she came tomorrow'],
        correctAnswer: 1,
        explanation: 'Will changes to would in reported speech.',
        type: QuestionType.multipleChoice,
      ),
      
      // Articles
      ExerciseQuestion(
        question: 'Complete: "_____ sun rises in _____ east"',
        options: ['The, the', 'A, a', 'The, a', 'A, the'],
        correctAnswer: 0,
        explanation: 'Use "the" with unique things (sun) and directions (east).',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "I need _____ advice"',
        options: ['a', 'an', 'the', 'no article'],
        correctAnswer: 3,
        explanation: 'Advice is uncountable, so no article is needed.',
        type: QuestionType.multipleChoice,
      ),
      
      // Prepositions
      ExerciseQuestion(
        question: 'Complete: "I\'m interested _____ learning English"',
        options: ['in', 'on', 'at', 'for'],
        correctAnswer: 0,
        explanation: 'Interested in + noun/gerund is the correct preposition.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "I arrived _____ the airport at 3 PM"',
        options: ['in', 'at', 'on', 'to'],
        correctAnswer: 1,
        explanation: 'Arrive at + place (airport, station, etc.).',
        type: QuestionType.multipleChoice,
      ),
      
      // Gerunds and Infinitives
      ExerciseQuestion(
        question: 'Complete: "I enjoy _____ music"',
        options: ['listen to', 'listening to', 'to listen to', 'listen'],
        correctAnswer: 1,
        explanation: 'Enjoy + gerund (verb + ing).',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "I want _____ a doctor"',
        options: ['be', 'being', 'to be', 'been'],
        correctAnswer: 2,
        explanation: 'Want + infinitive (to + verb).',
        type: QuestionType.multipleChoice,
      ),
      
      // Modal Verbs
      ExerciseQuestion(
        question: 'Complete: "You _____ wear a seatbelt in the car"',
        options: ['can', 'should', 'must', 'both B and C'],
        correctAnswer: 3,
        explanation: 'Both "should" (advice) and "must" (obligation) are correct here.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "I _____ speak three languages"',
        options: ['can', 'should', 'must', 'have to'],
        correctAnswer: 0,
        explanation: 'Can expresses ability.',
        type: QuestionType.multipleChoice,
      ),
      
      // Complex Sentences
      ExerciseQuestion(
        question: 'Complete: "_____ it was raining, we went for a walk"',
        options: ['Although', 'Because', 'Since', 'Due to'],
        correctAnswer: 0,
        explanation: 'Although shows contrast between two ideas.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "I\'ll call you _____ I arrive"',
        options: ['as soon as', 'while', 'during', 'until'],
        correctAnswer: 0,
        explanation: 'As soon as means immediately after.',
        type: QuestionType.multipleChoice,
      ),
      
      // Countable/Uncountable
      ExerciseQuestion(
        question: 'Complete: "How _____ money do you have?"',
        options: ['many', 'much', 'a lot', 'some'],
        correctAnswer: 1,
        explanation: 'Much is used with uncountable nouns like money.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "There are _____ people here"',
        options: ['much', 'many', 'a lot', 'both B and C'],
        correctAnswer: 3,
        explanation: 'Many and a lot of are both correct with countable nouns.',
        type: QuestionType.multipleChoice,
      ),
      
      // Comparative and Superlative
      ExerciseQuestion(
        question: 'Complete: "This is _____ book I\'ve ever read"',
        options: ['good', 'better', 'best', 'the best'],
        correctAnswer: 3,
        explanation: 'Superlative form: the + adjective + est.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "She is _____ than her sister"',
        options: ['tall', 'taller', 'tallest', 'the tallest'],
        correctAnswer: 1,
        explanation: 'Comparative form: adjective + er + than.',
        type: QuestionType.multipleChoice,
      ),
    ];
  }

  List<ExerciseQuestion> _generateFluencyQuestions() {
    return [
      // Linking Ideas
      ExerciseQuestion(
        question: 'How would you connect these ideas smoothly?\n"I love music. I play guitar."',
        options: [
          'I love music, and I play guitar.',
          'I love music. I also play guitar.',
          'I love music. In fact, I play guitar.',
          'All of the above'
        ],
        correctAnswer: 3,
        explanation: 'All three options show smooth connection between ideas.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Which phrase helps with fluency when you need thinking time?',
        options: ['Well...', 'Let me think...', 'That\'s a good question...', 'All of the above'],
        correctAnswer: 3,
        explanation: 'All these phrases give you time to think while maintaining fluency.',
        type: QuestionType.multipleChoice,
      ),
      
      // Discourse Markers
      ExerciseQuestion(
        question: 'Complete: "I like coffee. _____, I prefer tea"',
        options: ['However', 'Therefore', 'Moreover', 'Furthermore'],
        correctAnswer: 0,
        explanation: 'However shows contrast between two ideas.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "I study hard. _____, I get good grades"',
        options: ['However', 'Therefore', 'Moreover', 'Furthermore'],
        correctAnswer: 1,
        explanation: 'Therefore shows cause and effect relationship.',
        type: QuestionType.multipleChoice,
      ),
      
      // Paraphrasing
      ExerciseQuestion(
        question: 'How would you paraphrase: "I think technology is important"?',
        options: [
          'In my opinion, technology is important',
          'I believe technology is important',
          'From my perspective, technology is important',
          'All of the above'
        ],
        correctAnswer: 3,
        explanation: 'All three options are good ways to paraphrase the original statement.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "I disagree with this idea. _____, I think..."',
        options: ['Instead', 'Rather', 'On the contrary', 'All of the above'],
        correctAnswer: 3,
        explanation: 'All three options can introduce a contrasting opinion.',
        type: QuestionType.multipleChoice,
      ),
      
      // Giving Examples
      ExerciseQuestion(
        question: 'Complete: "I enjoy outdoor activities. _____, I like hiking"',
        options: ['For example', 'Such as', 'Like', 'All of the above'],
        correctAnswer: 3,
        explanation: 'All three options can introduce examples.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "There are many benefits. _____, it saves time"',
        options: ['For instance', 'For example', 'Such as', 'Both A and B'],
        correctAnswer: 3,
        explanation: 'For instance and For example both introduce specific examples.',
        type: QuestionType.multipleChoice,
      ),
      
      // Expressing Opinions
      ExerciseQuestion(
        question: 'Complete: "_____ my view, this is a good idea"',
        options: ['In', 'On', 'From', 'All of the above'],
        correctAnswer: 3,
        explanation: 'All three prepositions can be used with "view" to express opinion.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "I _____ that this is the best solution"',
        options: ['think', 'believe', 'feel', 'all of the above'],
        correctAnswer: 3,
        explanation: 'All three verbs can express personal opinion.',
        type: QuestionType.multipleChoice,
      ),
      
      // Agreeing and Disagreeing
      ExerciseQuestion(
        question: 'Complete: "I _____ with you completely"',
        options: ['agree', 'disagree', 'both are possible', 'neither'],
        correctAnswer: 2,
        explanation: 'Both agree and disagree are grammatically correct, depending on context.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "That\'s a _____ point"',
        options: ['good', 'valid', 'interesting', 'all of the above'],
        correctAnswer: 3,
        explanation: 'All three adjectives can be used to acknowledge someone\'s point.',
        type: QuestionType.multipleChoice,
      ),
      
      // Asking for Clarification
      ExerciseQuestion(
        question: 'Complete: "Could you _____ what you mean?"',
        options: ['explain', 'clarify', 'elaborate on', 'all of the above'],
        correctAnswer: 3,
        explanation: 'All three verbs can be used to ask for clarification.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "I\'m not sure I understand. _____ you repeat that?"',
        options: ['Could', 'Can', 'Would', 'All of the above'],
        correctAnswer: 3,
        explanation: 'All three modal verbs can be used to ask for repetition.',
        type: QuestionType.multipleChoice,
      ),
      
      // Expressing Uncertainty
      ExerciseQuestion(
        question: 'Complete: "I\'m not _____ sure about this"',
        options: ['completely', 'entirely', 'totally', 'all of the above'],
        correctAnswer: 3,
        explanation: 'All three adverbs can express uncertainty.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "_____ this might be true"',
        options: ['Perhaps', 'Maybe', 'Possibly', 'All of the above'],
        correctAnswer: 3,
        explanation: 'All three words can express possibility or uncertainty.',
        type: QuestionType.multipleChoice,
      ),
      
      // Comparing and Contrasting
      ExerciseQuestion(
        question: 'Complete: "This is _____ than that"',
        options: ['better', 'worse', 'different', 'all of the above'],
        correctAnswer: 3,
        explanation: 'All three adjectives can be used in comparative structures.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "_____ the other hand, there are disadvantages"',
        options: ['On', 'In', 'At', 'From'],
        correctAnswer: 0,
        explanation: 'On the other hand is the correct phrase for contrast.',
        type: QuestionType.multipleChoice,
      ),
      
      // Summarizing
      ExerciseQuestion(
        question: 'Complete: "_____ all, I think this is a good idea"',
        options: ['In', 'After', 'Above', 'All of the above'],
        correctAnswer: 3,
        explanation: 'All three phrases can be used to summarize or conclude.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Complete: "To _____, this is my opinion"',
        options: ['summarize', 'conclude', 'finish', 'both A and B'],
        correctAnswer: 3,
        explanation: 'Both summarize and conclude can be used to end a discussion.',
        type: QuestionType.multipleChoice,
      ),
    ];
  }

  List<ExerciseQuestion> _generatePronunciationQuestions() {
    return [
      // Word Stress
      ExerciseQuestion(
        question: 'Which word has a different stress pattern?',
        options: ['PHOtograph', 'phoTOgraphy', 'photoGRAPHic', 'PHOtographer'],
        correctAnswer: 1,
        explanation: 'Photography has stress on the second syllable, while others have stress on the first.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Which word has stress on the first syllable?',
        options: ['comPUter', 'COMPuter', 'compuTER', 'comPUter'],
        correctAnswer: 1,
        explanation: 'Computer has stress on the first syllable: COM-put-er.',
        type: QuestionType.multipleChoice,
      ),
      
      // Vowel Sounds
      ExerciseQuestion(
        question: 'Which word has the same vowel sound as "cat"?',
        options: ['car', 'care', 'cut', 'caught'],
        correctAnswer: 2,
        explanation: 'Cut has the same short /ʌ/ sound as cat.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Which word has the same vowel sound as "meet"?',
        options: ['met', 'meat', 'mate', 'mute'],
        correctAnswer: 1,
        explanation: 'Meat has the same long /i:/ sound as meet.',
        type: QuestionType.multipleChoice,
      ),
      
      // Consonant Sounds
      ExerciseQuestion(
        question: 'Which word has the same consonant sound as "think"?',
        options: ['this', 'that', 'three', 'through'],
        correctAnswer: 2,
        explanation: 'Three has the same /θ/ sound as think.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Which word has the same consonant sound as "ship"?',
        options: ['chip', 'tip', 'zip', 'lip'],
        correctAnswer: 0,
        explanation: 'Chip has the same /ʃ/ sound as ship.',
        type: QuestionType.multipleChoice,
      ),
      
      // Silent Letters
      ExerciseQuestion(
        question: 'Which letter is silent in "comb"?',
        options: ['c', 'o', 'm', 'b'],
        correctAnswer: 3,
        explanation: 'The letter "b" is silent in comb.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Which letter is silent in "knight"?',
        options: ['k', 'n', 'g', 'h'],
        correctAnswer: 0,
        explanation: 'The letter "k" is silent in knight.',
        type: QuestionType.multipleChoice,
      ),
      
      // Word Endings
      ExerciseQuestion(
        question: 'How do you pronounce the "-ed" ending in "walked"?',
        options: ['/t/', '/d/', '/ɪd/', '/ed/'],
        correctAnswer: 0,
        explanation: 'Walked ends with /t/ sound because "walk" ends with /k/.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'How do you pronounce the "-ed" ending in "needed"?',
        options: ['/t/', '/d/', '/ɪd/', '/ed/'],
        correctAnswer: 2,
        explanation: 'Needed ends with /ɪd/ because "need" ends with /d/.',
        type: QuestionType.multipleChoice,
      ),
      
      // Connected Speech
      ExerciseQuestion(
        question: 'How do you pronounce "I am" in connected speech?',
        options: ['I am', 'I\'m', 'I\'m', 'both B and C'],
        correctAnswer: 3,
        explanation: 'In connected speech, "I am" becomes "I\'m" with contraction.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'How do you pronounce "going to" in connected speech?',
        options: ['going to', 'gonna', 'going to', 'both A and B'],
        correctAnswer: 3,
        explanation: 'Both forms are correct, with "gonna" being more informal.',
        type: QuestionType.multipleChoice,
      ),
      
      // Intonation
      ExerciseQuestion(
        question: 'Which sentence has rising intonation?',
        options: ['I like coffee.', 'Do you like coffee?', 'Coffee is good.', 'I don\'t like coffee.'],
        correctAnswer: 1,
        explanation: 'Questions typically have rising intonation.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Which sentence has falling intonation?',
        options: ['Are you coming?', 'I\'m coming.', 'Really?', 'Is that so?'],
        correctAnswer: 1,
        explanation: 'Statements typically have falling intonation.',
        type: QuestionType.multipleChoice,
      ),
      
      // Minimal Pairs
      ExerciseQuestion(
        question: 'Which words are minimal pairs?',
        options: ['ship/sheep', 'bit/beat', 'cat/cut', 'all of the above'],
        correctAnswer: 3,
        explanation: 'All three pairs differ by only one sound.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Which words have the same vowel sound?',
        options: ['pin/pen', 'bit/bet', 'sit/set', 'none of the above'],
        correctAnswer: 3,
        explanation: 'All pairs have different vowel sounds.',
        type: QuestionType.multipleChoice,
      ),
      
      // Syllable Count
      ExerciseQuestion(
        question: 'How many syllables does "beautiful" have?',
        options: ['2', '3', '4', '5'],
        correctAnswer: 1,
        explanation: 'Beautiful has 3 syllables: beau-ti-ful.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'How many syllables does "information" have?',
        options: ['3', '4', '5', '6'],
        correctAnswer: 1,
        explanation: 'Information has 4 syllables: in-for-ma-tion.',
        type: QuestionType.multipleChoice,
      ),
      
      // Common Pronunciation Mistakes
      ExerciseQuestion(
        question: 'Which is the correct pronunciation of "clothes"?',
        options: ['/kloʊðz/', '/kloʊθs/', '/kloʊðɪz/', '/kloʊθɪz/'],
        correctAnswer: 0,
        explanation: 'Clothes is pronounced /kloʊðz/ with voiced /ð/ sound.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Which is the correct pronunciation of "comfortable"?',
        options: ['/kʌmfərtəbəl/', '/kʌmftəbəl/', '/kʌmfərtəbl/', '/kʌmftəbl/'],
        correctAnswer: 1,
        explanation: 'Comfortable is often pronounced /kʌmftəbəl/ in connected speech.',
        type: QuestionType.multipleChoice,
      ),
      
      // Word Stress Patterns
      ExerciseQuestion(
        question: 'Which word follows the stress pattern Oo (stressed-unstressed)?',
        options: ['HAPpy', 'hapPY', 'HAPPY', 'hapPY'],
        correctAnswer: 0,
        explanation: 'Happy follows the Oo pattern with stress on the first syllable.',
        type: QuestionType.multipleChoice,
      ),
      ExerciseQuestion(
        question: 'Which word follows the stress pattern oO (unstressed-stressed)?',
        options: ['beGIN', 'BEgin', 'beGIN', 'beGIN'],
        correctAnswer: 0,
        explanation: 'Begin follows the oO pattern with stress on the second syllable.',
        type: QuestionType.multipleChoice,
      ),
    ];
  }

  List<ExerciseQuestion> _generateMixedQuestions() {
    return [
      // Vocabulary Questions
      ..._generateVocabularyQuestions().take(5),
      // Grammar Questions  
      ..._generateGrammarQuestions().take(5),
      // Fluency Questions
      ..._generateFluencyQuestions().take(5),
      // Pronunciation Questions
      ..._generatePronunciationQuestions().take(5),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '${widget.exerciseType.toUpperCase()} Practice',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary,
            size: 20.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF3B82F6),
          labelColor: const Color(0xFF3B82F6),
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Exercise'),
            Tab(text: 'Results'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExerciseTab(),
          _buildResultsTab(),
        ],
      ),
    );
  }

  Widget _buildExerciseTab() {
    if (_isCompleted) {
      return _buildCompletionScreen();
    }

    if (_currentQuestionIndex >= _questions.length) {
      _completeExercise();
      return _buildCompletionScreen();
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          SizedBox(height: 24.h),
          
          // Question
          _buildQuestionCard(currentQuestion),
          SizedBox(height: 24.h),
          
          // Answer options
          _buildAnswerOptions(currentQuestion),
          SizedBox(height: 24.h),
          
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Score: $_score',
                style: AppTypography.titleMedium.copyWith(
                  color: const Color(0xFF3B82F6),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF3B82F6)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(ExerciseQuestion question) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.quiz_rounded,
                  color: const Color(0xFF3B82F6),
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Question ${_currentQuestionIndex + 1}',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            question.question,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(ExerciseQuestion question) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose your answer:',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _userAnswers[_currentQuestionIndex] == option;
            
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: GestureDetector(
                onTap: () => _selectAnswer(option),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF3B82F6).withOpacity(0.1)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF3B82F6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF9CA3AF),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16.w,
                              )
                            : null,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          '${String.fromCharCode(65 + index)}. $option',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final hasAnswer = _userAnswers.containsKey(_currentQuestionIndex);
    
    return Row(
      children: [
        if (_currentQuestionIndex > 0)
          Expanded(
            child: ElevatedButton(
              onPressed: _previousQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(color: AppColors.textPrimary.withOpacity(0.2)),
                ),
                elevation: 0,
              ),
              child: Text(
                'Previous',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (_currentQuestionIndex > 0) SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton(
            onPressed: hasAnswer ? _nextQuestion : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasAnswer ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
              foregroundColor: hasAnswer ? Colors.white : AppColors.textSecondary,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              _currentQuestionIndex == _questions.length - 1 ? 'Finish' : 'Next',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionScreen() {
    final percentage = (_score / _questions.length * 100).round();
    final isGoodScore = percentage >= 70;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Completion header
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isGoodScore
                    ? [const Color(0xFF10B981), const Color(0xFF059669)]
                    : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: (isGoodScore ? const Color(0xFF10B981) : const Color(0xFF3B82F6)).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  isGoodScore ? Icons.celebration_rounded : Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 64.w,
                ),
                SizedBox(height: 16.h),
                Text(
                  isGoodScore ? 'Excellent Work!' : 'Good Job!',
                  style: AppTypography.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'You scored $percentage%',
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$_score out of ${_questions.length} correct',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Detailed results
          _buildDetailedResults(),
          
          SizedBox(height: 24.h),
          
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDetailedResults() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Results',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          ..._questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final userAnswer = _userAnswers[index];
            final isCorrect = userAnswer == question.options[question.correctAnswer];
            
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isCorrect 
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isCorrect 
                        ? const Color(0xFF10B981).withOpacity(0.3)
                        : const Color(0xFFEF4444).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          size: 20.w,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Question ${index + 1}',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      question.question,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Your answer: $userAnswer',
                      style: AppTypography.bodySmall.copyWith(
                        color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (!isCorrect) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'Correct answer: ${question.options[question.correctAnswer]}',
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    SizedBox(height: 8.h),
                    Text(
                      question.explanation,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _retryExercise,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Try Again',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(color: AppColors.textPrimary.withOpacity(0.2)),
              ),
              elevation: 0,
            ),
            child: Text(
              'Back to Learning',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exercise Results',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          // TODO: Add detailed results analysis
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Detailed results analysis coming soon',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Event handlers
  void _selectAnswer(String answer) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
    });
  }

  void _nextQuestion() {
    final currentQuestion = _questions[_currentQuestionIndex];
    final userAnswer = _userAnswers[_currentQuestionIndex];
    
    if (userAnswer == currentQuestion.options[currentQuestion.correctAnswer]) {
      setState(() {
        _score++;
      });
    }
    
    setState(() {
      _currentQuestionIndex++;
    });
  }

  void _previousQuestion() {
    setState(() {
      _currentQuestionIndex--;
    });
  }

  void _completeExercise() {
    setState(() {
      _isCompleted = true;
    });
    
    // Update learning progress
    final progressService = LearningProgressService();
    // TODO: Add exercise completion to progress tracking
    // progressService.addExerciseCompletion(widget.exerciseType, _score, _questions.length);
  }

  void _retryExercise() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _isCompleted = false;
      _userAnswers.clear();
    });
  }
}

// Data models
class ExerciseQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final QuestionType type;

  ExerciseQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.type,
  });
}

enum QuestionType {
  multipleChoice,
  fillInTheBlank,
  trueFalse,
  matching,
}
