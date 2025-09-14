// ================================
// GAME EVENTS - Todos los eventos del juego
// ================================

abstract class GameEvent {}

class GameStarted extends GameEvent {} // Iniciar el juego
class GameStopped extends GameEvent {} // Detener el juego
class GameTick extends GameEvent {} // Para cada tick del timer
class GameRoundCompleted extends GameEvent {} // Cuando se completa una ronda