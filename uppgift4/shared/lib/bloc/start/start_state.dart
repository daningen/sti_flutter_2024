abstract class StartState {}

class StartInitial extends StartState {}

class StartLoading extends StartState {}

class StartLoaded extends StartState {
  final String data;  
  StartLoaded({required this.data});
}

class StartError extends StartState {
  final String message;
  StartError({required this.message});
}
