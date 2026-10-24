import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_flutter_module/features/movies/data/models/movie.dart';
import 'package:movies_flutter_module/features/movies/presentation/bloc/movies_bloc.dart';
import 'package:movies_flutter_module/features/movies/presentation/widgets/movie_card.dart';

class MoviesPage extends StatelessWidget {
  const MoviesPage({required this.onMovieTap, super.key});

  final ValueChanged<Movie> onMovieTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popular Movies')),
      body: BlocBuilder<MoviesBloc, MoviesState>(
        builder: (context, state) {
          return switch (state) {
            MoviesInitial() ||
            MoviesLoading() => const Center(child: CircularProgressIndicator()),
            MoviesLoaded(:final movies) =>
              movies.isEmpty
                  ? const Center(child: Text('No movies found'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return MovieCard(
                          movie: movie,
                          onTap: () => onMovieTap(movie),
                        );
                      },
                    ),
            MoviesError(:final message) => _ErrorView(message: message),
          };
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  context.read<MoviesBloc>().add(const FetchMovies()),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
