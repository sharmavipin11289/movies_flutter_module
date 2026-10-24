part of 'trailer_bloc.dart';

sealed class TrailerEvent extends Equatable {
  const TrailerEvent();

  @override
  List<Object?> get props => [];
}

final class TrailerRequested extends TrailerEvent {
  const TrailerRequested(this.movie);

  final Movie movie;

  @override
  List<Object?> get props => [movie];
}
