import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'career_event.dart';
part 'career_state.dart';

class CareerBloc extends Bloc<CareerEvent, CareerState> {
  CareerBloc(
    this._getAssessmentQuestions,
    this._getCareerGuidance,
    this._saveCareerSession,
    this._loadCareerSession,
    this._getAvailableSessions,
    this._deleteCareerSession,
  ) : super(CareerInitial()) {
    // Event handlers will be implemented later
  }

  final dynamic _getAssessmentQuestions;
  final dynamic _getCareerGuidance;
  final dynamic _saveCareerSession;
  final dynamic _loadCareerSession;
  final dynamic _getAvailableSessions;
  final dynamic _deleteCareerSession;
}

// Placeholder events
abstract class CareerEvent extends Equatable {
  const CareerEvent();
  @override
  List<Object> get props => [];
}

// Placeholder states
abstract class CareerState extends Equatable {
  const CareerState();
  @override
  List<Object> get props => [];
}

class CareerInitial extends CareerState {}
