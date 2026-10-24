import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/bloc/movies/movies_bloc.dart';
import 'package:movies_flutter_module/data/models/movie.dart';
import 'package:movies_flutter_module/data/movie_api_client.dart';
import 'package:movies_flutter_module/data/movie_repository.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository repository;

  const movies = [
    Movie(id: 1, title: 'A', overview: 'a'),
    Movie(id: 2, title: 'B', overview: 'b', posterPath: '/b.jpg'),
  ];

  setUp(() {
    repository = MockMovieRepository();
  });

  test('initial state is MoviesInitial', () {
    expect(MoviesBloc(repository: repository).state, const MoviesInitial());
  });

  blocTest<MoviesBloc, MoviesState>(
    'emits [MoviesLoading, MoviesLoaded] when fetch succeeds',
    setUp: () {
      when(() => repository.getPopularMovies()).thenAnswer((_) async => movies);
    },
    build: () => MoviesBloc(repository: repository),
    act: (bloc) => bloc.add(const FetchMovies()),
    expect: () => [const MoviesLoading(), const MoviesLoaded(movies)],
    verify: (_) {
      verify(() => repository.getPopularMovies()).called(1);
    },
  );

  blocTest<MoviesBloc, MoviesState>(
    'emits [MoviesLoading, MoviesLoaded([])] when the list is empty',
    setUp: () {
      when(() => repository.getPopularMovies())
          .thenAnswer((_) async => <Movie>[]);
    },
    build: () => MoviesBloc(repository: repository),
    act: (bloc) => bloc.add(const FetchMovies()),
    expect: () => [const MoviesLoading(), const MoviesLoaded([])],
  );

  blocTest<MoviesBloc, MoviesState>(
    'emits [MoviesLoading, MoviesError] when the api fails',
    setUp: () {
      when(() => repository.getPopularMovies()).thenAnswer(
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
      when(() => repository.getPopularMovies()).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw const ApiException('Network error');
        return movies;
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
}
