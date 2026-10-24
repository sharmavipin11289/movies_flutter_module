part of 'movies_bloc.dart';

sealed class MoviesState extends Equatable {
  const MoviesState();

  @override
  List<Object?> get props => [];
}

final class MoviesInitial extends MoviesState {
  const MoviesInitial();
}

final class MoviesLoading extends MoviesState {
  const MoviesLoading();
}

final class MoviesLoaded extends MoviesState {
  const MoviesLoaded(this.movies);

  final List<Movie> movies;

  @override
  List<Object?> get props => [movies];
}

final class MoviesError extends MoviesState {
  const MoviesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
