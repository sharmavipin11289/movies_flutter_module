import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_flutter_module/data/models/movie.dart';
import 'package:movies_flutter_module/data/movie_api_client.dart';
import 'package:movies_flutter_module/data/movie_repository.dart';

part 'movies_event.dart';
part 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  MoviesBloc({required this.repository}) : super(const MoviesInitial()) {
    on<FetchMovies>(_onFetchMovies);
  }

  final MovieRepository repository;

  Future<void> _onFetchMovies(
    FetchMovies event,
    Emitter<MoviesState> emit,
  ) async {
    emit(const MoviesLoading());
    try {
      final movies = await repository.getPopularMovies();
      emit(MoviesLoaded(movies));
    } on ApiException catch (e) {
      emit(MoviesError(e.message));
    }
  }
}
