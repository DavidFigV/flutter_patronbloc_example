// ================================
// GAME STATES - Estados del juego
// ================================

class GameState {
  final bool isRunning; // Indica si el juego está en curso
  final double progress; // Progreso del tiempo (0.0 a 1.0)
  final int targetNumber; // Número objetivo a alcanzar
  final int score; // Puntaje actual
  final int record; // Mejor puntaje
  final int currentCounter; // Valor actual del contador
  
  const GameState({
    this.isRunning = false,
    this.progress = 1.0,
    this.targetNumber = 0,
    this.score = 0,
    this.record = 0,
    this.currentCounter = 0,
  });
  
  GameState copyWith({
    bool? isRunning,
    double? progress,
    int? targetNumber,
    int? score,
    int? record,
    int? currentCounter,
  }) {
    return GameState(
      isRunning: isRunning ?? this.isRunning,
      progress: progress ?? this.progress,
      targetNumber: targetNumber ?? this.targetNumber,
      score: score ?? this.score,
      record: record ?? this.record,
      currentCounter: currentCounter ?? this.currentCounter,
    );
  }
}
