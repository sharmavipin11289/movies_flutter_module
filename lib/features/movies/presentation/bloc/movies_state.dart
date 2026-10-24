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
  const MoviesLoaded(
    this.movies, {
    this.page = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<Movie> movies;

  /// Last page that was loaded successfully.
  final int page;

  /// True when TMDB has no more pages.
  final bool hasReachedMax;

  /// True while the next page is being fetched.
  final bool isLoadingMore;

  /// True when fetching the next page failed (the list is kept).
  final bool loadMoreFailed;

  MoviesLoaded copyWith({
    List<Movie>? movies,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) {
    return MoviesLoaded(
      movies ?? this.movies,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }

  @override
  List<Object?> get props => [
    movies,
    page,
    hasReachedMax,
    isLoadingMore,
    loadMoreFailed,
  ];
}

final class MoviesError extends MoviesState {
  const MoviesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
