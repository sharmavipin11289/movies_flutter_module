import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_flutter_module/core/platform/native_bridge.dart';
import 'package:movies_flutter_module/features/movies/presentation/bloc/trailer_bloc.dart';

class TrailerListener extends StatelessWidget {
  const TrailerListener({required this.bridge, required this.child, super.key});

  final NativeBridge bridge;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TrailerBloc, TrailerState>(
      listener: (context, state) {
        switch (state) {
          case TrailerReady(:final movie, :final youtubeKey):
            bridge.openTrailer(
              movieId: movie.id,
              title: movie.title,
              youtubeKey: youtubeKey,
            );
          case TrailerUnavailable(:final movie):
            bridge.openTrailer(movieId: movie.id, title: movie.title);
          case TrailerFailure(:final message):
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          case TrailerInitial():
          case TrailerLoading():
            break;
        }
      },
      child: child,
    );
  }
}
