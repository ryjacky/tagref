import 'dart:io';

import 'package:isar/isar.dart';
import 'package:tagref/isar/IsarHelper.dart';
import 'package:tagref/isar/TagRefSchema.dart';
import 'package:test/test.dart';
void main() async {
  await Isar.initializeIsarCore(download: true);

  test("Insert/Query image with IsarHelper", () async {
    IsarHelper isarHelper = IsarHelper(test: true);
    await isarHelper.initializeIsarDB();

    await isarHelper.putImage("https://picsum.photos/seed/picsum/200/300");
    List<ImageData> images = await isarHelper.getImageByUrl("https://picsum.photos/seed/picsum/200/300");

    expect(images.length, greaterThanOrEqualTo(1));
  });

  test("Query/Delete image with IsarHelper", () async {
    IsarHelper isarHelper = IsarHelper(test: true);
    await isarHelper.initializeIsarDB();

    List<ImageData> images = await isarHelper.getImageByUrl("https://picsum.photos/seed/picsum/200/300");

    bool deleteSuccess = true;
    for (int i = 0; i < images.length; i++){
      deleteSuccess = deleteSuccess && await isarHelper.deleteImage(images[i].id);
    }

    expect(
        deleteSuccess,
        equals(true)
    );
  });

  test("Query all images", () async {
    IsarHelper isarHelper = IsarHelper(test: true);
    await isarHelper.initializeIsarDB();

    await isarHelper.putImage("https://picsum.photos/seed/picsum/200/300");
    await isarHelper.putImage("https://picsum.photos/seed/picsum/200/300");
    await isarHelper.putImage("https://picsum.photos/seed/picsum/200/300");

    int qLength = isarHelper.getAllImages().length;

    List<ImageData> images = await isarHelper.getImageByUrl("https://picsum.photos/seed/picsum/200/300");

    bool deleteSuccess = true;
    for (int i = 0; i < images.length; i++){
      deleteSuccess = deleteSuccess && await isarHelper.deleteImage(images[i].id);
    }

    expect(
        qLength,
        equals(3)
    );
  });

  test("Insert/Query tag with IsarHelper", () async {
    IsarHelper isarHelper = IsarHelper(test: true);
    await isarHelper.initializeIsarDB();

    await isarHelper.putTag("tag1");
    await isarHelper.putTag("tag1");
    await isarHelper.putTag("tag2");
    await isarHelper.putTag("tag3");
    List<Tag> tags = await isarHelper.getAllTags();

    expect(tags.length, equals(3));
  });

  test("Add tag", () async {
    IsarHelper isarHelper = IsarHelper(test: true);
    await isarHelper.initializeIsarDB();

    await isarHelper.putTag("tag1");
    await isarHelper.putTag("tag1");
    await isarHelper.putTag("tag2");
    await isarHelper.putTag("tag3");
    List<Tag> tags = await isarHelper.getAllTags();

    expect(tags.length, equals(3));
  });

  test("Add tag to images", () async {
    IsarHelper isarHelper = IsarHelper(test: true);
    await isarHelper.initializeIsarDB();

    await isarHelper.putImage("https://picsum.photos/seed/picsum/200/300");
    await isarHelper.putImage("https://picsum.photos/seed/picsum/200/300");
    await isarHelper.putImage("https://picsum.photos/seed/picsum/200/300");

    List<ImageData> allImg = isarHelper.getAllImages();
    await isarHelper.addTagToImage(allImg[0].id, "tag1");
    await isarHelper.addTagToImage(allImg[1].id, "tag1");
    await isarHelper.addTagToImage(allImg[2].id, "tag2");

    expect(
        isarHelper.getAllImages().first.tagLinks.first.tagName == ("tag1") &&
            isarHelper.getAllImages()[1].tagLinks.first.tagName == ("tag1") &&
            isarHelper.getAllImages()[2].tagLinks.first.tagName == ("tag2"),
        equals(true)
    );
  });

  test("Get images by tag", () async {
    IsarHelper isarHelper = IsarHelper(test: true);
    await isarHelper.initializeIsarDB();

    int qLength = isarHelper.getImagesByTags(["tag1"]).length;
    List<ImageData> images = isarHelper.getAllImages();

    expect(
        qLength,
        equals(2)
    );

  });

  test("Remove tag from images", () async {
    IsarHelper isarHelper = IsarHelper(test: true);
    await isarHelper.initializeIsarDB();

    List<ImageData> images = isarHelper.getAllImages();
    await isarHelper.removeTagFromImage(images.first.id, "tag1");

    int qLength = isarHelper.getImagesByTags(["tag1"]).length;

    bool deleteSuccess = true;
    for (int i = 0; i < images.length; i++){
      deleteSuccess = deleteSuccess && await isarHelper.deleteImage(images[i].id);
    }

    expect(
        qLength,
        equals(1)
    );

  });

  test("Delete tag globally", () async {
    // IsarHelper isarHelper = IsarHelper(test: true);
    // await isarHelper.initializeIsarDB();
    //
    // List<ImageData> images = isarHelper.getAllImages();
    // await isarHelper.removeTagFromImage(images.first.id, "tag1");
    //
    // int qLength = isarHelper.getImagesByTags(["tag1"]).length;
    //
    // bool deleteSuccess = true;
    // for (int i = 0; i < images.length; i++){
    //   deleteSuccess = deleteSuccess && await isarHelper.deleteImage(images[i].id);
    // }
    //
    // expect(
    //     qLength,
    //     equals(1)
    // );
  });

}