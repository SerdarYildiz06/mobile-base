import 'package:photo_manager/photo_manager.dart';

class AlbumModel {
  final String name;
  final int count;
  final AssetPathEntity album;
  final AssetEntity thumbnail;

  AlbumModel({required this.name, required this.count, required this.album, required this.thumbnail});
}
