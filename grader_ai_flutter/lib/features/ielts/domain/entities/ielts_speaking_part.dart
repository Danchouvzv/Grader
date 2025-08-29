import 'ielts_result.dart';

enum IeltsSpeakingPartType {
  part1('Part 1', 'Introduction & Interview', '4-5 minutes'),
  part2('Part 2', 'Individual Long Turn', '1-2 minutes'),
  part3('Part 3', 'Two-Way Discussion', '4-5 minutes');

  const IeltsSpeakingPartType(this.title, this.subtitle, this.duration);
  
  final String title;
  final String subtitle;
  final String duration;
}

class IeltsSpeakingPart {
  final IeltsSpeakingPartType type;
  final String topic;
  final List<String> points;
  final String timeLimit;
  final bool isCompleted;
  final IeltsResult? result;

  const IeltsSpeakingPart({
    required this.type,
    required this.topic,
    required this.points,
    required this.timeLimit,
    this.isCompleted = false,
    this.result,
  });

  IeltsSpeakingPart copyWith({
    IeltsSpeakingPartType? type,
    String? topic,
    List<String>? points,
    String? timeLimit,
    bool? isCompleted,
    IeltsResult? result,
  }) {
    return IeltsSpeakingPart(
      type: type ?? this.type,
      topic: topic ?? this.topic,
      points: points ?? this.points,
      timeLimit: timeLimit ?? this.timeLimit,
      isCompleted: isCompleted ?? this.isCompleted,
      result: result ?? this.result,
    );
  }
}

class IeltsSpeakingSession {
  final List<IeltsSpeakingPart> parts;
  final int currentPartIndex;
  final bool isCompleted;
  final double? overallBand;

  const IeltsSpeakingSession({
    required this.parts,
    this.currentPartIndex = 0,
    this.isCompleted = false,
    this.overallBand,
  });

  IeltsSpeakingPart get currentPart => parts[currentPartIndex];
  
  bool get canMoveToNextPart => 
      currentPartIndex < parts.length - 1 && 
      currentPart.isCompleted;
  
  bool get canCompleteSession => 
      parts.every((part) => part.isCompleted);

  IeltsSpeakingSession copyWith({
    List<IeltsSpeakingPart>? parts,
    int? currentPartIndex,
    bool? isCompleted,
    double? overallBand,
  }) {
    return IeltsSpeakingSession(
      parts: parts ?? this.parts,
      currentPartIndex: currentPartIndex ?? this.currentPartIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      overallBand: overallBand ?? this.overallBand,
    );
  }

  double calculateOverallBand() {
    if (!canCompleteSession) return 0.0;
    
    final completedParts = parts.where((part) => part.result != null).toList();
    if (completedParts.isEmpty) return 0.0;
    
    double totalBand = 0.0;
    for (final part in completedParts) {
      totalBand += part.result!.overallBand;
    }
    
    return totalBand / completedParts.length;
  }
}
