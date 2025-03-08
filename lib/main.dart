import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show compute;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MovieScreen(),
    );
  }
}

class Movie {
  final String title;
  final int year;

  Movie({required this.title, required this.year});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(title: json['title'], year: json['year']);
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  List<Movie> movies = [];
  bool isLoading = false;

  /// Method 1: Load movies without isolate (UI Freezes)
  Future<void> loadMoviesWithoutIsolate() async {
    setState(() => isLoading = true);

    String jsonString = await rootBundle.loadString('assets/movies.json');
    List<Movie> moviesList = parseJson(jsonString); // Heavy computation

    setState(() {
      movies = moviesList;
      isLoading = false;
    });
  }

  /// Method 2: Load movies with isolate (UI Stays Smooth)
  Future<void> loadMoviesWithIsolate() async {
    setState(() => isLoading = true);

    String jsonString = await rootBundle.loadString('assets/movies.json');

    // Offload JSON parsing to an isolate
    List<Movie> moviesList = await compute(parseJson, jsonString);

    setState(() {
      movies = moviesList;
      isLoading = false;
    });
  }

  /// Function to parse JSON data
  static List<Movie> parseJson(String jsonString) {
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((movie) => Movie.fromJson(movie)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Isolates Demo")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const CircularProgressIndicator(), // Show loader while parsing
            const SizedBox(height: 20),

            // Button to load movies without isolate
            ElevatedButton(
              onPressed: loadMoviesWithoutIsolate,
              child: const Text("Load Movies (No Isolate)"),
            ),

            const SizedBox(height: 10),

            // Button to load movies with isolate
            ElevatedButton(
              onPressed: loadMoviesWithIsolate,
              child: const Text("Load Movies (With Isolate)"),
            ),

            const SizedBox(height: 20),

            // Display movies in a list
            Expanded(
              child: ListView.builder(
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(movies[index].title),
                    subtitle: Text("Year: ${movies[index].year}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
