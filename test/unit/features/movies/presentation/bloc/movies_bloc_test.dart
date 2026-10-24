import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/core/network/api_exception.dart';
import 'package:movies_flutter_module/features/movies/data/models/movie.dart';
import 'package:movies_flutter_module/features/movies/data/models/paged_movies.dart';
import 'package:movies_flutter_module/features/movies/data/repositories/movie_repository.dart';
import 'package:movies_flutter_module/features/movies/presentation/bloc/movies_bloc.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository repository;

  const a = Movie(id: 1, title: 'A', overview: 'a');
  const b = Movie(id: 2, title: 'B', overview: 'b', posterPath: '/b.jpg');
  const c = Movie(id: 3, title: 'C', overview: 'c');
  const movies = [a, b];

  const firstPage = PagedMovies(movies: movies, page: 1, totalPages: 3);

  setUp(() {
    repository = MockMovieRepository();
  });

  test('initial state is MoviesInitial', () {
    expect(MoviesBloc(repository: repository).state, const MoviesInitial());
  });

  group('FetchMovies', () {
    blocTest<MoviesBloc, MoviesState>(
      'emits [MoviesLoading, MoviesLoaded] when fetch succeeds',
      setUp: () {
        when(() => repository.getPopularMovies(page: 1))
            .thenAnswer((_) async => firstPage);
      },
      build: () => MoviesBloc(repository: repository),
      act: (bloc) => bloc.add(const FetchMovies()),
      expect: () => [const MoviesLoading(), const MoviesLoaded(movies)],
      verify: (_) {
        verify(() => repository.getPopularMovies(page: 1)).called(1);
      },
    );

    blocTest<MoviesBloc, MoviesState>(
      'marks hasReachedMax when there is only one page',
      setUp: () {
        when(() => repository.getPopularMovies(page: 1)).thenAnswer(
          (_) async =>
              const PagedMovies(movies: movies, page: 1, totalPages: 1),
        );
      },
      build: () => MoviesBloc(repository: repository),
      act: (bloc) => bloc.add(const FetchMovies()),
      expect: () => [
        const MoviesLoading(),
        const MoviesLoaded(movies, hasReachedMax: true),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'emits an empty, finished list when TMDB returns no movies',
      setUp: () {
        when(() => repository.getPopularMovies(page: 1)).thenAnswer(
          (_) async => const PagedMovies(movies: [], page: 1, totalPages: 1),
        );
      },
      build: () => MoviesBloc(repository: repository),
      act: (bloc) => bloc.add(const FetchMovies()),
      expect: () => [
        const MoviesLoading(),
        const MoviesLoaded([], hasReachedMax: true),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'emits [MoviesLoading, MoviesError] when the api fails',
      setUp: () {
        when(() => repository.getPopularMovies(page: 1)).thenAnswer(
          (_) async => throw const ApiException('Request failed (401)'),
        );
      },
      build: () => MoviesBloc(repository: repository),
      act: (bloc) => bloc.add(const FetchMovies()),
      expect: () => [
        const MoviesLoading(),
        const MoviesError('Request failed (401)'),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'can retry after an error',
      setUp: () {
        var calls = 0;
        when(() => repository.getPopularMovies(page: 1)).thenAnswer((_) async {
          calls++;
          if (calls == 1) throw const ApiException('Network error');
          return firstPage;
        });
      },
      build: () => MoviesBloc(repository: repository),
      act: (bloc) async {
        bloc.add(const FetchMovies());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const FetchMovies());
      },
      expect: () => [
        const MoviesLoading(),
        const MoviesError('Network error'),
        const MoviesLoading(),
        const MoviesLoaded(movies),
      ],
    );
  });

  group('FetchNextPage', () {
    blocTest<MoviesBloc, MoviesState>(
      'appends the next page to the list',
      setUp: () {
        when(() => repository.getPopularMovies(page: 2)).thenAnswer(
          (_) async => const PagedMovies(movies: [c], page: 2, totalPages: 3),
        );
      },
      build: () => MoviesBloc(repository: repository),
      seed: () => const MoviesLoaded(movies),
      act: (bloc) => bloc.add(const FetchNextPage()),
      expect: () => [
        const MoviesLoaded(movies, isLoadingMore: true),
        const MoviesLoaded([a, b, c], page: 2),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'sets hasReachedMax when the last page is loaded',
      setUp: () {
        when(() => repository.getPopularMovies(page: 2)).thenAnswer(
          (_) async => const PagedMovies(movies: [c], page: 2, totalPages: 2),
        );
      },
      build: () => MoviesBloc(repository: repository),
      seed: () => const MoviesLoaded(movies),
      act: (bloc) => bloc.add(const FetchNextPage()),
      expect: () => [
        const MoviesLoaded(movies, isLoadingMore: true),
        const MoviesLoaded([a, b, c], page: 2, hasReachedMax: true),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'skips movies that are already in the list',
      setUp: () {
        when(() => repository.getPopularMovies(page: 2)).thenAnswer(
          (_) async =>
              const PagedMovies(movies: [b, c], page: 2, totalPages: 3),
        );
      },
      build: () => MoviesBloc(repository: repository),
      seed: () => const MoviesLoaded(movies),
      act: (bloc) => bloc.add(const FetchNextPage()),
      expect: () => [
        const MoviesLoaded(movies, isLoadingMore: true),
        const MoviesLoaded([a, b, c], page: 2),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'keeps the list and sets loadMoreFailed when the next page fails',
      setUp: () {
        when(() => repository.getPopularMovies(page: 2))
            .thenAnswer((_) async => throw const ApiException('Network error'));
      },
      build: () => MoviesBloc(repository: repository),
      seed: () => const MoviesLoaded(movies),
      act: (bloc) => bloc.add(const FetchNextPage()),
      expect: () => [
        const MoviesLoaded(movies, isLoadingMore: true),
        const MoviesLoaded(movies, loadMoreFailed: true),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'can load the next page again after a failure',
      setUp: () {
        when(() => repository.getPopularMovies(page: 2)).thenAnswer(
          (_) async => const PagedMovies(movies: [c], page: 2, totalPages: 3),
        );
      },
      build: () => MoviesBloc(repository: repository),
      seed: () => const MoviesLoaded(movies, loadMoreFailed: true),
      act: (bloc) => bloc.add(const FetchNextPage()),
      expect: () => [
        const MoviesLoaded(movies, isLoadingMore: true),
        const MoviesLoaded([a, b, c], page: 2),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'does nothing when hasReachedMax is true',
      build: () => MoviesBloc(repository: repository),
      seed: () => const MoviesLoaded(movies, hasReachedMax: true),
      act: (bloc) => bloc.add(const FetchNextPage()),
      expect: () => <MoviesState>[],
      verify: (_) {
        verifyNever(
          () => repository.getPopularMovies(page: any(named: 'page')),
        );
      },
    );

    blocTest<MoviesBloc, MoviesState>(
      'does nothing when the list is not loaded yet',
      build: () => MoviesBloc(repository: repository),
      seed: () => const MoviesLoading(),
      act: (bloc) => bloc.add(const FetchNextPage()),
      expect: () => <MoviesState>[],
      verify: (_) {
        verifyNever(
          () => repository.getPopularMovies(page: any(named: 'page')),
        );
      },
    );
  });
}
