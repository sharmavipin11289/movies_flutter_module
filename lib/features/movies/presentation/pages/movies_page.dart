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
            MoviesLoaded(:final movies) when movies.isEmpty => const Center(
              child: Text('No movies found'),
            ),
            final MoviesLoaded loaded => _MoviesList(
              state: loaded,
              onMovieTap: onMovieTap,
            ),
            MoviesError(:final message) => _ErrorView(message: message),
          };
        },
      ),
    );
  }
}

class _MoviesList extends StatefulWidget {
  const _MoviesList({required this.state, required this.onMovieTap});

  final MoviesLoaded state;
  final ValueChanged<Movie> onMovieTap;

  @override
  State<_MoviesList> createState() => _MoviesListState();
}

class _MoviesListState extends State<_MoviesList> {
  /// Start loading the next page this many pixels before the end.
  static const double _loadThreshold = 300;

  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = widget.state;
    if (!_controller.hasClients ||
        state.hasReachedMax ||
        state.isLoadingMore ||
        state.loadMoreFailed) {
      return;
    }
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent - _loadThreshold) {
      context.read<MoviesBloc>().add(const FetchNextPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final hasFooter = state.isLoadingMore || state.loadMoreFailed;

    return ListView.builder(
      controller: _controller,
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: state.movies.length + (hasFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.movies.length) {
          return _Footer(failed: state.loadMoreFailed);
        }
        final movie = state.movies[index];
        return MovieCard(movie: movie, onTap: () => widget.onMovieTap(movie));
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.failed});

  final bool failed;

  @override
  Widget build(BuildContext context) {
    if (!failed) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Could not load more movies'),
          TextButton(
            onPressed: () =>
                context.read<MoviesBloc>().add(const FetchNextPage()),
            child: const Text('Retry'),
          ),
        ],
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
