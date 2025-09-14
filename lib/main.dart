import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_patronbloc_example/game/game_bloc.dart';
import 'counter/counter_bloc.dart';
import 'counter/counter_event.dart';
import 'game/game_event.dart';
import 'game/game_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloc Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<GameBloc>(create: (context) => GameBloc()),
          BlocProvider<CounterBloc>(
            create: (context) => CounterBloc(
              gameBloc: context.read<GameBloc>(),
            ),
          ),
        ],
        child: const CounterPage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Counter Game con BLoC"),
      ),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, gameState) {
          return BlocBuilder<CounterBloc, int>(
            builder: (context, counterValue) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Panel del juego
                  Column(
                    children: [
                      Text(
                        gameState.isRunning 
                          ? 'Objetivo: ${gameState.targetNumber}'
                          : 'Presiona "Iniciar" para jugar',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 64,
                          vertical: 24,
                        ),
                        child: LinearProgressIndicator( // (countdown)
                          value: gameState.progress,
                          minHeight: 20,
                          borderRadius: BorderRadius.circular(10),
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            gameState.progress > 0.5 
                              ? Colors.green 
                              : gameState.progress > 0.25 
                                ? Colors.orange 
                                : Colors.red,
                          ),
                        ),
                      ),
                      Text(
                        "Puntaje: ${gameState.score}",
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        "Mejor Récord: ${gameState.record}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  
                  // Botón de control del juego
                  ElevatedButton(
                    onPressed: () {
                      if (gameState.isRunning) {
                        context.read<GameBloc>().add(GameStopped());
                        context.read<CounterBloc>().add(CounterReset());
                      } else {
                        context.read<GameBloc>().add(GameStarted());
                      }
                    },
                    child: Text(gameState.isRunning ? "Detener" : "Iniciar"),
                  ),
                  
                  // Contador actual
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.deepPurple.shade200),
                    ),
                    child: Text(
                      '$counterValue', 
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<GameBloc, GameState>(
        builder: (context, gameState) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón incrementar
              GestureDetector( // Detecta gestos de pulsación larga
                onLongPressStart: (_) { // Aquí se maneja el inicio de la pulsación larga
                  if (gameState.isRunning) { // Solo si el juego está en curso
                    context.read<CounterBloc>().add(CounterAutoIncrementStarted()); // Inicia la acción de incremento automático
                  }
                },
                onLongPressEnd: (_) { // Aquí se maneja el final de la pulsación larga
                  context.read<CounterBloc>().add(CounterAutoRepeatStopped()); // Detiene la acción de incremento automático
                },
                child: FloatingActionButton(
                  onPressed: gameState.isRunning ? () { // Solo si el juego está en curso
                    context.read<CounterBloc>().add(CounterIncremented()); // Incrementa el contador en 1 al presionar 1 vez
                  } : null, // Si el juego no está en curso, el botón no hace nada
                  backgroundColor: gameState.isRunning ? null : Colors.grey,
                  child: const Icon(Icons.add), 
                ),
              ),
              // Botón decrementar
              GestureDetector( // Detecta gestos de pulsación larga
                onLongPressStart: (_) { // Aquí se maneja el inicio de la pulsación larga
                  if (gameState.isRunning) { // Solo si el juego está en curso
                    context.read<CounterBloc>().add(CounterAutoDecrementStarted()); // Inicia la acción de decremento automático
                  }
                },
                onLongPressEnd: (_) { // Aquí se maneja el final de la pulsación larga
                  context.read<CounterBloc>().add(CounterAutoRepeatStopped()); // Detiene la acción de decremento automático
                },
                child: FloatingActionButton(
                  onPressed: gameState.isRunning ? () { // Solo si el juego está en curso
                    context.read<CounterBloc>().add(CounterDecremented()); // Decrementa el contador en 1 al presionar 1 vez
                  } : null, // Si el juego no está en curso, el botón no hace nada
                  backgroundColor: gameState.isRunning ? null : Colors.grey,
                  child: const Icon(Icons.remove),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}