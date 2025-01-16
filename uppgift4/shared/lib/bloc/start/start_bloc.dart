import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'start_event.dart';
import 'start_state.dart';

class StartBloc extends Bloc<StartEvent, StartState> {
  StartBloc() : super(StartInitial()) {
    on<LoadStartData>(_onLoadStartData);
  }

  Future<void> _onLoadStartData(
      LoadStartData event, Emitter<StartState> emit) async {
    emit(StartLoading());
    debugPrint('StartBloc: Loading data...');
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(StartLoaded(data: "Welcome to StartView!"));
      debugPrint('StartBloc: Data loaded successfully.');
    } catch (e) {
      emit(StartError(message: 'Failed to load start data: $e'));
      debugPrint('StartBloc: Error loading data - $e');
    }
  }
}
