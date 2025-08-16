import '../models/ielts_speaking_test.dart';

class IeltsTopicsExtended {
  static final List<IeltsSpeakingTest> additionalTests = [
    // ===== EDUCATION & LEARNING =====
    IeltsSpeakingTest(
      id: 'edu_001',
      title: 'Education & Learning',
      description: 'Discuss educational experiences, learning methods, and academic challenges',
      difficulty: 'Easy',
      tags: ['education', 'learning', 'academic', 'school'],
      totalDuration: 15,
      createdAt: DateTime.now(),
      parts: [
        // Part 1: Introduction & General Discussion
        IeltsSpeakingPart(
          partNumber: 1,
          title: 'Your Educational Background',
          description: 'Discuss your educational experiences and preferences',
          instructions: 'Answer each question naturally. Speak for 2-3 sentences per answer.',
          preparationTime: 0,
          speakingTime: 4,
          questions: [
            IeltsQuestion(
              id: 'ed1_1',
              question: 'What subjects did you enjoy most at school?',
              category: 'education',
              sampleAnswers: [
                'I really enjoyed science subjects, especially biology and chemistry.',
                'I also liked languages because I found them challenging and rewarding.',
              ],
              vocabulary: ['science subjects', 'biology', 'chemistry', 'languages', 'challenging', 'rewarding'],
            ),
            IeltsQuestion(
              id: 'ed1_2',
              question: 'How do you prefer to learn new things?',
              category: 'learning',
              sampleAnswers: [
                'I prefer hands-on learning and practical experience over just reading theory.',
                'I also learn well through discussions and group work with others.',
              ],
              vocabulary: ['hands-on learning', 'practical experience', 'theory', 'discussions', 'group work'],
            ),
            IeltsQuestion(
              id: 'ed1_3',
              question: 'What\'s the most challenging thing you\'ve ever learned?',
              category: 'learning',
              sampleAnswers: [
                'Learning to drive was quite challenging for me, especially parallel parking.',
                'I also found learning a new language difficult at first, but it became easier with practice.',
              ],
              vocabulary: ['parallel parking', 'language acquisition', 'practice', 'perseverance', 'skill development'],
            ),
            IeltsQuestion(
              id: 'ed1_4',
              question: 'Do you think education is important for success?',
              category: 'education',
              sampleAnswers: [
                'Yes, I believe education provides essential knowledge and skills for success.',
                'However, I also think practical experience and personal qualities are equally important.',
              ],
              vocabulary: ['essential knowledge', 'practical experience', 'personal qualities', 'success factors', 'balanced approach'],
            ),
          ],
          tips: [
            'Use specific examples from your educational experience',
            'Show reflection on your learning preferences',
            'Express balanced opinions on education',
          ],
        ),
        
        // Part 2: Cue Card - Learning Experience
        IeltsSpeakingPart(
          partNumber: 2,
          title: 'Describe a Learning Experience',
          description: 'Talk about a memorable learning experience',
          instructions: 'You have 1 minute to prepare. Then speak for 1-2 minutes.',
          preparationTime: 60,
          speakingTime: 2,
          questions: [
            IeltsQuestion(
              id: 'ed2_1',
              question: 'Describe a time when you learned something important',
              category: 'learning',
              sampleAnswers: [
                'I\'d like to talk about when I learned to swim as an adult.',
                'It was challenging but taught me the importance of perseverance and facing fears.',
              ],
              vocabulary: ['perseverance', 'facing fears', 'adult learning', 'challenge', 'personal growth'],
            ),
          ],
          tips: [
            'Choose a learning experience that had a lasting impact',
            'Explain what you learned and how it changed you',
            'Include specific details and emotions',
          ],
        ),
        
        // Part 3: Abstract Discussion
        IeltsSpeakingPart(
          partNumber: 3,
          title: 'Education & Society',
          description: 'Discuss broader issues in education and learning',
          instructions: 'Give detailed answers with examples. Express your opinions clearly.',
          preparationTime: 0,
          speakingTime: 5,
          questions: [
            IeltsQuestion(
              id: 'ed3_1',
              question: 'How has technology changed education in recent years?',
              category: 'technology',
              sampleAnswers: [
                'Technology has revolutionized education through online learning platforms and digital resources.',
                'It has made education more accessible and personalized, though it also presents new challenges.',
              ],
              vocabulary: ['revolutionize', 'online learning', 'digital resources', 'accessibility', 'personalization'],
            ),
            IeltsQuestion(
              id: 'ed3_2',
              question: 'What skills do you think are most important for students today?',
              category: 'skills',
              sampleAnswers: [
                'Critical thinking and problem-solving skills are crucial in today\'s complex world.',
                'Digital literacy and adaptability are also essential as technology continues to evolve.',
              ],
              vocabulary: ['critical thinking', 'problem-solving', 'digital literacy', 'adaptability', 'evolving technology'],
            ),
            IeltsQuestion(
              id: 'ed3_3',
              question: 'Do you think traditional classroom learning will become obsolete?',
              category: 'future',
              sampleAnswers: [
                'I don\'t think traditional classrooms will disappear completely.',
                'However, they will likely evolve to incorporate more technology and flexible learning methods.',
              ],
              vocabulary: ['obsolete', 'evolve', 'incorporate', 'flexible learning', 'hybrid approaches'],
            ),
          ],
          tips: [
            'Consider both traditional and modern approaches',
            'Discuss the benefits and limitations of different methods',
            'Express balanced views on future developments',
          ],
        ),
      ],
    ),

    // ===== TRAVEL & CULTURE =====
    IeltsSpeakingTest(
      id: 'travel_001',
      title: 'Travel & Culture',
      description: 'Explore travel experiences, cultural differences, and global perspectives',
      difficulty: 'Medium',
      tags: ['travel', 'culture', 'tourism', 'global'],
      totalDuration: 15,
      createdAt: DateTime.now(),
      parts: [
        // Part 1: Introduction & General Discussion
        IeltsSpeakingPart(
          partNumber: 1,
          title: 'Travel Experiences',
          description: 'Discuss your travel experiences and cultural interests',
          instructions: 'Answer each question naturally. Speak for 2-3 sentences per answer.',
          preparationTime: 0,
          speakingTime: 4,
          questions: [
            IeltsQuestion(
              id: 'tr1_1',
              question: 'Do you enjoy traveling?',
              category: 'travel',
              sampleAnswers: [
                'Yes, I love traveling because it allows me to experience new cultures and meet interesting people.',
                'I find it exciting to explore different places and try new foods.',
              ],
              vocabulary: ['experience cultures', 'meet people', 'explore', 'try new foods', 'adventure'],
            ),
            IeltsQuestion(
              id: 'tr1_2',
              question: 'What\'s the most interesting place you\'ve visited?',
              category: 'travel',
              sampleAnswers: [
                'I found Japan fascinating because of its unique blend of traditional and modern culture.',
                'The food, architecture, and people\'s politeness really impressed me.',
              ],
              vocabulary: ['fascinating', 'unique blend', 'traditional', 'modern culture', 'architecture', 'politeness'],
            ),
            IeltsQuestion(
              id: 'tr1_3',
              question: 'How do you usually plan your trips?',
              category: 'travel',
              sampleAnswers: [
                'I usually research destinations online and read travel blogs for recommendations.',
                'I also like to plan some activities in advance but leave room for spontaneous discoveries.',
              ],
              vocabulary: ['research destinations', 'travel blogs', 'recommendations', 'spontaneous', 'discoveries'],
            ),
            IeltsQuestion(
              id: 'tr1_4',
              question: 'What do you think is the best way to learn about a new culture?',
              category: 'culture',
              sampleAnswers: [
                'I think immersing yourself in local life is the best way to understand a culture.',
                'This means trying local food, learning basic phrases, and interacting with local people.',
              ],
              vocabulary: ['immerse', 'local life', 'local food', 'basic phrases', 'interact', 'cultural understanding'],
            ),
          ],
          tips: [
            'Use specific examples from your travels',
            'Show cultural sensitivity and awareness',
            'Express genuine interest in different cultures',
          ],
        ),
        
        // Part 2: Cue Card - Travel Experience
        IeltsSpeakingPart(
          partNumber: 2,
          title: 'Describe a Memorable Trip',
          description: 'Talk about a specific travel experience that was meaningful to you',
          instructions: 'You have 1 minute to prepare. Then speak for 1-2 minutes.',
          preparationTime: 60,
          speakingTime: 2,
          questions: [
            IeltsQuestion(
              id: 'tr2_1',
              question: 'Describe a trip that was particularly memorable for you',
              category: 'travel',
              sampleAnswers: [
                'I\'d like to talk about my backpacking trip through Europe when I was 20.',
                'It was my first solo travel experience and taught me independence and cultural appreciation.',
              ],
              vocabulary: ['backpacking', 'solo travel', 'independence', 'cultural appreciation', 'adventure'],
            ),
          ],
          tips: [
            'Choose a trip that had a lasting impact on you',
            'Include sensory details and emotions',
            'Explain what made it memorable',
          ],
        ),
        
        // Part 3: Abstract Discussion
        IeltsSpeakingPart(
          partNumber: 3,
          title: 'Global Culture & Tourism',
          description: 'Discuss broader issues related to travel, tourism, and cultural exchange',
          instructions: 'Give detailed answers with examples. Express your opinions clearly.',
          preparationTime: 0,
          speakingTime: 5,
          questions: [
            IeltsQuestion(
              id: 'tr3_1',
              question: 'How has tourism changed in recent years?',
              category: 'tourism',
              sampleAnswers: [
                'Tourism has become more accessible with budget airlines and online booking platforms.',
                'There\'s also a growing trend towards sustainable and responsible tourism practices.',
              ],
              vocabulary: ['budget airlines', 'online booking', 'sustainable tourism', 'responsible tourism', 'accessibility'],
            ),
            IeltsQuestion(
              id: 'tr3_2',
              question: 'What are the positive and negative effects of mass tourism?',
              category: 'tourism',
              sampleAnswers: [
                'Mass tourism brings economic benefits to local communities and promotes cultural exchange.',
                'However, it can also lead to environmental damage and cultural commodification.',
              ],
              vocabulary: ['economic benefits', 'cultural exchange', 'environmental damage', 'cultural commodification', 'sustainability'],
            ),
            IeltsQuestion(
              id: 'tr3_3',
              question: 'Do you think globalization is making cultures more similar?',
              category: 'culture',
              sampleAnswers: [
                'I think there\'s some cultural convergence, especially in urban areas.',
                'However, many communities are actively preserving their unique traditions and identities.',
              ],
              vocabulary: ['cultural convergence', 'urban areas', 'preserve traditions', 'unique identities', 'cultural diversity'],
            ),
          ],
          tips: [
            'Consider both local and global perspectives',
            'Discuss the balance between preservation and change',
            'Use examples from different regions or countries',
          ],
        ),
      ],
    ),

    // ===== WORK & CAREER =====
    IeltsSpeakingTest(
      id: 'work_001',
      title: 'Work & Career',
      description: 'Discuss work experiences, career goals, and professional development',
      difficulty: 'Medium',
      tags: ['work', 'career', 'professional', 'business'],
      totalDuration: 15,
      createdAt: DateTime.now(),
      parts: [
        // Part 1: Introduction & General Discussion
        IeltsSpeakingPart(
          partNumber: 1,
          title: 'Your Work & Career',
          description: 'Discuss your work experience and career aspirations',
          instructions: 'Answer each question naturally. Speak for 2-3 sentences per answer.',
          preparationTime: 0,
          speakingTime: 4,
          questions: [
            IeltsQuestion(
              id: 'w1_1',
              question: 'What do you do for work?',
              category: 'work',
              sampleAnswers: [
                'I work as a software developer for a technology company.',
                'My role involves designing and developing applications for mobile devices.',
              ],
              vocabulary: ['software developer', 'technology company', 'design', 'develop', 'applications', 'mobile devices'],
            ),
            IeltsQuestion(
              id: 'w1_2',
              question: 'What do you like most about your job?',
              category: 'work',
              sampleAnswers: [
                'I enjoy the creative problem-solving aspect and the opportunity to learn new technologies.',
                'I also appreciate the collaborative environment and working with talented people.',
              ],
              vocabulary: ['creative problem-solving', 'learn new technologies', 'collaborative environment', 'talented people', 'innovation'],
            ),
            IeltsQuestion(
              id: 'w1_3',
              question: 'What skills are most important in your field?',
              category: 'skills',
              sampleAnswers: [
                'Technical skills are essential, but communication and teamwork are equally important.',
                'Adaptability and continuous learning are also crucial as technology evolves rapidly.',
              ],
              vocabulary: ['technical skills', 'communication', 'teamwork', 'adaptability', 'continuous learning', 'evolving technology'],
            ),
            IeltsQuestion(
              id: 'w1_4',
              question: 'Where do you see yourself in five years?',
              category: 'career',
              sampleAnswers: [
                'I hope to advance to a senior position and possibly lead a team of developers.',
                'I also want to specialize in artificial intelligence and machine learning.',
              ],
              vocabulary: ['advance', 'senior position', 'lead a team', 'specialize', 'artificial intelligence', 'machine learning'],
            ),
          ],
          tips: [
            'Be honest about your current situation and future goals',
            'Show enthusiasm for your field and continuous learning',
            'Connect your skills to your career aspirations',
          ],
        ),
        
        // Part 2: Cue Card - Work Experience
        IeltsSpeakingPart(
          partNumber: 2,
          title: 'Describe a Work Challenge',
          description: 'Talk about a challenging situation at work and how you handled it',
          instructions: 'You have 1 minute to prepare. Then speak for 1-2 minutes.',
          preparationTime: 60,
          speakingTime: 2,
          questions: [
            IeltsQuestion(
              id: 'w2_1',
              question: 'Describe a challenging situation you faced at work',
              category: 'work',
              sampleAnswers: [
                'I\'d like to talk about when I had to lead a project with a tight deadline.',
                'It was challenging because the team was new and we had limited resources.',
              ],
              vocabulary: ['lead a project', 'tight deadline', 'limited resources', 'team management', 'project coordination'],
            ),
          ],
          tips: [
            'Choose a challenge that shows your problem-solving skills',
            'Explain the situation, your actions, and the outcome',
            'Show what you learned from the experience',
          ],
        ),
        
        // Part 3: Abstract Discussion
        IeltsSpeakingPart(
          partNumber: 3,
          title: 'Work & Society',
          description: 'Discuss broader issues related to work, employment, and career development',
          instructions: 'Give detailed answers with examples. Express your opinions clearly.',
          preparationTime: 0,
          speakingTime: 5,
          questions: [
            IeltsQuestion(
              id: 'w3_1',
              question: 'How has the nature of work changed in recent years?',
              category: 'society',
              sampleAnswers: [
                'Work has become more flexible with remote working and flexible hours becoming common.',
                'There\'s also been a shift towards project-based work and greater emphasis on work-life balance.',
              ],
              vocabulary: ['flexible working', 'remote work', 'project-based', 'work-life balance', 'changing workplace'],
            ),
            IeltsQuestion(
              id: 'w3_2',
              question: 'What challenges do young people face when entering the job market?',
              category: 'employment',
              sampleAnswers: [
                'Young people often struggle with lack of experience and high competition for entry-level positions.',
                'They also face the challenge of adapting to rapidly changing job requirements and technologies.',
              ],
              vocabulary: ['lack of experience', 'high competition', 'entry-level positions', 'changing requirements', 'rapid adaptation'],
            ),
            IeltsQuestion(
              id: 'w3_3',
              question: 'Do you think job security is still important today?',
              category: 'employment',
              sampleAnswers: [
                'I think job security is still valued, but people are becoming more comfortable with career changes.',
                'The focus is shifting towards developing transferable skills and maintaining employability.',
              ],
              vocabulary: ['job security', 'career changes', 'transferable skills', 'employability', 'adaptability'],
            ),
          ],
          tips: [
            'Consider both individual and societal perspectives',
            'Discuss the balance between security and flexibility',
            'Use examples from different industries or countries',
          ],
        ),
      ],
    ),

    // ===== HEALTH & FITNESS =====
    IeltsSpeakingTest(
      id: 'health_001',
      title: 'Health & Fitness',
      description: 'Discuss healthy lifestyle, exercise habits, and wellness practices',
      difficulty: 'Easy',
      tags: ['health', 'fitness', 'wellness', 'lifestyle'],
      totalDuration: 15,
      createdAt: DateTime.now(),
      parts: [
        // Part 1: Introduction & General Discussion
        IeltsSpeakingPart(
          partNumber: 1,
          title: 'Your Health & Fitness',
          description: 'Discuss your health habits and fitness routine',
          instructions: 'Answer each question naturally. Speak for 2-3 sentences per answer.',
          preparationTime: 0,
          speakingTime: 4,
          questions: [
            IeltsQuestion(
              id: 'h1_1',
              question: 'How often do you exercise?',
              category: 'fitness',
              sampleAnswers: [
                'I try to exercise three to four times a week, usually in the mornings.',
                'I find that regular exercise helps me stay energized throughout the day.',
              ],
              vocabulary: ['exercise regularly', 'morning routine', 'stay energized', 'fitness schedule'],
            ),
            IeltsQuestion(
              id: 'h1_2',
              question: 'What type of exercise do you enjoy most?',
              category: 'fitness',
              sampleAnswers: [
                'I really enjoy swimming because it\'s a full-body workout and very relaxing.',
                'I also like hiking and cycling when the weather is nice.',
              ],
              vocabulary: ['full-body workout', 'relaxing', 'hiking', 'cycling', 'outdoor activities'],
            ),
            IeltsQuestion(
              id: 'h1_3',
              question: 'How do you maintain a healthy diet?',
              category: 'nutrition',
              sampleAnswers: [
                'I try to eat plenty of fruits and vegetables and limit processed foods.',
                'I also make sure to drink enough water and avoid excessive sugar.',
              ],
              vocabulary: ['balanced diet', 'fruits and vegetables', 'processed foods', 'hydration', 'sugar intake'],
            ),
            IeltsQuestion(
              id: 'h1_4',
              question: 'What do you do to relax and reduce stress?',
              category: 'wellness',
              sampleAnswers: [
                'I practice meditation and deep breathing exercises when I feel stressed.',
                'I also enjoy reading and spending time with friends to unwind.',
              ],
              vocabulary: ['meditation', 'deep breathing', 'stress relief', 'unwind', 'relaxation techniques'],
            ),
          ],
          tips: [
            'Be honest about your current habits',
            'Show awareness of health and wellness',
            'Connect exercise to mental and physical benefits',
          ],
        ),
        
        // Part 2: Cue Card - Health Experience
        IeltsSpeakingPart(
          partNumber: 2,
          title: 'Describe a Health Goal',
          description: 'Talk about a health or fitness goal you\'ve set for yourself',
          instructions: 'You have 1 minute to prepare. Then speak for 1-2 minutes.',
          preparationTime: 60,
          speakingTime: 2,
          questions: [
            IeltsQuestion(
              id: 'h2_1',
              question: 'Describe a health or fitness goal you\'ve set for yourself',
              category: 'health',
              sampleAnswers: [
                'I\'d like to talk about my goal to run a half marathon this year.',
                'It\'s challenging but I\'m gradually building up my endurance through training.',
              ],
              vocabulary: ['half marathon', 'endurance', 'training program', 'personal challenge', 'fitness goal'],
            ),
          ],
          tips: [
            'Choose a realistic and meaningful goal',
            'Explain your motivation and progress',
            'Discuss challenges and how you overcome them',
          ],
        ),
        
        // Part 3: Abstract Discussion
        IeltsSpeakingPart(
          partNumber: 3,
          title: 'Health & Modern Life',
          description: 'Discuss broader health issues in contemporary society',
          instructions: 'Give detailed answers with examples. Express your opinions clearly.',
          preparationTime: 0,
          speakingTime: 5,
          questions: [
            IeltsQuestion(
              id: 'h3_1',
              question: 'How has modern lifestyle affected people\'s health?',
              category: 'society',
              sampleAnswers: [
                'Modern lifestyle has led to more sedentary behavior due to desk jobs and technology use.',
                'However, it has also made health information and fitness tracking more accessible.',
              ],
              vocabulary: ['sedentary lifestyle', 'desk jobs', 'technology use', 'health information', 'fitness tracking'],
            ),
            IeltsQuestion(
              id: 'h3_2',
              question: 'What role should governments play in promoting public health?',
              category: 'politics',
              sampleAnswers: [
                'Governments should invest in public health infrastructure and promote healthy living campaigns.',
                'They should also regulate unhealthy products and provide incentives for healthy choices.',
              ],
              vocabulary: ['public health infrastructure', 'health campaigns', 'regulate', 'incentives', 'healthy choices'],
            ),
            IeltsQuestion(
              id: 'h3_3',
              question: 'Do you think mental health is as important as physical health?',
              category: 'wellness',
              sampleAnswers: [
                'Yes, I believe mental and physical health are equally important and interconnected.',
                'Good mental health affects our physical well-being and overall quality of life.',
              ],
              vocabulary: ['mental health', 'physical health', 'interconnected', 'well-being', 'quality of life'],
            ),
          ],
          tips: [
            'Consider both individual and societal perspectives',
            'Discuss the relationship between mental and physical health',
            'Use examples from current health trends',
          ],
        ),
      ],
    ),
  ];

  // Получить все расширенные тесты
  static List<IeltsSpeakingTest> getAllExtendedTests() {
    return additionalTests;
  }

  // Получить тесты по сложности
  static List<IeltsSpeakingTest> getExtendedTestsByDifficulty(String difficulty) {
    return additionalTests.where((test) => test.difficulty == difficulty).toList();
  }

  // Получить тесты по тегам
  static List<IeltsSpeakingTest> getExtendedTestsByTags(List<String> tags) {
    return additionalTests.where((test) => 
      test.tags.any((tag) => tags.contains(tag))
    ).toList();
  }
}
