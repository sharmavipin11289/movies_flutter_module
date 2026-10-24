import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_flutter_module/core/network/api_exception.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:movies_flutter_module/features/movies/data/models/movie.dart';
import 'package:movies_flutter_module/features/movies/data/repositories/movie_repository.dart';

part 'trailer_event.dart';
part 'trailer_state.dart';

class TrailerBloc extends Bloc<TrailerEvent, TrailerState> {
  TrailerBloc({required this.repository}) : super(const TrailerInitial()) {
    on<TrailerRequested>(_onTrailerRequested, transformer: droppable());
  }

  final MovieRepository repository;

  Future<void> _onTrailerRequested(
    TrailerRequested event,
    Emitter<TrailerState> emit,
  ) async {
    emit(const TrailerLoading());
    try {
      final key = await repository.getTrailerKey(event.movie.id);
      if (key == null) {
        emit(TrailerUnavailable(event.movie));
      } else {
        emit(TrailerReady(movie: event.movie, youtubeKey: key));
      }
    } on ApiException catch (e) {
      emit(TrailerFailure(e.message));
    }
  }
}
