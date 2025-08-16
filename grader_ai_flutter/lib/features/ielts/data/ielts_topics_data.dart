import '../models/ielts_speaking_test.dart';

class IeltsTopicsData {
  static final List<IeltsSpeakingTest> allTests = [
    // ===== FAMILY & RELATIONSHIPS =====
    IeltsSpeakingTest(
      id: 'family_001',
      title: 'Family & Relationships',
      description: 'Discuss family dynamics, relationships, and personal connections',
      difficulty: 'Easy',
      tags: ['family', 'relationships', 'personal'],
      totalDuration: 15,
      createdAt: DateTime.now(),
      parts: [
        // Part 1: Introduction & General Discussion
        IeltsSpeakingPart(
          partNumber: 1,
          title: 'Introduction & Family',
          description: 'Answer questions about your family and relationships',
          instructions: 'Answer each question naturally. Speak for 2-3 sentences per answer.',
          preparationTime: 0,
          speakingTime: 4,
          questions: [
            IeltsQuestion(
              id: 'f1_1',
              question: 'Can you tell me about your family?',
              category: 'family',
              sampleAnswers: [
                'I come from a small family of four people - my parents, my younger sister, and me.',
                'We\'re a close-knit family and we spend a lot of time together.',
              ],
              vocabulary: ['nuclear family', 'extended family', 'close-knit', 'siblings'],
            ),
            IeltsQuestion(
              id: 'f1_2',
              question: 'How much time do you spend with your family?',
              category: 'family',
              sampleAnswers: [
                'I try to have dinner with my family every evening when possible.',
                'We also spend weekends together, usually going for walks or watching movies.',
              ],
              vocabulary: ['quality time', 'family dinner', 'weekend activities', 'bonding'],
            ),
            IeltsQuestion(
              id: 'f1_3',
              question: 'What do you usually do together as a family?',
              category: 'family',
              sampleAnswers: [
                'We enjoy cooking together, especially on weekends.',
                'We also like playing board games and going on family trips.',
              ],
              vocabulary: ['family activities', 'cooking together', 'board games', 'family trips'],
            ),
            IeltsQuestion(
              id: 'f1_4',
              question: 'Do you think family relationships are important?',
              category: 'family',
              sampleAnswers: [
                'Absolutely, I believe family relationships are the foundation of our lives.',
                'They provide us with support, love, and a sense of belonging.',
              ],
              vocabulary: ['foundation', 'support system', 'sense of belonging', 'emotional security'],
            ),
          ],
          tips: [
            'Use personal examples to make your answers more engaging',
            'Include specific details about your family members',
            'Express your genuine feelings about family relationships',
          ],
        ),
        
        // Part 2: Cue Card - Family Member
        IeltsSpeakingPart(
          partNumber: 2,
          title: 'Describe a Family Member',
          description: 'Talk about someone special in your family',
          instructions: 'You have 1 minute to prepare. Then speak for 1-2 minutes.',
          preparationTime: 60,
          speakingTime: 2,
          questions: [
            IeltsQuestion(
              id: 'f2_1',
              question: 'Describe a family member who has influenced you the most',
              category: 'family',
              sampleAnswers: [
                'I\'d like to talk about my grandmother, who has been a huge influence in my life.',
                'She taught me the importance of hard work and kindness to others.',
              ],
              vocabulary: ['influence', 'role model', 'inspiration', 'life lessons'],
            ),
          ],
          tips: [
            'Use the preparation time to organize your thoughts',
            'Include specific examples and memories',
            'Describe their personality and appearance',
            'Explain why they are important to you',
          ],
        ),
        
        // Part 3: Abstract Discussion
        IeltsSpeakingPart(
          partNumber: 3,
          title: 'Family in Modern Society',
          description: 'Discuss broader issues related to family and society',
          instructions: 'Give detailed answers with examples. Express your opinions clearly.',
          preparationTime: 0,
          speakingTime: 5,
          questions: [
            IeltsQuestion(
              id: 'f3_1',
              question: 'How have family structures changed in recent years?',
              category: 'society',
              sampleAnswers: [
                'Family structures have become more diverse, with single-parent families, blended families, and same-sex parents becoming more common.',
                'There\'s also been a shift towards smaller family sizes in many countries.',
              ],
              vocabulary: ['diverse', 'blended families', 'single-parent', 'nuclear family', 'extended family'],
            ),
            IeltsQuestion(
              id: 'f3_2',
              question: 'What challenges do modern families face?',
              category: 'society',
              sampleAnswers: [
                'Modern families often struggle with work-life balance, especially when both parents work full-time.',
                'Technology can also create distance between family members if not used mindfully.',
              ],
              vocabulary: ['work-life balance', 'dual-income', 'technology addiction', 'quality time'],
            ),
            IeltsQuestion(
              id: 'f3_3',
              question: 'Do you think family values are still important today?',
              category: 'society',
              sampleAnswers: [
                'Yes, I believe family values are still crucial in today\'s fast-paced world.',
                'They provide stability and help children develop strong moral foundations.',
              ],
              vocabulary: ['moral foundation', 'stability', 'traditional values', 'modern challenges'],
            ),
          ],
          tips: [
            'Connect your answers to broader social trends',
            'Use examples from different cultures or countries',
            'Express balanced opinions on complex issues',
          ],
        ),
      ],
    ),

    // ===== TECHNOLOGY & INNOVATION =====
    IeltsSpeakingTest(
      id: 'tech_001',
      title: 'Technology & Innovation',
      description: 'Explore the impact of technology on modern life and future developments',
      difficulty: 'Medium',
      tags: ['technology', 'innovation', 'digital', 'future'],
      totalDuration: 15,
      createdAt: DateTime.now(),
      parts: [
        // Part 1: Introduction & General Discussion
        IeltsSpeakingPart(
          partNumber: 1,
          title: 'Technology in Daily Life',
          description: 'Discuss how you use technology in your everyday life',
          instructions: 'Answer each question naturally. Speak for 2-3 sentences per answer.',
          preparationTime: 0,
          speakingTime: 4,
          questions: [
            IeltsQuestion(
              id: 't1_1',
              question: 'What technology do you use most often?',
              category: 'technology',
              sampleAnswers: [
                'I use my smartphone most frequently - for communication, navigation, and entertainment.',
                'I also rely heavily on my laptop for work and studying.',
              ],
              vocabulary: ['smartphone', 'laptop', 'digital devices', 'communication tools'],
            ),
            IeltsQuestion(
              id: 't1_2',
              question: 'How has technology changed the way you work or study?',
              category: 'technology',
              sampleAnswers: [
                'Technology has made studying much more convenient - I can access information instantly online.',
                'I can also collaborate with classmates remotely through various apps and platforms.',
              ],
              vocabulary: ['remote collaboration', 'online resources', 'digital platforms', 'instant access'],
            ),
            IeltsQuestion(
              id: 't1_3',
              question: 'Do you think technology makes life easier or more complicated?',
              category: 'technology',
              sampleAnswers: [
                'I think it\'s a bit of both - technology simplifies many tasks but can also create new challenges.',
                'For example, while apps make ordering food easier, they can also be addictive.',
              ],
              vocabulary: ['simplify', 'complicate', 'addictive', 'double-edged sword'],
            ),
            IeltsQuestion(
              id: 't1_4',
              question: 'What\'s the most recent technology you\'ve learned to use?',
              category: 'technology',
              sampleAnswers: [
                'I recently learned to use a new project management app for team collaboration.',
                'It took some time to get used to, but it\'s really improved our workflow.',
              ],
              vocabulary: ['project management', 'workflow', 'learning curve', 'adaptation'],
            ),
          ],
          tips: [
            'Give specific examples of how you use technology',
            'Mention both benefits and challenges',
            'Use current technology examples',
          ],
        ),
        
        // Part 2: Cue Card - Technology Impact
        IeltsSpeakingPart(
          partNumber: 2,
          title: 'Describe a Technology That Has Changed Your Life',
          description: 'Talk about a specific technology and its impact on you',
          instructions: 'You have 1 minute to prepare. Then speak for 1-2 minutes.',
          preparationTime: 60,
          speakingTime: 2,
          questions: [
            IeltsQuestion(
              id: 't2_1',
              question: 'Describe a piece of technology that has significantly changed your life',
              category: 'technology',
              sampleAnswers: [
                'I\'d like to talk about how the internet has transformed my life.',
                'It has opened up countless opportunities for learning and connecting with people worldwide.',
              ],
              vocabulary: ['transform', 'revolutionize', 'digital revolution', 'global connectivity'],
            ),
          ],
          tips: [
            'Choose a technology you\'re familiar with',
            'Explain both positive and negative impacts',
            'Give specific examples of how it changed your routine',
          ],
        ),
        
        // Part 3: Abstract Discussion
        IeltsSpeakingPart(
          partNumber: 3,
          title: 'Technology & Society',
          description: 'Discuss broader implications of technology on society and the future',
          instructions: 'Give detailed answers with examples. Express your opinions clearly.',
          preparationTime: 0,
          speakingTime: 5,
          questions: [
            IeltsQuestion(
              id: 't3_1',
              question: 'How do you think artificial intelligence will change the job market?',
              category: 'future',
              sampleAnswers: [
                'AI will likely automate many routine tasks, which could lead to job displacement in some sectors.',
                'However, it will also create new opportunities in AI development, data analysis, and creative fields.',
              ],
              vocabulary: ['automation', 'job displacement', 'AI development', 'creative fields', 'data analysis'],
            ),
            IeltsQuestion(
              id: 't3_2',
              question: 'What are the ethical concerns surrounding new technologies?',
              category: 'ethics',
              sampleAnswers: [
                'Privacy is a major concern, especially with how companies collect and use personal data.',
                'There are also questions about AI bias and the potential for technology to be used maliciously.',
              ],
              vocabulary: ['privacy concerns', 'data collection', 'AI bias', 'malicious use', 'ethical implications'],
            ),
            IeltsQuestion(
              id: 't3_3',
              question: 'Do you think we\'re too dependent on technology?',
              category: 'society',
              sampleAnswers: [
                'I think there\'s a growing dependency that could be problematic if we\'re not careful.',
                'It\'s important to maintain a balance and not lose basic skills like face-to-face communication.',
              ],
              vocabulary: ['dependency', 'problematic', 'balance', 'basic skills', 'face-to-face communication'],
            ),
          ],
          tips: [
            'Consider both positive and negative aspects',
            'Use examples from current events or trends',
            'Express balanced opinions on complex issues',
          ],
        ),
      ],
    ),

    // ===== ENVIRONMENT & SUSTAINABILITY =====
    IeltsSpeakingTest(
      id: 'env_001',
      title: 'Environment & Sustainability',
      description: 'Discuss environmental issues, climate change, and sustainable living',
      difficulty: 'Medium',
      tags: ['environment', 'sustainability', 'climate', 'nature'],
      totalDuration: 15,
      createdAt: DateTime.now(),
      parts: [
        // Part 1: Introduction & General Discussion
        IeltsSpeakingPart(
          partNumber: 1,
          title: 'Environmental Awareness',
          description: 'Discuss your relationship with nature and environmental concerns',
          instructions: 'Answer each question naturally. Speak for 2-3 sentences per answer.',
          preparationTime: 0,
          speakingTime: 4,
          questions: [
            IeltsQuestion(
              id: 'e1_1',
              question: 'Do you enjoy spending time in nature?',
              category: 'nature',
              sampleAnswers: [
                'Yes, I love being outdoors, especially hiking in the mountains or walking in parks.',
                'Nature helps me relax and feel more connected to the world around me.',
              ],
              vocabulary: ['outdoors', 'hiking', 'parks', 'relaxation', 'connection to nature'],
            ),
            IeltsQuestion(
              id: 'e1_2',
              question: 'What environmental issues concern you most?',
              category: 'environment',
              sampleAnswers: [
                'Climate change is my biggest concern because it affects everyone globally.',
                'I\'m also worried about plastic pollution and its impact on marine life.',
              ],
              vocabulary: ['climate change', 'global impact', 'plastic pollution', 'marine life', 'environmental concerns'],
            ),
            IeltsQuestion(
              id: 'e1_3',
              question: 'How do you try to be environmentally friendly?',
              category: 'sustainability',
              sampleAnswers: [
                'I try to reduce waste by using reusable bags and water bottles.',
                'I also make an effort to recycle and use public transportation when possible.',
              ],
              vocabulary: ['reduce waste', 'reusable', 'recycle', 'public transportation', 'eco-friendly'],
            ),
            IeltsQuestion(
              id: 'e1_4',
              question: 'What\'s the weather like in your country?',
              category: 'weather',
              sampleAnswers: [
                'My country has four distinct seasons with hot summers and cold winters.',
                'We also experience some extreme weather events like storms and heatwaves.',
              ],
              vocabulary: ['distinct seasons', 'extreme weather', 'storms', 'heatwaves', 'climate patterns'],
            ),
          ],
          tips: [
            'Connect personal experiences to broader environmental issues',
            'Show awareness of current environmental challenges',
            'Use specific examples of sustainable practices',
          ],
        ),
        
        // Part 2: Cue Card - Environmental Experience
        IeltsSpeakingPart(
          partNumber: 2,
          title: 'Describe an Environmental Problem',
          description: 'Talk about a specific environmental issue you\'ve observed',
          instructions: 'You have 1 minute to prepare. Then speak for 1-2 minutes.',
          preparationTime: 60,
          speakingTime: 2,
          questions: [
            IeltsQuestion(
              id: 'e2_1',
              question: 'Describe an environmental problem in your area',
              category: 'environment',
              sampleAnswers: [
                'I\'d like to talk about air pollution in my city, which has become a serious issue.',
                'The problem is mainly caused by heavy traffic and industrial emissions.',
              ],
              vocabulary: ['air pollution', 'traffic congestion', 'industrial emissions', 'environmental degradation'],
            ),
          ],
          tips: [
            'Choose a problem you\'ve personally observed',
            'Explain the causes and effects',
            'Suggest possible solutions',
          ],
        ),
        
        // Part 3: Abstract Discussion
        IeltsSpeakingPart(
          partNumber: 3,
          title: 'Global Environmental Challenges',
          description: 'Discuss broader environmental issues and solutions',
          instructions: 'Give detailed answers with examples. Express your opinions clearly.',
          preparationTime: 0,
          speakingTime: 5,
          questions: [
            IeltsQuestion(
              id: 'e3_1',
              question: 'What role should governments play in addressing climate change?',
              category: 'politics',
              sampleAnswers: [
                'Governments should implement strict environmental regulations and invest in renewable energy.',
                'They should also provide incentives for businesses and individuals to adopt sustainable practices.',
              ],
              vocabulary: ['environmental regulations', 'renewable energy', 'incentives', 'sustainable practices', 'policy implementation'],
            ),
            IeltsQuestion(
              id: 'e3_2',
              question: 'How can individuals make a difference in environmental protection?',
              category: 'society',
              sampleAnswers: [
                'Individuals can make significant impact through daily choices like reducing energy consumption.',
                'They can also support environmental organizations and vote for environmentally conscious leaders.',
              ],
              vocabulary: ['daily choices', 'energy consumption', 'environmental organizations', 'conscious leadership', 'collective action'],
            ),
            IeltsQuestion(
              id: 'e3_3',
              question: 'Do you think economic development and environmental protection can coexist?',
              category: 'economics',
              sampleAnswers: [
                'Yes, I believe they can coexist through sustainable development practices.',
                'Many countries are proving that green technology can drive economic growth.',
              ],
              vocabulary: ['sustainable development', 'green technology', 'economic growth', 'coexistence', 'innovation'],
            ),
          ],
          tips: [
            'Consider economic, social, and environmental perspectives',
            'Use examples from different countries or regions',
            'Discuss both challenges and opportunities',
          ],
        ),
      ],
    ),
  ];

  // Получить тесты по категории
  static List<IeltsSpeakingTest> getTestsByCategory(String category) {
    return allTests.where((test) => test.tags.contains(category)).toList();
  }

  // Получить тесты по сложности
  static List<IeltsSpeakingTest> getTestsByDifficulty(String difficulty) {
    return allTests.where((test) => test.difficulty == difficulty).toList();
  }

  // Получить случайный тест
  static IeltsSpeakingTest getRandomTest() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return allTests[random % allTests.length];
  }

  // Поиск тестов по ключевым словам
  static List<IeltsSpeakingTest> searchTests(String query) {
    final lowercaseQuery = query.toLowerCase();
    return allTests.where((test) {
      return test.title.toLowerCase().contains(lowercaseQuery) ||
          test.description.toLowerCase().contains(lowercaseQuery) ||
          test.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }
}
