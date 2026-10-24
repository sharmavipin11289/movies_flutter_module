import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/core/network/api_exception.dart';
import 'package:movies_flutter_module/features/movies/data/models/movie.dart';
import 'package:movies_flutter_module/features/movies/data/repositories/movie_repository.dart';
import 'package:movies_flutter_module/features/movies/presentation/bloc/trailer_bloc.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository repository;

  const movie = Movie(id: 550, title: 'Fight Club', overview: 'o');

  setUp(() {
    repository = MockMovieRepository();
  });

  test('initial state is TrailerInitial', () {
    expect(TrailerBloc(repository: repository).state, const TrailerInitial());
  });

  blocTest<TrailerBloc, TrailerState>(
    'emits [TrailerLoading, TrailerReady] when a trailer key is found',
    setUp: () {
      when(() => repository.getTrailerKey(550))
          .thenAnswer((_) async => 'abc123');
    },
    build: () => TrailerBloc(repository: repository),
    act: (bloc) => bloc.add(const TrailerRequested(movie)),
    expect: () => [
      const TrailerLoading(),
      const TrailerReady(movie: movie, youtubeKey: 'abc123'),
    ],
    verify: (_) {
      verify(() => repository.getTrailerKey(550)).called(1);
    },
  );

  blocTest<TrailerBloc, TrailerState>(
    'emits [TrailerLoading, TrailerUnavailable] when the movie has no trailer',
    setUp: () {
      when(() => repository.getTrailerKey(550)).thenAnswer((_) async => null);
    },
    build: () => TrailerBloc(repository: repository),
    act: (bloc) => bloc.add(const TrailerRequested(movie)),
    expect: () => [const TrailerLoading(), const TrailerUnavailable(movie)],
  );

  blocTest<TrailerBloc, TrailerState>(
    'emits [TrailerLoading, TrailerFailure] when the api fails',
    setUp: () {
      when(() => repository.getTrailerKey(550))
          .thenAnswer((_) async => throw const ApiException('Network error'));
    },
    build: () => TrailerBloc(repository: repository),
    act: (bloc) => bloc.add(const TrailerRequested(movie)),
    expect: () => [
      const TrailerLoading(),
      const TrailerFailure('Network error'),
    ],
  );
}
