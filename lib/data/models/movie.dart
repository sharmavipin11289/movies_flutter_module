import 'package:equatable/equatable.dart';
import 'package:movies_flutter_module/core/config/api_constants.dart';

class Movie extends Equatable {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
    );
  }

  final int id;
  final String title;
  final String overview;
  final String? posterPath;

  String? get posterUrl =>
      posterPath == null ? null : '${ApiConstants.imageBaseUrl}$posterPath';

  @override
  List<Object?> get props => [id, title, overview, posterPath];
}
