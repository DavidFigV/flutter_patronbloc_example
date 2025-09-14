import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'counter/counter_bloc.dart';
import 'counter/counter_event.dart';

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
      home: BlocProvider(create: (_) => CounterBloc(), child: CounterPage()),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  Timer? timer;
  Timer? countdownTimer;
  double progress = 1.0; // Progreso de la barra
  final int countdownSeconds = 5;
  int randomNumber = 0;
  int puntaje = 0, record = 0;
  bool isCounting = false;
  late CounterBloc counterBloc;

  @override
  void initState() {
    super.initState();
    counterBloc = context.read<CounterBloc>();
  }

  void startCountdown() {
    countdownTimer?.cancel();
    setState(() {
      progress = 1.0;
      randomNumber = generateRandomNumber();
    });
    int elapsed = 0;
    countdownTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      elapsed += 50;
      setState(() {
        progress = 1.0 - (elapsed / (countdownSeconds * 1000));
        if (progress <= 0.0) {
          progress = 0.0;
          countdownTimer?.cancel();
          if (counterBloc.state == randomNumber) {
            setState(() => puntaje++);
          } else {
            if (puntaje > record) {
              setState(() => record = puntaje);
            }
            setState(() => puntaje = 0);
          }
          if (isCounting) {
            startCountdown();
          }
        }
      });
    });
  }

  void toggleCountdown() {
    if (isCounting) {
      // Detener
      countdownTimer?.cancel();
      setState(() {
        isCounting = false;
        progress = 1.0;
        randomNumber = 0;
        record = 0;
        puntaje = 0;
      });
      context.read<CounterBloc>().add(CounterReset());
    } else {
      // Iniciar
      setState(() {
        isCounting = true;
      });
      startCountdown();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  int generateRandomNumber() {
    return Random().nextInt(101) - 50;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Counter con BLoC"),
      ),
      body: BlocBuilder<CounterBloc, int>(
        builder: (context, count) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    'Objetivo: $randomNumber',
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
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 20,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text("Puntaje: $puntaje"),
                  Text("Mejor Record: $record"),
                ],
              ),
              ElevatedButton(
                onPressed: toggleCountdown,
                child: Text(isCounting ? "Detener" : "Iniciar"),
              ),
              Text('$count', style: const TextStyle(fontSize: 48)),
            ],
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onLongPressStart: (_) {
              int interval = 100; // intervalo inicial en ms
              int minInterval = 50; // límite mínimo para no ir demasiado rápido
              void startRepeating() {
                timer = Timer.periodic(Duration(milliseconds: interval), (t) {
                  context.read<CounterBloc>().add(CounterIncremented());
                  // Acelera reduciendo el intervalo cada 1 segundo aprox
                  if (interval > minInterval) {
                    interval = (interval * 0.8)
                        .toInt(); // reduce 20% el intervalo
                    t.cancel();
                    startRepeating(); // reinicia con nuevo intervalo
                  }
                });
              }

              startRepeating();
            },
            onLongPressEnd: (_) {
              timer?.cancel();
            },
            child: FloatingActionButton(
              onPressed: () =>
                  context.read<CounterBloc>().add(CounterIncremented()),
              child: const Icon(Icons.add),
            ),
          ),
          GestureDetector(
            onLongPressStart: (_) {
              int interval = 100; // intervalo inicial en ms
              int minInterval = 50; // límite mínimo para no ir demasiado rápido
              void startRepeating() {
                timer = Timer.periodic(Duration(milliseconds: interval), (t) {
                  context.read<CounterBloc>().add(CounterDecremented());
                  if (interval > minInterval) {
                    interval = (interval * 0.8)
                        .toInt(); // reduce 20% el intervalo
                    t.cancel();
                    startRepeating(); // reinicia con nuevo intervalo
                  }
                });
              }

              startRepeating();
            },
            onLongPressEnd: (_) {
              timer?.cancel();
            },
            child: FloatingActionButton(
              onPressed: () =>
                  context.read<CounterBloc>().add(CounterDecremented()),
              child: const Icon(Icons.remove),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
