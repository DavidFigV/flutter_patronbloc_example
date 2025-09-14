// ================================
// GAME BLOC - Lógica principal del juego
// ================================

import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  Timer? _gameTimer; // Timer del juego para el countdown
  final Random _random = Random(); // Generador de números aleatorios para el objetivo
  static const int _countdownMs = 5000; // Duración del countdown en ms
  static const int _tickIntervalMs = 50; // Intervalo de tick del timer para actualizar progreso en ms
  
  GameBloc() : super(const GameState()) {
    on<GameStarted>(_onGameStarted); // Manejar evento de inicio del juego
    on<GameStopped>(_onGameStopped); // Manejar evento de detención del juego
    on<GameTick>(_onGameTick); // Manejar evento de tick del timer para actualizar progreso del countdown
    on<GameRoundCompleted>(_onGameRoundCompleted); // Manejar evento de finalización de ronda
  }
  
  void _onGameStarted(GameStarted event, Emitter<GameState> emit) {
    _startNewRound(emit); // Iniciar una nueva ronda
  }
  
  void _onGameStopped(GameStopped event, Emitter<GameState> emit) {
    _gameTimer?.cancel(); // Cancelar timer si existe
    emit(GameState(record: state.record)); // Resetear a estado inicial
  }
  
  void _onGameTick(GameTick event, Emitter<GameState> emit) { 
    final newProgress = state.progress - (_tickIntervalMs / _countdownMs); // Calcular nuevo progreso del countdown
    
    if (newProgress <= 0) {
      // Tiempo agotado, evaluar resultado
      add(GameRoundCompleted());
    } else {
      emit(state.copyWith(progress: newProgress)); // Actualizar countdown
    }
  }
  
  void _onGameRoundCompleted(GameRoundCompleted event, Emitter<GameState> emit) { // Evaluar si el jugador acertó o falló
    _gameTimer?.cancel();
    
    // Evaluar si acertó
    if (state.currentCounter == state.targetNumber) {
      // ¡Acierto!
      final newScore = state.score + 1;
      emit(state.copyWith(score: newScore)); // Actualizar puntuación
    } else {
      // Falló
      final newRecord = state.score > state.record ? state.score : state.record;
      emit(state.copyWith( // Resetear estado del juego
        score: 0, // Resetear puntuación
        record: newRecord, // Actualizar récord
      ));
    }
    
    // Si el juego sigue activo, iniciar nueva ronda
    if (state.isRunning) {
      _startNewRound(emit); // Iniciar nueva ronda
    }
  }
  
  void _startNewRound(Emitter<GameState> emit) {
    final newTarget = _random.nextInt(101) - 50; // Generar número objetivo aleatorio entre -50 y 50
    
    emit(state.copyWith(
      isRunning: true, // El juego está en marcha
      progress: 1.0, // Resetear progreso del countdown
      targetNumber: newTarget, // Nuevo número objetivo
    ));
    
    // Iniciar timer del juego
    _gameTimer = Timer.periodic(
      Duration(milliseconds: _tickIntervalMs),
      (_) => add(GameTick()), // Disparar evento de tick para actualizar progreso
    );
  }
  
  // Método para actualizar el contador desde el CounterBloc
  void updateCounter(int newValue) {
    if (state.isRunning) {
      emit(state.copyWith(currentCounter: newValue)); // Actualizar valor del contador actual
    }
  }
  
  @override
  Future<void> close() { // Limpiar recursos al cerrar el BLoC
    _gameTimer?.cancel(); // Cancelar timer si existe
    return super.close();
  }
}