part of 'trailer_bloc.dart';

sealed class TrailerState extends Equatable {
  const TrailerState();

  @override
  List<Object?> get props => [];
}

final class TrailerInitial extends TrailerState {
  const TrailerInitial();
}

final class TrailerLoading extends TrailerState {
  const TrailerLoading();
}

final class TrailerReady extends TrailerState {
  const TrailerReady({required this.movie, required this.youtubeKey});

  final Movie movie;
  final String youtubeKey;

  @override
  List<Object?> get props => [movie, youtubeKey];
}

/// The movie exists but TMDB has no YouTube trailer for it.
final class TrailerUnavailable extends TrailerState {
  const TrailerUnavailable(this.movie);

  final Movie movie;

  @override
  List<Object?> get props => [movie];
}

final class TrailerFailure extends TrailerState {
  const TrailerFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
