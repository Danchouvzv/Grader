import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'ielts_event.dart';
part 'ielts_state.dart';

class IeltsBloc extends Bloc<IeltsEvent, IeltsState> {
  IeltsBloc(this._getRandomTask, this._assessAudio) : super(IeltsInitial()) {
    // Event handlers will be implemented later
  }

  final dynamic _getRandomTask;
  final dynamic _assessAudio;
}

// Placeholder events
abstract class IeltsEvent extends Equatable {
  const IeltsEvent();
  @override
  List<Object> get props => [];
}

// Placeholder states
abstract class IeltsState extends Equatable {
  const IeltsState();
  @override
  List<Object> get props => [];
}

class IeltsInitial extends IeltsState {}
