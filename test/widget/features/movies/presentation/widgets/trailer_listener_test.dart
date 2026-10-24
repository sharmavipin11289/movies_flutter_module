import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/core/platform/native_bridge.dart';
import 'package:movies_flutter_module/features/movies/data/models/movie.dart';
import 'package:movies_flutter_module/features/movies/presentation/bloc/trailer_bloc.dart';
import 'package:movies_flutter_module/features/movies/presentation/widgets/trailer_listener.dart';

class MockTrailerBloc extends MockBloc<TrailerEvent, TrailerState>
    implements TrailerBloc {}

class MockNativeBridge extends Mock implements NativeBridge {}

void main() {
  late MockTrailerBloc bloc;
  late MockNativeBridge bridge;

  const movie = Movie(id: 550, title: 'Fight Club', overview: 'o');

  setUp(() {
    bloc = MockTrailerBloc();
    bridge = MockNativeBridge();
    when(
      () => bridge.openTrailer(
        movieId: any(named: 'movieId'),
        title: any(named: 'title'),
        youtubeKey: any(named: 'youtubeKey'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> pumpListener(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TrailerBloc>.value(
            value: bloc,
            child: TrailerListener(bridge: bridge, child: const Text('child')),
          ),
        ),
      ),
    );
  }

  testWidgets('renders its child', (tester) async {
    whenListen(
      bloc,
      const Stream<TrailerState>.empty(),
      initialState: const TrailerInitial(),
    );

    await pumpListener(tester);

    expect(find.text('child'), findsOneWidget);
  });

  testWidgets('sends openTrailer with the key on TrailerReady', (tester) async {
    whenListen(
      bloc,
      Stream<TrailerState>.fromIterable([
        const TrailerReady(movie: movie, youtubeKey: 'abc123'),
      ]),
      initialState: const TrailerInitial(),
    );

    await pumpListener(tester);
    await tester.pump();

    verify(
      () => bridge.openTrailer(
        movieId: 550,
        title: 'Fight Club',
        youtubeKey: 'abc123',
      ),
    ).called(1);
  });

  testWidgets('sends openTrailer with a null key on TrailerUnavailable', (
    tester,
  ) async {
    whenListen(
      bloc,
      Stream<TrailerState>.fromIterable([const TrailerUnavailable(movie)]),
      initialState: const TrailerInitial(),
    );

    await pumpListener(tester);
    await tester.pump();

    verify(
      () => bridge.openTrailer(
        movieId: 550,
        title: 'Fight Club',
        youtubeKey: null,
      ),
    ).called(1);
  });

  testWidgets('shows a snackbar and does not call native on TrailerFailure', (
    tester,
  ) async {
    whenListen(
      bloc,
      Stream<TrailerState>.fromIterable([
        const TrailerFailure('Network error'),
      ]),
      initialState: const TrailerInitial(),
    );

    await pumpListener(tester);
    await tester.pump();

    expect(find.text('Network error'), findsOneWidget);
    verifyNever(
      () => bridge.openTrailer(
        movieId: any(named: 'movieId'),
        title: any(named: 'title'),
        youtubeKey: any(named: 'youtubeKey'),
      ),
    );
  });
}
