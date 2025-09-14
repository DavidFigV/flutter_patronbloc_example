abstract class CounterEvent {}
class CounterIncremented extends CounterEvent {} // Evento para incrementar el contador
class CounterDecremented extends CounterEvent {} // Evento para decrementar el contador
class CounterReset extends CounterEvent {} // Evento para resetear el contador
class CounterAutoIncrementStarted extends CounterEvent {} // Evento para iniciar auto-incremento por long press
class CounterAutoDecrementStarted extends CounterEvent {} // Evento para iniciar auto-decremento por long press
class CounterAutoRepeatStopped extends CounterEvent {} // Evento para detener auto-repeat