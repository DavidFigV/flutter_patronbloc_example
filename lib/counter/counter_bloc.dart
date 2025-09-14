// ================================
// COUNTER BLOC - Refactorizado para incluir auto-repeat
// ================================

import 'dart:async';

import 'package:bloc/bloc.dart';
import '/game/game_bloc.dart';
import 'counter_event.dart';

class CounterBloc extends Bloc<CounterEvent, int> {
  Timer? _autoRepeatTimer; // Timer para auto-repeat
  GameBloc? _gameBloc; // Referencia para notificar cambios
  
  CounterBloc({GameBloc? gameBloc}) : super(0) {
    _gameBloc = gameBloc;
    on<CounterIncremented>(_onIncremented); // Maneja incremento normal (on tap)
    on<CounterDecremented>(_onDecremented); // Maneja decremento normal (on tap)
    on<CounterReset>(_onReset); // Maneja reseteo del contador
    on<CounterAutoIncrementStarted>(_onAutoIncrementStarted); // Maneja inicio de auto-repeat (on long press)
    on<CounterAutoDecrementStarted>(_onAutoDecrementStarted); // Maneja inicio de auto-repeat (on long press)
    on<CounterAutoRepeatStopped>(_onAutoRepeatStopped); // Maneja detención de auto-repeat (on long press end)
  }
  
  void _onIncremented(CounterIncremented event, Emitter<int> emit) {
    final newValue = state + 1;
    emit(newValue); // Actualiza el estado del contador
    _gameBloc?.updateCounter(newValue); // Notificar cambio al GameBloc
  }
  
  void _onDecremented(CounterDecremented event, Emitter<int> emit) {
    final newValue = state - 1;
    emit(newValue); // Actualiza el estado del contador
    _gameBloc?.updateCounter(newValue); // Notificar cambio al GameBloc
  }
  
  void _onReset(CounterReset event, Emitter<int> emit) {
    emit(0); // Resetea el contador a 0 
    _gameBloc?.updateCounter(0); // Notificar reseteo al GameBloc
  }
  
  void _onAutoIncrementStarted(CounterAutoIncrementStarted event, Emitter<int> emit) {
    _startAutoRepeat(true); // true para incrementar
  }
  
  void _onAutoDecrementStarted(CounterAutoDecrementStarted event, Emitter<int> emit) {
    _startAutoRepeat(false); // false para decrementar
  }
  
  void _onAutoRepeatStopped(CounterAutoRepeatStopped event, Emitter<int> emit) {
    _autoRepeatTimer?.cancel(); // Detener el auto-repeat
  }
  
  // Inicia el auto-repeat con aceleración progresiva
  void _startAutoRepeat(bool increment) { // true para incrementar, false para decrementar
    _autoRepeatTimer?.cancel(); // Cancelar cualquier timer previo
    
    int interval = 100; // Intervalo inicial en ms (Indica la velocidad inicial)
    const int minInterval = 50; // Intervalo mínimo en ms (Velocidad máxima)
    
    void executeRepeat() { 
      _autoRepeatTimer = Timer.periodic(Duration(milliseconds: interval), (timer) { 
        if (increment) {
          add(CounterIncremented()); // Incrementar
        } else {
          add(CounterDecremented()); // Decrementar
        }
        
        // Acelerar
        if (interval > minInterval) {
          interval = (interval * 0.8).toInt(); // Reducir intervalo en 20%
          timer.cancel(); 
          executeRepeat(); // Reiniciar con nuevo intervalo
        }
      });
    }
    
    executeRepeat();
  }
  
  @override
  Future<void> close() {
    _autoRepeatTimer?.cancel(); // Cancelar timer al cerrar
    return super.close(); 
  }
}