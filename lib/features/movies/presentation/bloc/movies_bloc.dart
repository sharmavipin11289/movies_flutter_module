import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_flutter_module/core/network/api_exception.dart';
import 'package:movies_flutter_module/features/movies/data/models/movie.dart';
import 'package:movies_flutter_module/features/movies/data/repositories/movie_repository.dart';

part 'movies_event.dart';
part 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  MoviesBloc({required this.repository}) : super(const MoviesInitial()) {
    on<FetchMovies>(_onFetchMovies);
    on<FetchNextPage>(_onFetchNextPage, transformer: droppable());
  }

  final MovieRepository repository;

  Future<void> _onFetchMovies(
    FetchMovies event,
    Emitter<MoviesState> emit,
  ) async {
    emit(const MoviesLoading());
    try {
      final result = await repository.getPopularMovies(page: 1);
      emit(
        MoviesLoaded(
          result.movies,
          page: result.page,
          hasReachedMax: !result.hasMore,
        ),
      );
    } on ApiException catch (e) {
      emit(MoviesError(e.message));
    }
  }

  Future<void> _onFetchNextPage(
    FetchNextPage event,
    Emitter<MoviesState> emit,
  ) async {
    final current = state;
    if (current is! MoviesLoaded ||
        current.hasReachedMax ||
        current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true, loadMoreFailed: false));
    try {
      final result = await repository.getPopularMovies(page: current.page + 1);
      final knownIds = current.movies.map((m) => m.id).toSet();
      final fresh = result.movies.where((m) => !knownIds.contains(m.id));
      emit(
        MoviesLoaded(
          [...current.movies, ...fresh],
          page: result.page,
          hasReachedMax: !result.hasMore,
        ),
      );
    } on ApiException {
      emit(current.copyWith(loadMoreFailed: true));
    }
  }
}
