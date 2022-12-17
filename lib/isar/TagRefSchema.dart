
import 'package:isar/isar.dart';

part 'TagRefSchema.g.dart';
@Collection()
class ImageData {
  Id id = Isar.autoIncrement;

  String? srcUrl;
  final IsarLinks<Tag> tagLinks = IsarLinks<Tag>();
}

@Collection()
class Tag {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String? tagName;

  final IsarLinks<ImageData> imageDataLinks = IsarLinks<ImageData>();
}

@Collection()
class Pin {
  Id id = Isar.autoIncrement;

  int? imageId;
}