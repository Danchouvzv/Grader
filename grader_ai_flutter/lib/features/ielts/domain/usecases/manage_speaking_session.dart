import 'dart:math';
import '../entities/ielts_speaking_part.dart';
import '../entities/ielts_result.dart';

abstract class ManageSpeakingSession {
  IeltsSpeakingSession createNewSession();
  IeltsSpeakingSession? getCurrentSession();
  void clearCurrentSession();
  IeltsSpeakingSession moveToNextPart(IeltsSpeakingSession session);
  IeltsSpeakingSession completeCurrentPart(IeltsSpeakingSession session, IeltsResult result);
  IeltsSpeakingSession completeSession(IeltsSpeakingSession session);
  IeltsSpeakingSession changeCurrentPartTopic(IeltsSpeakingSession session);
}

class ManageSpeakingSessionImpl implements ManageSpeakingSession {
  // Singleton pattern to preserve session state across navigation
  static final ManageSpeakingSessionImpl _instance = ManageSpeakingSessionImpl._internal();
  factory ManageSpeakingSessionImpl() => _instance;
  ManageSpeakingSessionImpl._internal();

  // Current active session (persists across page rebuilds)
  IeltsSpeakingSession? _currentSession;

  @override
  IeltsSpeakingSession? getCurrentSession() => _currentSession;

  @override
  void clearCurrentSession() {
    _currentSession = null;
  }

  @override
  IeltsSpeakingSession createNewSession() {
    // Return existing session if available, otherwise create new
    if (_currentSession != null) {
      return _currentSession!;
    }
    // Expanded pool with 20+ topics for better variety
    final List<IeltsSpeakingPart> part1Pool = [
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about your daily routine.',
        points: [
          'What is a typical day like for you?',
          'Which part of the day do you enjoy most?',
          'Do you prefer to have a fixed schedule or be flexible?',
          'Has your routine changed recently? Why?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about reading.',
        points: [
          'Do you enjoy reading? Why/why not?',
          'What kinds of books do you prefer?',
          'Do you read e-books or paper books?',
          'How has your reading habit changed over time?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about food and cooking.',
        points: [
          'Do you like cooking? Why?',
          'What\'s your favorite dish?',
          'Do you prefer eating at home or in restaurants?',
          'Is healthy eating important to you?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about your hometown.',
        points: [
          'Where is your hometown and what is it like?',
          'What do you like most about it?',
          'Are there any changes you would like to see?',
          'Would you like to live there in the future?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about technology in your life.',
        points: [
          'Which technology do you use most?',
          'How does technology help you study or work?',
          'Are there any disadvantages to relying on technology?',
          'What technology would you like to learn next?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about sports and fitness.',
        points: [
          'Do you play any sports?',
          'How often do you exercise?',
          'What are the benefits of staying fit?',
          'Do you prefer team sports or individual sports?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about music.',
        points: [
          'What kind of music do you like?',
          'Do you prefer live concerts or listening at home?',
          'Has your taste in music changed?',
          'Do you play any instruments?'
        ],
        timeLimit: 'You have 1-2 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about travel.',
        points: [
          'Do you like traveling? Why?',
          'What\'s your favorite type of destination?',
          'Do you prefer to travel alone or with others?',
          'What\'s your most memorable trip?'
        ],
        timeLimit: 'You have 2-3 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about studying and work.',
        points: [
          'What do you study or do for work?',
          'Why did you choose this field?',
          'What skills are important for your role?',
          'Do you plan to change your career path?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about friends and socializing.',
        points: [
          'Do you have a large or small circle of friends?',
          'How do you usually spend time together?',
          'Do you prefer meeting in person or online?',
          'What makes a good friend in your opinion?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      // NEW TOPICS
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about shopping.',
        points: [
          'Do you enjoy shopping? Why or why not?',
          'Do you prefer shopping online or in stores?',
          'What do you usually buy when you shop?',
          'How has shopping changed in recent years?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about weather and seasons.',
        points: [
          'What\'s your favorite season? Why?',
          'How does weather affect your mood?',
          'Do you prefer hot or cold weather?',
          'How do you adapt to different seasons?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about movies and entertainment.',
        points: [
          'What type of movies do you enjoy?',
          'Do you prefer watching movies at home or in cinemas?',
          'How often do you watch movies?',
          'What\'s the best movie you\'ve seen recently?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about languages.',
        points: [
          'How many languages do you speak?',
          'Which language do you find most difficult to learn?',
          'Why are you learning English?',
          'Do you think it\'s important to learn multiple languages?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about hobbies and free time.',
        points: [
          'What do you like to do in your free time?',
          'How do you usually spend weekends?',
          'Do you have any unusual hobbies?',
          'How important is it to have hobbies?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about family.',
        points: [
          'Tell me about your family.',
          'Do you spend much time with your family?',
          'Who in your family are you closest to?',
          'How important is family to you?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about pets and animals.',
        points: [
          'Do you have any pets?',
          'What\'s your favorite animal? Why?',
          'Do you think people should have pets?',
          'Have you ever had a pet?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about fashion and clothing.',
        points: [
          'Do you follow fashion trends?',
          'What type of clothes do you prefer?',
          'How important is fashion to you?',
          'Do you prefer casual or formal clothing?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about health and lifestyle.',
        points: [
          'How do you stay healthy?',
          'Do you have any health concerns?',
          'What do you do to relax?',
          'How important is a healthy lifestyle?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about dreams and goals.',
        points: [
          'What are your future goals?',
          'Do you have any dreams you want to achieve?',
          'How do you plan to achieve your goals?',
          'What\'s most important to you in life?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
    ];

    final List<IeltsSpeakingPart> part2Pool = [
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a place you would like to visit.',
        points: ['Where this place is', 'Why you want to visit it', 'What you would do there', 'Why it appeals to you'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a book that left a strong impression on you.',
        points: ['What the book is', 'What it is about', 'Why it impressed you', 'What you learned from it'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a person you admire.',
        points: ['Who the person is', 'How you know them', 'What they are like', 'Why you admire them'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a skill you want to learn.',
        points: ['What the skill is', 'Why you want to learn it', 'How you plan to learn it', 'What benefits it could bring'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a time you helped someone.',
        points: ['Who you helped', 'How you helped them', 'Why they needed help', 'How you felt about it'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe an important decision you made.',
        points: ['What the decision was', 'When and where you made it', 'Why it was important', 'How it affected your life'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a memorable journey.',
        points: ['Where you went', 'Who you went with', 'What happened', 'Why it was memorable'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a time you helped someone.',
        points: ['Who you helped', 'How you helped them', 'Why they needed help', 'How you felt about it'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a useful app or website you often use.',
        points: ['What it is', 'What it does', 'Why you use it often', 'What could be improved'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a hobby you enjoy.',
        points: ['What it is', 'How you started', 'Why you enjoy it', 'How it benefits you'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a historical event you find fascinating.',
        points: ['What happened', 'Why it is important', 'How you learned about it', 'What you think about it'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a difficult challenge you faced.',
        points: ['What the challenge was', 'How you handled it', 'What the result was', 'What you learned'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe your favorite season of the year.',
        points: ['Which season it is', 'Why you like it', 'What you do in that season', 'Any special memories'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a teacher who influenced you.',
        points: ['Who they are', 'What they taught you', 'How they influenced you', 'Why you remember them'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a time you tried something new.',
        points: ['What you tried', 'Why you tried it', 'How you felt', 'What the outcome was'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe an item you can\'t live without.',
        points: ['What it is', 'Why it\'s important', 'How you use it', 'How life would be without it'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      // NEW PART 2 TOPICS
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a memorable celebration.',
        points: ['What was being celebrated', 'Who was there', 'What happened', 'Why it was memorable'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a piece of technology you use daily.',
        points: ['What it is', 'How you use it', 'Why it\'s useful', 'How it has changed your life'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a childhood memory.',
        points: ['What happened', 'When it was', 'Who was involved', 'Why you remember it'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a gift you received.',
        points: ['What the gift was', 'Who gave it to you', 'When you received it', 'Why it was special'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a restaurant you enjoy.',
        points: ['Where it is', 'What type of food it serves', 'Why you like it', 'When you usually go there'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a time you learned something new.',
        points: ['What you learned', 'How you learned it', 'Why you wanted to learn it', 'How it has helped you'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a place where you feel relaxed.',
        points: ['Where it is', 'What it looks like', 'Why you feel relaxed there', 'When you usually go there'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a time you had to be patient.',
        points: ['What the situation was', 'Why you had to be patient', 'How you felt', 'What the outcome was'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a piece of art you like.',
        points: ['What it is', 'Where you saw it', 'What it looks like', 'Why you like it'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a time you were proud of yourself.',
        points: ['What you achieved', 'Why it was important', 'How you felt', 'What you learned'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a place you would like to live.',
        points: ['Where it is', 'What it\'s like', 'Why you want to live there', 'What you would do there'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a time you had to work in a team.',
        points: ['What the task was', 'Who was in your team', 'What your role was', 'How it went'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a tradition in your culture.',
        points: ['What the tradition is', 'When it happens', 'What people do', 'Why it\'s important'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a time you had to make a difficult choice.',
        points: ['What the choice was', 'What the options were', 'How you decided', 'What the result was'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a place you visited that was different from your expectations.',
        points: ['Where it was', 'What you expected', 'What it was actually like', 'How you felt about the difference'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
    ];

    final List<IeltsSpeakingPart> part3Pool = [
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the impact of technology on society.',
        points: ['Benefits vs drawbacks of technology', 'Digital divide and accessibility', 'Future trends', 'Regulation and ethics'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss education and learning methods.',
        points: ['Online vs traditional learning', 'Standardized tests', 'Lifelong learning', 'Teacher\'s role in modern education'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the environment and sustainability.',
        points: ['Individual vs government responsibility', 'Renewable energy', 'Waste reduction', 'Climate change awareness'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss work and career.',
        points: ['Work-life balance', 'Remote work', 'Automation and jobs', 'Choosing a career path'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss culture and globalization.',
        points: ['Cultural identity', 'Benefits of globalization', 'Cultural preservation', 'Language and culture'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss public health and lifestyle.',
        points: ['Healthy habits', 'Government campaigns', 'Mental health awareness', 'Urban lifestyle challenges'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss media and communication.',
        points: ['Social media influence', 'Fake news and trust', 'Freedom of speech', 'Privacy concerns'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss travel and tourism.',
        points: ['Sustainable tourism', 'Local communities', 'Overtourism', 'Cultural exchange'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss cities and urban development.',
        points: ['Public transport', 'Green spaces', 'Smart cities', 'Affordable housing'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss ethics and modern society.',
        points: ['Data privacy', 'AI decision-making', 'Consumerism and values', 'Corporate responsibility'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss art and creativity.',
        points: ['Art in education', 'Funding for the arts', 'Role of creativity at work', 'Digital art vs traditional'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss consumer behavior.',
        points: ['Advertising influence', 'Sustainable consumption', 'Online shopping', 'Brand loyalty'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      // NEW PART 3 TOPICS
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the future of work.',
        points: ['Remote work trends', 'AI and automation', 'Skills for the future', 'Work-life balance'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss social media and relationships.',
        points: ['Impact on communication', 'Privacy concerns', 'Mental health effects', 'Building real connections'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss aging and society.',
        points: ['Population aging', 'Healthcare for elderly', 'Intergenerational relationships', 'Retirement planning'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss innovation and creativity.',
        points: ['Sources of innovation', 'Creativity in education', 'Supporting creative industries', 'Innovation vs tradition'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss food and nutrition.',
        points: ['Global food security', 'Healthy eating habits', 'Food waste reduction', 'Sustainable agriculture'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss transportation and mobility.',
        points: ['Public transport systems', 'Electric vehicles', 'Urban planning', 'Sustainable transport'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss mental health awareness.',
        points: ['Stigma reduction', 'Access to mental health services', 'Workplace mental health', 'Community support'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss space exploration.',
        points: ['Benefits of space research', 'Commercial space travel', 'International cooperation', 'Future possibilities'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the role of government.',
        points: ['Public services', 'Regulation and freedom', 'Transparency and accountability', 'Citizen participation'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the future of education.',
        points: ['Personalized learning', 'Technology in classrooms', 'Lifelong learning', 'Skills vs knowledge'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss social inequality.',
        points: ['Causes of inequality', 'Government policies', 'Education and opportunity', 'Social mobility'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the importance of sleep.',
        points: ['Sleep and health', 'Work schedules and sleep', 'Technology and sleep quality', 'Sleep education'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the role of sports in society.',
        points: ['Health benefits', 'Social cohesion', 'Economic impact', 'Youth development'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the future of cities.',
        points: ['Smart city technology', 'Sustainable urban living', 'Community spaces', 'Urban challenges'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the value of time.',
        points: ['Time management', 'Work-life balance', 'Leisure time', 'Time and technology'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the importance of reading.',
        points: ['Reading habits', 'Digital vs physical books', 'Reading and education', 'Reading for pleasure'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
    ];

    final random = Random();
    final selectedPart1 = part1Pool[random.nextInt(part1Pool.length)];
    final selectedPart2 = part2Pool[random.nextInt(part2Pool.length)];
    final selectedPart3 = part3Pool[random.nextInt(part3Pool.length)];

    _currentSession = IeltsSpeakingSession(parts: [selectedPart1, selectedPart2, selectedPart3]);
    return _currentSession!;
  }

  @override
  IeltsSpeakingSession moveToNextPart(IeltsSpeakingSession session) {
    if (!session.canMoveToNextPart) return session;
    
    _currentSession = session.copyWith(
      currentPartIndex: session.currentPartIndex + 1,
    );
    return _currentSession!;
  }

  @override
  IeltsSpeakingSession completeCurrentPart(IeltsSpeakingSession session, IeltsResult result) {
    final updatedParts = List<IeltsSpeakingPart>.from(session.parts);
    updatedParts[session.currentPartIndex] = updatedParts[session.currentPartIndex].copyWith(
      isCompleted: true,
      result: result,
    );

    _currentSession = session.copyWith(
      parts: updatedParts,
      overallBand: session.calculateOverallBand(),
    );
    return _currentSession!;
  }

  @override
  IeltsSpeakingSession completeSession(IeltsSpeakingSession session) {
    if (!session.canCompleteSession) return session;
    
    _currentSession = session.copyWith(
      isCompleted: true,
      overallBand: session.calculateOverallBand(),
    );
    // Session completed, clear it so next time starts fresh
    _currentSession = null;
    return session.copyWith(
      isCompleted: true,
      overallBand: session.calculateOverallBand(),
    );
  }

  @override
  IeltsSpeakingSession changeCurrentPartTopic(IeltsSpeakingSession session) {
    final currentPart = session.currentPart;
    final random = Random();
    
    IeltsSpeakingPart newPart;
    
    // Select new topic based on current part type
    switch (currentPart.type) {
      case IeltsSpeakingPartType.part1:
        final part1Pool = _getPart1Pool();
        newPart = part1Pool[random.nextInt(part1Pool.length)];
        break;
      case IeltsSpeakingPartType.part2:
        final part2Pool = _getPart2Pool();
        newPart = part2Pool[random.nextInt(part2Pool.length)];
        break;
      case IeltsSpeakingPartType.part3:
        final part3Pool = _getPart3Pool();
        newPart = part3Pool[random.nextInt(part3Pool.length)];
        break;
    }
    
    // Update the current part with new topic
    final updatedParts = List<IeltsSpeakingPart>.from(session.parts);
    updatedParts[session.currentPartIndex] = newPart;
    
    _currentSession = session.copyWith(parts: updatedParts);
    return _currentSession!;
  }

  // Helper methods to get topic pools
  List<IeltsSpeakingPart> _getPart1Pool() {
    return [
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about your daily routine.',
        points: [
          'What is a typical day like for you?',
          'Which part of the day do you enjoy most?',
          'Do you prefer to have a fixed schedule or be flexible?',
          'Has your routine changed recently? Why?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about reading.',
        points: [
          'Do you enjoy reading? Why/why not?',
          'What kinds of books do you prefer?',
          'Do you read e-books or paper books?',
          'How has your reading habit changed over time?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about food and cooking.',
        points: [
          'Do you like cooking? Why?',
          'What\'s your favorite dish?',
          'Do you prefer eating at home or in restaurants?',
          'Is healthy eating important to you?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about your hometown.',
        points: [
          'Where is your hometown and what is it like?',
          'What do you like most about it?',
          'Are there any changes you would like to see?',
          'Would you like to live there in the future?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about technology in your life.',
        points: [
          'Which technology do you use most?',
          'How does technology help you study or work?',
          'Are there any disadvantages to relying on technology?',
          'What technology would you like to learn next?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about sports and fitness.',
        points: [
          'Do you play any sports?',
          'How often do you exercise?',
          'What are the benefits of staying fit?',
          'Do you prefer team sports or individual sports?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about music.',
        points: [
          'What kind of music do you like?',
          'Do you prefer live concerts or listening at home?',
          'Has your taste in music changed?',
          'Do you play any instruments?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about travel.',
        points: [
          'Do you like traveling? Why?',
          'What\'s your favorite type of destination?',
          'Do you prefer to travel alone or with others?',
          'What\'s your most memorable trip?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about studying and work.',
        points: [
          'What do you study or do for work?',
          'Why did you choose this field?',
          'What skills are important for your role?',
          'Do you plan to change your career path?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about friends and socializing.',
        points: [
          'Do you have a large or small circle of friends?',
          'How do you usually spend time together?',
          'Do you prefer meeting in person or online?',
          'What makes a good friend in your opinion?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about shopping.',
        points: [
          'Do you enjoy shopping? Why or why not?',
          'Do you prefer shopping online or in stores?',
          'What do you usually buy when you shop?',
          'How has shopping changed in recent years?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about weather and seasons.',
        points: [
          'What\'s your favorite season? Why?',
          'How does weather affect your mood?',
          'Do you prefer hot or cold weather?',
          'How do you adapt to different seasons?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about movies and entertainment.',
        points: [
          'What type of movies do you enjoy?',
          'Do you prefer watching movies at home or in cinemas?',
          'How often do you watch movies?',
          'What\'s the best movie you\'ve seen recently?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about languages.',
        points: [
          'How many languages do you speak?',
          'Which language do you find most difficult to learn?',
          'Why are you learning English?',
          'Do you think it\'s important to learn multiple languages?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about hobbies and free time.',
        points: [
          'What do you like to do in your free time?',
          'How do you usually spend weekends?',
          'Do you have any unusual hobbies?',
          'How important is it to have hobbies?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about family.',
        points: [
          'Tell me about your family.',
          'Do you spend much time with your family?',
          'Who in your family are you closest to?',
          'How important is family to you?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about pets and animals.',
        points: [
          'Do you have any pets?',
          'What\'s your favorite animal? Why?',
          'Do you think people should have pets?',
          'Have you ever had a pet?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about fashion and clothing.',
        points: [
          'Do you follow fashion trends?',
          'What type of clothes do you prefer?',
          'How important is fashion to you?',
          'Do you prefer casual or formal clothing?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about health and lifestyle.',
        points: [
          'How do you stay healthy?',
          'Do you have any health concerns?',
          'What do you do to relax?',
          'How important is a healthy lifestyle?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Let\'s talk about dreams and goals.',
        points: [
          'What are your future goals?',
          'Do you have any dreams you want to achieve?',
          'How do you plan to achieve your goals?',
          'What\'s most important to you in life?'
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
    ];
  }

  List<IeltsSpeakingPart> _getPart2Pool() {
    return [
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a place you would like to visit.',
        points: ['Where this place is', 'Why you want to visit it', 'What you would do there', 'Why it appeals to you'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a book that left a strong impression on you.',
        points: ['What the book is', 'What it is about', 'Why it impressed you', 'What you learned from it'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a person you admire.',
        points: ['Who the person is', 'How you know them', 'What they are like', 'Why you admire them'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a skill you want to learn.',
        points: ['What the skill is', 'Why you want to learn it', 'How you plan to learn it', 'What benefits it could bring'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a time you helped someone.',
        points: ['Who you helped', 'How you helped them', 'Why they needed help', 'How you felt about it'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe an important decision you made.',
        points: ['What the decision was', 'When and where you made it', 'Why it was important', 'How it affected your life'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a memorable journey.',
        points: ['Where you went', 'Who you went with', 'What happened', 'Why it was memorable'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a useful app or website you often use.',
        points: ['What it is', 'What it does', 'Why you use it often', 'What could be improved'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a hobby you enjoy.',
        points: ['What it is', 'How you started', 'Why you enjoy it', 'How it benefits you'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a historical event you find fascinating.',
        points: ['What happened', 'Why it is important', 'How you learned about it', 'What you think about it'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a difficult challenge you faced.',
        points: ['What the challenge was', 'How you handled it', 'What the result was', 'What you learned'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe your favorite season of the year.',
        points: ['Which season it is', 'Why you like it', 'What you do in that season', 'Any special memories'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a teacher who influenced you.',
        points: ['Who they are', 'What they taught you', 'How they influenced you', 'Why you remember them'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a time you tried something new.',
        points: ['What you tried', 'Why you tried it', 'How you felt', 'What the outcome was'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe an item you can\'t live without.',
        points: ['What it is', 'Why it\'s important', 'How you use it', 'How life would be without it'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a memorable celebration.',
        points: ['What was being celebrated', 'Who was there', 'What happened', 'Why it was memorable'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a piece of technology you use daily.',
        points: ['What it is', 'How you use it', 'Why it\'s useful', 'How it has changed your life'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a childhood memory.',
        points: ['What happened', 'When it was', 'Who was involved', 'Why you remember it'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a gift you received.',
        points: ['What the gift was', 'Who gave it to you', 'When you received it', 'Why it was special'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a restaurant you enjoy.',
        points: ['Where it is', 'What type of food it serves', 'Why you like it', 'When you usually go there'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a time you learned something new.',
        points: ['What you learned', 'How you learned it', 'Why you wanted to learn it', 'How it has helped you'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a place where you feel relaxed.',
        points: ['Where it is', 'What it looks like', 'Why you feel relaxed there', 'When you usually go there'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a time you had to be patient.',
        points: ['What the situation was', 'Why you had to be patient', 'How you felt', 'What the outcome was'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a piece of art you like.',
        points: ['What it is', 'Where you saw it', 'What it looks like', 'Why you like it'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a time you were proud of yourself.',
        points: ['What you achieved', 'Why it was important', 'How you felt', 'What you learned'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a place you would like to live.',
        points: ['Where it is', 'What it\'s like', 'Why you want to live there', 'What you would do there'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a time you had to work in a team.',
        points: ['What the task was', 'Who was in your team', 'What your role was', 'How it went'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a tradition in your culture.',
        points: ['What the tradition is', 'When it happens', 'What people do', 'Why it\'s important'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a time you had to make a difficult choice.',
        points: ['What the choice was', 'What the options were', 'How you decided', 'What the result was'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a place you visited that was different from your expectations.',
        points: ['Where it was', 'What you expected', 'What it was actually like', 'How you felt about the difference'],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
    ];
  }

  List<IeltsSpeakingPart> _getPart3Pool() {
    return [
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the impact of technology on society.',
        points: ['Benefits vs drawbacks of technology', 'Digital divide and accessibility', 'Future trends', 'Regulation and ethics'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss education and learning methods.',
        points: ['Online vs traditional learning', 'Standardized tests', 'Lifelong learning', 'Teacher\'s role in modern education'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the environment and sustainability.',
        points: ['Individual vs government responsibility', 'Renewable energy', 'Waste reduction', 'Climate change awareness'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss work and career.',
        points: ['Work-life balance', 'Remote work', 'Automation and jobs', 'Choosing a career path'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss culture and globalization.',
        points: ['Cultural identity', 'Benefits of globalization', 'Cultural preservation', 'Language and culture'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss public health and lifestyle.',
        points: ['Healthy habits', 'Government campaigns', 'Mental health awareness', 'Urban lifestyle challenges'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss media and communication.',
        points: ['Social media influence', 'Fake news and trust', 'Freedom of speech', 'Privacy concerns'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss travel and tourism.',
        points: ['Sustainable tourism', 'Local communities', 'Overtourism', 'Cultural exchange'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss cities and urban development.',
        points: ['Public transport', 'Green spaces', 'Smart cities', 'Affordable housing'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss ethics and modern society.',
        points: ['Data privacy', 'AI decision-making', 'Consumerism and values', 'Corporate responsibility'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss art and creativity.',
        points: ['Art in education', 'Funding for the arts', 'Role of creativity at work', 'Digital art vs traditional'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss consumer behavior.',
        points: ['Advertising influence', 'Sustainable consumption', 'Online shopping', 'Brand loyalty'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the future of work.',
        points: ['Remote work trends', 'AI and automation', 'Skills for the future', 'Work-life balance'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss social media and relationships.',
        points: ['Impact on communication', 'Privacy concerns', 'Mental health effects', 'Building real connections'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss aging and society.',
        points: ['Population aging', 'Healthcare for elderly', 'Intergenerational relationships', 'Retirement planning'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss innovation and creativity.',
        points: ['Sources of innovation', 'Creativity in education', 'Supporting creative industries', 'Innovation vs tradition'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss food and nutrition.',
        points: ['Global food security', 'Healthy eating habits', 'Food waste reduction', 'Sustainable agriculture'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss transportation and mobility.',
        points: ['Public transport systems', 'Electric vehicles', 'Urban planning', 'Sustainable transport'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss mental health awareness.',
        points: ['Stigma reduction', 'Access to mental health services', 'Workplace mental health', 'Community support'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss space exploration.',
        points: ['Benefits of space research', 'Commercial space travel', 'International cooperation', 'Future possibilities'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the role of government.',
        points: ['Public services', 'Regulation and freedom', 'Transparency and accountability', 'Citizen participation'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the future of education.',
        points: ['Personalized learning', 'Technology in classrooms', 'Lifelong learning', 'Skills vs knowledge'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss social inequality.',
        points: ['Causes of inequality', 'Government policies', 'Education and opportunity', 'Social mobility'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the importance of sleep.',
        points: ['Sleep and health', 'Work schedules and sleep', 'Technology and sleep quality', 'Sleep education'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the role of sports in society.',
        points: ['Health benefits', 'Social cohesion', 'Economic impact', 'Youth development'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the future of cities.',
        points: ['Smart city technology', 'Sustainable urban living', 'Community spaces', 'Urban challenges'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the value of time.',
        points: ['Time management', 'Work-life balance', 'Leisure time', 'Time and technology'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s discuss the importance of reading.',
        points: ['Reading habits', 'Digital vs physical books', 'Reading and education', 'Reading for pleasure'],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
    ];
  }
}
