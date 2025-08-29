import '../entities/ielts_speaking_part.dart';
import '../entities/ielts_result.dart';

abstract class ManageSpeakingSession {
  IeltsSpeakingSession createNewSession();
  IeltsSpeakingSession moveToNextPart(IeltsSpeakingSession session);
  IeltsSpeakingSession completeCurrentPart(IeltsSpeakingSession session, IeltsResult result);
  IeltsSpeakingSession completeSession(IeltsSpeakingSession session);
}

class ManageSpeakingSessionImpl implements ManageSpeakingSession {
  @override
  IeltsSpeakingSession createNewSession() {
    final parts = [
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part1,
        topic: 'Tell me about your hometown.',
        points: [
          'Where is your hometown?',
          'What is it like?',
          'What do you like most about it?',
          'Would you like to live there in the future?',
        ],
        timeLimit: 'You have 4-5 minutes to answer these questions',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part2,
        topic: 'Describe a place you would like to visit.',
        points: [
          'Where this place is',
          'Why you want to visit it',
          'What you would do there',
          'How you think this place has changed',
        ],
        timeLimit: 'You have 1-2 minutes to speak',
      ),
      IeltsSpeakingPart(
        type: IeltsSpeakingPartType.part3,
        topic: 'Let\'s talk about travel and tourism.',
        points: [
          'What are the benefits of traveling?',
          'How has tourism changed in recent years?',
          'What impact does tourism have on local communities?',
          'Do you think people travel too much these days?',
        ],
        timeLimit: 'You have 4-5 minutes for this discussion',
      ),
    ];

    return IeltsSpeakingSession(parts: parts);
  }

  @override
  IeltsSpeakingSession moveToNextPart(IeltsSpeakingSession session) {
    if (!session.canMoveToNextPart) return session;
    
    return session.copyWith(
      currentPartIndex: session.currentPartIndex + 1,
    );
  }

  @override
  IeltsSpeakingSession completeCurrentPart(IeltsSpeakingSession session, IeltsResult result) {
    final updatedParts = List<IeltsSpeakingPart>.from(session.parts);
    updatedParts[session.currentPartIndex] = updatedParts[session.currentPartIndex].copyWith(
      isCompleted: true,
      result: result,
    );

    return session.copyWith(
      parts: updatedParts,
      overallBand: session.calculateOverallBand(),
    );
  }

  @override
  IeltsSpeakingSession completeSession(IeltsSpeakingSession session) {
    if (!session.canCompleteSession) return session;
    
    return session.copyWith(
      isCompleted: true,
      overallBand: session.calculateOverallBand(),
    );
  }
}
