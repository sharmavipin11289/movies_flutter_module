import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_flutter_module/features/movies/data/models/movie.dart';
import 'package:movies_flutter_module/features/movies/presentation/widgets/movie_card.dart';

void main() {
  const movie = Movie(
    id: 550,
    title: 'Fight Club',
    overview: 'An insomniac office worker starts a fight club.',
    posterPath: '/abc123.jpg',
  );

  Future<void> pumpCard(
    WidgetTester tester, {
    Movie movie = movie,
    VoidCallback? onTap,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MovieCard(movie: movie, onTap: onTap ?? () {}),
        ),
      ),
    );
  }

  testWidgets('shows the title and the description', (tester) async {
    await pumpCard(tester);

    expect(find.text('Fight Club'), findsOneWidget);
    expect(
      find.text('An insomniac office worker starts a fight club.'),
      findsOneWidget,
    );
  });

  testWidgets('shows the poster image when the movie has one', (tester) async {
    await pumpCard(tester);

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('shows a placeholder icon when there is no poster', (
    tester,
  ) async {
    await pumpCard(
      tester,
      movie: const Movie(id: 1, title: 'No Poster', overview: 'x'),
    );

    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
  });

  testWidgets('limits the description to 3 lines with ellipsis', (
    tester,
  ) async {
    await pumpCard(tester);

    final text = tester.widget<Text>(
      find.text('An insomniac office worker starts a fight club.'),
    );
    expect(text.maxLines, 3);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('calls onTap when the card is tapped', (tester) async {
    var taps = 0;
    await pumpCard(tester, onTap: () => taps++);

    await tester.tap(find.byType(MovieCard));

    expect(taps, 1);
  });
}
