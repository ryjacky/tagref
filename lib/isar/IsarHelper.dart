import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/isar/TagRefSchema.dart';

class IsarHelper {
  final String _eIsarNotOpened = "Isar database not opened, please call IsarHelper.initializeIsarDB() first.";

  final String _dbFileName = "data";
  late final String _dbName;

  Isar? _isar;

  IsarHelper({bool test = false}) {
    _dbName = test ? "tagrefTest" : "tagrefRoot";
  }

  closeAll() async {
    if (_isar == null) {
      throw Exception(_eIsarNotOpened);
    }

    await _isar!.close();
  }

  /// Open the database if not yet opened, attach to the opened instance otherwise.
  Future<void> openDB () async {
    _isar = Isar.getInstance(_dbName);

    _isar ??= Isar.openSync(
          [ImageDataSchema, TagSchema, PinSchema], directory: await getDBDir(), name: _dbName);
  }

  /// Retrieve the database path, this will create the specified directory
  /// if it does not exist.
  ///
  /// Returns a string containing the database path.
  Future<String> getDBDir() async {
    Directory dbDir = Directory(join(
        (await getApplicationSupportDirectory()).path,
        _dbFileName));

    if (!(await dbDir.exists())){
      dbDir.create();
    }

    return dbDir.path;
  }

  Future<String> getDBUrl() async {
    return join((await getDBDir()), _dbName, ".isar");
  }

  /// Insert/Update an image-data into the given database with the source
  /// URL equals to [srcUrl], database will be pushed to Google Drive when
  /// [googleApiHelper] is provided.
  ///
  /// Returns the image id inserted/updated when success, otherwise, returns -1.
  Future<int> putImage(String srcUrl, {GoogleApiHelper? googleApiHelper}) async {
    if (_isar == null) {
      throw Exception(_eIsarNotOpened);
    }

    final image = ImageData()..srcUrl = srcUrl;

    int id = -1;
    await _isar!.writeTxn(() async {
      id = await _isar!.imageData.put(image);
    });

    if (googleApiHelper != null) {
      if (await googleApiHelper.pushDB()){
        return id;
      } else {
        return -1;
      }
    }

    return id;
  }

  /// Insert/Update a tag with the given name, database will be pushed
  /// to Google Drive when [googleApiHelper] is provided.
  ///
  /// Returns the tag id inserted/updated when success, otherwise, returns -1.
  Future<int> putTag(String tagName, {GoogleApiHelper? googleApiHelper}) async {
    if (_isar == null) {
      throw Exception(_eIsarNotOpened);
    }

    final tag = Tag()..tagName = tagName;

    // Tag already existed, return -1
    if (_isar!.tags.getByTagNameSync(tagName) != null) {
      return -1;
    }

    int id = -1;
    await _isar!.writeTxn(() async {
      id = await _isar!.tags.put(tag);
    });

    if (googleApiHelper != null) {
      if (await googleApiHelper.pushDB()){
        return id;
      } else {
        return -1;
      }
    }

    return id;
  }

  /// Add tag to image, if the tag does not exist, create it and add the tag
  /// to image.
  ///
  /// Return true when success, false otherwise.
  Future<bool> addTagToImage(int imgId, String tagName) async {
    if (_isar == null) {
      throw Exception(_eIsarNotOpened);
    }

    ImageData? imgData = await _isar!.imageData.get(imgId);

    Tag imgTag =
        (await _isar!.tags.getByTagName(tagName)) ?? Tag()..tagName = tagName;
    // Skip if imgId does not exist
    // Skip when the tag exists in the image data
    if (imgData == null || imgData.tagLinks.contains(imgTag)) return false;

    // Add image to tag
    imgTag.imageDataLinks.add(imgData);

    // Add tag to image
    imgData.tagLinks.add(imgTag);

    // Update the tag and image data
    return await _isar!.writeTxn(() async {
      await _isar!.tags.put(imgTag);

      await imgTag.imageDataLinks.save();
      await imgData.tagLinks.save();
      return true;
    });
  }

  /// Delete an image-data with given [imgId] from the given database.
  ///
  /// Returns true when delete is success, otherwise, returns false. Always
  /// return true when running on web.
  Future<bool> deleteImage(int imgId) async {
    if (_isar == null) {
      throw Exception(_eIsarNotOpened);
    }

    return await _isar!.writeTxn(() async {
       return await _isar!.imageData.delete(imgId);
    });
  }

  /// Retrieve a list of image-data from the given database with source URL
  /// equal to [srcUrl].
  ///
  /// Returns a list of image-data, empty list otherwise.
  Future<List<ImageData>> getImageByUrl(String srcUrl) async {
    if (_isar == null) {
      throw Exception(_eIsarNotOpened);
    }

    return await _isar!.imageData.filter().srcUrlEqualTo(srcUrl).findAll();
  }

  /// Retrieve a list of image-data from the database with given tag in [tags]
  ///
  /// Returns a list of existing image-data, null otherwise.
  Future<List<ImageData>> getImagesByTags(List<String> tags) async {
    if (_isar == null) {
      throw Exception(_eIsarNotOpened);
    }

    List<ImageData> allImageData = <ImageData>[];
    for (var tag in tags){
      if (_isar!.tags.getByTagNameSync(tag) != null) {
        allImageData.addAll(
            _isar!.tags.getByTagNameSync(tag)!.imageDataLinks.toList());
      }
    }

    return allImageData;
  }

  /// Retrieve a list of all image-data from the database
  ///
  /// Returns a list of existing image-data, null otherwise.
  Future<List<ImageData>> getAllImages() async {
    if (_isar == null) {
      throw Exception(_eIsarNotOpened);
    }
    
    List<ImageData> existingImages = <ImageData>[];
    List<ImageData?> images = await _isar!.imageData.getAll(
        [for (int i = 0; i < await _isar!.imageData.getSize(); i++) i]
    );

    // Add existing (non-null fields) images to return
    for (int i = 0; i < images.length; i++){
      if (images[i] != null){
        existingImages.add(images[i]!);
      }
    }

    return existingImages;
  }

  /// Retrieve a list of all tags
  ///
  /// Returns a list of existing image-data, null otherwise.
  Future<List<Tag>> getAllTags(bool excludeLeaf) async {
    if (_isar == null) {
      throw Exception(_eIsarNotOpened);
    }

    List<Tag> existingTags = <Tag>[];
    List<Tag?> tags = await _isar!.tags.getAll(
        [for (int i = 0; i < await _isar!.tags.getSize(); i++) i]
    );

    // Remove non-existing tag (by any chance)
    for (int i = 0; i < tags.length; i++){
      if (tags[i] != null && (!excludeLeaf || tags[i]!.imageDataLinks.isNotEmpty)){
        existingTags.add(tags[i]!);
      }
    }

    return existingTags;
  }

  Future<bool> removeTagFromImage(int imgId, String tagName) async {
    if (_isar == null) {
      throw Exception(_eIsarNotOpened);
    }

    // skip if ImageData of imdId or tag of tagName do not exist or ImageData
    // does not have tag of tagName
    ImageData? imgData = await _isar!.imageData.get(imgId);
    Tag? tag = await _isar!.tags.getByTagName(tagName);

    if (imgData == null || tag == null || !imgData.tagLinks.contains(tag)) return false;

    // remove tag from image
    imgData.tagLinks.remove(tag);

    // remove image from tag
    tag.imageDataLinks.remove(imgData);

    await _isar!.writeTxn(() async {
      await imgData.tagLinks.save();
      await tag.imageDataLinks.save();

    });

    return true;
  }

  /// Get image data of id from local database
  ///
  /// Return ImageData when success, return null when image data of id is not
  /// found
  Future<ImageData?> getImageData(int id) async {
    if (_isar == null) {
      throw Exception(_eIsarNotOpened);
    }

    return await _isar!.imageData.get(id);
  }

  Future<bool> deleteTag(String tagName) async {
    if (_isar == null) {
      throw Exception(_eIsarNotOpened);
    }

    // Skip if tag of tagName does not exist
    Tag? tagToDel = await _isar!.tags.getByTagName(tagName);
    if (tagToDel == null) return false;

    // remove tag of tagName from every imageData
    List<ImageData> connectedImageData = await getImagesByTags([tagName]);
    for (var imageData in connectedImageData){
      imageData.tagLinks.remove(tagToDel);
    }

    // remove the tag
    tagToDel.imageDataLinks.clear();

    // Apply changes
    await _isar!.writeTxn(() async {
      for (var imageData in connectedImageData){
        await imageData.tagLinks.save();
      }
      await tagToDel.imageDataLinks.save();
      await _isar!.tags.delete(tagToDel.id);
    });

    return true;
  }

}
