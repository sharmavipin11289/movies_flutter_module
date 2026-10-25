# Movies Flutter Module

A Flutter **add-to-app module** that lists popular movies from
[TMDB](https://www.themoviedb.org/) as cards (poster, title, description).
When a movie is tapped, the module fetches its trailer key and hands control
back to the host app (Android / iOS), which plays the trailer on a native screen.

State management uses the **Bloc** pattern. The code was built test-first (TDD).

## Repositories

| Repo | Link |
|---|---|
| Flutter module (this repo) | `https://github.com/sharmavipin11289/movies_flutter_module.git` |
| Android host app | `https://github.com/sharmavipin11289/movies_android_app.git` |
| iOS host app (SwiftUI) | `https://github.com/sharmavipin11289/movies_ios_app.git` |

The host apps reference this module by relative path, so clone all repos
**side by side** in the same parent folder:

```
some_folder/
├── movies_flutter_module/
├── movies_android_app/
└── movies_ios_app/
```

## Features

- Popular movies list with poster, title and description
- Infinite scroll pagination (TMDB `page` parameter)
- Loading, empty and error states with Retry (also for failed next-page loads)
- Tap a movie: trailer key is fetched, then the native app opens the trailer
- Works standalone (`flutter run`) and embedded in native apps

## TMDB API key setup

The key is **not** committed. Create your own v3 API key at
https://www.themoviedb.org/settings/api, then use **one** of these options.

**Option A: `secrets.dart`**

Put the key in `lib/core/config/secrets.dart`:

```dart
const String tmdbApiKey = 'your_key_here';
```

Then tell git to ignore your local change so it is never committed:

```bash
git update-index --skip-worktree lib/core/config/secrets.dart
```

(Undo with `git update-index --no-skip-worktree lib/core/config/secrets.dart`.)

**Option B: `--dart-define`** (standalone runs only)

```bash
flutter run --dart-define=TMDB_API_KEY=your_key_here
```

If no key is set, the app shows a "TMDB API key is missing" screen instead
of failing with network errors.

> When the module is embedded in the Android/iOS apps, use Option A, because
> the host apps build the module without `--dart-define`.

## Run standalone

```bash
flutter pub get
flutter run
```

## Architecture

Feature-first layout:

```
lib/
├── app/                      MoviesApp (providers, theme, TrailerListener)
├── core/
│   ├── config/               api constants, AppConfig, secrets
│   ├── network/              Dio setup, ApiException
│   └── platform/             NativeBridge (MethodChannel)
└── features/movies/
    ├── data/
    │   ├── datasources/      MovieApiClient (Dio)
    │   ├── models/           Movie, PagedMovies
    │   └── repositories/     MovieRepository
    └── presentation/
        ├── bloc/             MoviesBloc, TrailerBloc
        ├── pages/            MoviesPage
        └── widgets/          MovieCard, TrailerListener
```

- **MoviesBloc**: `FetchMovies`, `FetchNextPage` (pagination, de-duplication, next-page error keeps the list).
- **TrailerBloc**: `TrailerRequested` fetches the YouTube key. States: loading, ready, unavailable, failure.
- **TrailerListener**: reacts to `TrailerBloc` and calls the native bridge, or shows a SnackBar on failure.
- **MovieRepository** is the only thing the Blocs know about; Dio stays inside the data layer.

## Native bridge contract

| | |
|---|---|
| Channel | `com.vipin.movies/bridge` |
| Method | `openTrailer` |
| Arguments | `movieId: int`, `title: String`, `youtubeKey: String?` |

`youtubeKey` is `null` when TMDB has no YouTube trailer for the movie.
The native side should close the Flutter screen and show the trailer screen.
When running standalone there is no native handler, so the call is only logged.

### Design decision: who fetches the trailer key?

The Flutter module calls `/movie/{id}/videos` and sends only the YouTube key
to native. The TMDB key therefore lives in one place, and the native apps
need no networking code or API key.

## Tests

```bash
flutter test                                     # unit + widget tests
flutter test integration_test -d <device-id>     # integration tests (simulator/emulator)
```

| Type | Covers |
|---|---|
| Unit | AppConfig, Movie / PagedMovies, MovieApiClient (mocked Dio), MovieRepository, MoviesBloc, TrailerBloc, NativeBridge, createDio |
| Widget | MovieCard, MoviesPage (all states, pagination), TrailerListener, MoviesApp |
| Integration | Full flow with mocked repository: list, tap to trailer, no trailer, trailer error, retry, next page |

### TDD

The git history follows red, green pairs: a `test:` commit that fails,
followed by a `feat:` commit that makes it pass. Integration tests were added
after the app was complete, so they are regression tests rather than red-first.

## Libraries

`flutter_bloc`, `bloc_concurrency`, `equatable`, `dio`, and for tests
`bloc_test`, `mocktail`, `integration_test`.

## Screenshots

(add: standalone list, error state)