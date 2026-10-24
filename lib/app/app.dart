import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_flutter_module/core/platform/native_bridge.dart';
import 'package:movies_flutter_module/features/movies/data/repositories/movie_repository.dart';
import 'package:movies_flutter_module/features/movies/presentation/bloc/movies_bloc.dart';
import 'package:movies_flutter_module/features/movies/presentation/bloc/trailer_bloc.dart';
import 'package:movies_flutter_module/features/movies/presentation/pages/movies_page.dart';
import 'package:movies_flutter_module/features/movies/presentation/widgets/trailer_listener.dart';

class MoviesApp extends StatelessWidget {
  const MoviesApp({
    required this.repository,
    required this.bridge,
    required this.hasApiKey,
    super.key,
  });

  final MovieRepository repository;
  final NativeBridge bridge;
  final bool hasApiKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: hasApiKey ? _buildMovies() : const _MissingApiKeyPage(),
    );
  }

  Widget _buildMovies() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              MoviesBloc(repository: repository)..add(const FetchMovies()),
        ),
        BlocProvider(create: (_) => TrailerBloc(repository: repository)),
      ],
      child: TrailerListener(
        bridge: bridge,
        child: Builder(
          builder: (context) => MoviesPage(
            onMovieTap: (movie) =>
                context.read<TrailerBloc>().add(TrailerRequested(movie)),
          ),
        ),
      ),
    );
  }
}

class _MissingApiKeyPage extends StatelessWidget {
  const _MissingApiKeyPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'TMDB API key is missing.\n'
            'Set it in lib/core/config/secrets.dart or run with '
            '--dart-define=TMDB_API_KEY=your_key (see README).',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
