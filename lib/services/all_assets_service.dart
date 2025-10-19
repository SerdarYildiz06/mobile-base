import 'dart:math';
import 'dart:ui';

import 'package:cleaner_app/models/month_entry.dart';
import 'package:photo_manager/photo_manager.dart';

class AllAssetsService {
  Future<Map<String, List<AssetEntity>>> findSimilarScreenshots(
    List<AssetEntity> screenshotsAssets,
    Function(double) updateProgress,
  ) async {
    if (screenshotsAssets.isEmpty) return {};

    Map<String, List<AssetEntity>> similarGroups = {};
    int groupId = 0;

    // Sort by creation date to optimize comparison
    List<AssetEntity> sortedScreenshots = List.from(screenshotsAssets);
    sortedScreenshots.sort((a, b) => a.createDateTime.compareTo(b.createDateTime));

    // Pre-fetch all metadata to avoid multiple async calls
    Map<AssetEntity, Size> assetSizes = {};
    Map<AssetEntity, int> assetFileSizes = {};

    for (var asset in sortedScreenshots) {
      Size? size = await asset.size;
      assetSizes[asset] = size;
      assetFileSizes[asset] = size.width.toInt() * size.height.toInt(); // Use pixel count as size approximation
    }

    // Compare each screenshot with others
    for (int i = 0; i < sortedScreenshots.length; i++) {
      AssetEntity baseAsset = sortedScreenshots[i];

      // Skip if already in a group
      if (similarGroups.values.any((group) => group.contains(baseAsset))) continue;

      // Skip if we don't have metadata
      if (!assetSizes.containsKey(baseAsset)) continue;

      List<AssetEntity> currentGroup = [baseAsset];
      DateTime baseDate = baseAsset.createDateTime;
      Size baseSize = assetSizes[baseAsset]!;
      int baseFileSize = assetFileSizes[baseAsset]!;

      // Only compare with screenshots taken within 5 minutes
      for (int j = i + 1; j < sortedScreenshots.length; j++) {
        AssetEntity compareAsset = sortedScreenshots[j];

        // Break if time difference is more than 5 minutes
        if (compareAsset.createDateTime.difference(baseDate).inMinutes.abs() > 5) break;

        // Skip if already in a group or no metadata
        if (similarGroups.values.any((group) => group.contains(compareAsset))) continue;
        if (!assetSizes.containsKey(compareAsset)) continue;

        // Compare metadata
        Size compareSize = assetSizes[compareAsset]!;
        int compareFileSize = assetFileSizes[compareAsset]!;

        // Check if dimensions match exactly
        bool sameDimensions = baseSize.width == compareSize.width && baseSize.height == compareSize.height;

        if (sameDimensions) {
          // Compare file sizes (should be within 10% difference)
          double sizeDiffPercent = (baseFileSize - compareFileSize).abs() / baseFileSize * 100;

          if (sizeDiffPercent <= 10) {
            currentGroup.add(compareAsset);
          }
        }
      }

      // Only create a group if there are similar screenshots
      if (currentGroup.length > 1) {
        similarGroups['group_${groupId++}'] = currentGroup;
      }

      // Update progress
      double _progress = (i + 1) / sortedScreenshots.length;
      updateProgress(_progress);
    }

    return similarGroups;
  }

  Future<Map<String, List<AssetEntity>>> findSimilarPhotos(
    List<AssetEntity> photos,
    Function(double) updateProgress,
  ) async {
    if (photos.isEmpty) return {};

    Map<String, List<AssetEntity>> similarGroups = {};
    int groupId = 0;

    // Filter out non-image assets
    List<AssetEntity> imageAssets = photos.where((asset) => asset.type == AssetType.image).toList();

    // Sort by creation date to optimize comparison
    imageAssets.sort((a, b) => a.createDateTime.compareTo(b.createDateTime));

    // Pre-fetch all metadata to avoid multiple async calls
    Map<AssetEntity, Size> assetSizes = {};
    Map<AssetEntity, int> assetFileSizes = {};

    for (var asset in imageAssets) {
      Size? size = await asset.size;
      assetSizes[asset] = size;
      assetFileSizes[asset] = size.width.toInt() * size.height.toInt();
    }

    // Compare each photo with others
    for (int i = 0; i < imageAssets.length; i++) {
      AssetEntity baseAsset = imageAssets[i];

      // Skip if already in a group
      if (similarGroups.values.any((group) => group.contains(baseAsset))) continue;

      // Skip if we don't have metadata
      if (!assetSizes.containsKey(baseAsset)) continue;

      List<AssetEntity> currentGroup = [baseAsset];
      DateTime baseDate = baseAsset.createDateTime;
      Size baseSize = assetSizes[baseAsset]!;
      int baseFileSize = assetFileSizes[baseAsset]!;

      // Compare with photos taken within 30 seconds (burst photos, HDR variants etc.)
      for (int j = i + 1; j < imageAssets.length; j++) {
        AssetEntity compareAsset = imageAssets[j];

        // Break if time difference is more than 30 seconds
        if (compareAsset.createDateTime.difference(baseDate).inSeconds.abs() > 30) break;

        // Skip if already in a group or no metadata
        if (similarGroups.values.any((group) => group.contains(compareAsset))) continue;
        if (!assetSizes.containsKey(compareAsset)) continue;

        // Compare metadata
        Size compareSize = assetSizes[compareAsset]!;
        int compareFileSize = assetFileSizes[compareAsset]!;

        // Check if dimensions are similar (allow small differences for cropped/edited photos)
        bool similarDimensions = _areDimensionsSimilar(baseSize, compareSize);

        if (similarDimensions) {
          // Compare file sizes (should be within 20% difference - more lenient than screenshots)
          double sizeDiffPercent = (baseFileSize - compareFileSize).abs() / baseFileSize * 100;

          if (sizeDiffPercent <= 20) {
            currentGroup.add(compareAsset);
          }
        }
      }

      // Only create a group if there are similar photos
      if (currentGroup.length > 1) {
        similarGroups['group_${groupId++}'] = currentGroup;
      }

      // Update progress
      double _progress = (i + 1) / imageAssets.length;
      updateProgress(_progress);
    }

    return similarGroups;
  }

  Future<Map<String, List<AssetEntity>>> findSimilarVideos(
    List<AssetEntity> videos,
    Function(double) updateProgress,
  ) async {
    if (videos.isEmpty) return {};

    Map<String, List<AssetEntity>> similarGroups = {};
    int groupId = 0;

    // Filter out non-video assets and sort by creation date
    List<AssetEntity> videoAssets = videos.where((asset) => asset.type == AssetType.video).toList();
    videoAssets.sort((a, b) => a.createDateTime.compareTo(b.createDateTime));

    // Pre-fetch all metadata to avoid multiple async calls
    Map<AssetEntity, Size> videoSizes = {};
    Map<AssetEntity, Duration> videoDurations = {};

    for (var video in videoAssets) {
      Size size = await video.size;
      videoSizes[video] = size;
      videoDurations[video] = Duration(seconds: video.duration);
    }

    // Compare each video with others
    for (int i = 0; i < videoAssets.length; i++) {
      AssetEntity baseVideo = videoAssets[i];

      // Skip if already in a group
      if (similarGroups.values.any((group) => group.contains(baseVideo))) continue;

      // Skip if we don't have metadata
      if (!videoSizes.containsKey(baseVideo)) continue;

      List<AssetEntity> currentGroup = [baseVideo];
      DateTime baseDate = baseVideo.createDateTime;
      Size baseSize = videoSizes[baseVideo]!;
      Duration baseDuration = videoDurations[baseVideo]!;

      // Compare with videos taken within 2 minutes (multiple takes of same video)
      for (int j = i + 1; j < videoAssets.length; j++) {
        AssetEntity compareVideo = videoAssets[j];

        // Break if time difference is more than 2 minutes
        if (compareVideo.createDateTime.difference(baseDate).inMinutes.abs() > 2) break;

        // Skip if already in a group or no metadata
        if (similarGroups.values.any((group) => group.contains(compareVideo))) continue;
        if (!videoSizes.containsKey(compareVideo)) continue;

        // Compare metadata
        Size compareSize = videoSizes[compareVideo]!;
        Duration compareDuration = videoDurations[compareVideo]!;

        // Check if dimensions are similar
        bool similarDimensions = _areDimensionsSimilar(baseSize, compareSize);

        // Check if durations are similar (within 3 seconds)
        bool similarDuration = (baseDuration.inSeconds - compareDuration.inSeconds).abs() <= 3;

        if (similarDimensions && similarDuration) {
          currentGroup.add(compareVideo);
        }
      }

      // Only create a group if there are similar videos
      if (currentGroup.length > 1) {
        similarGroups['group_${groupId++}'] = currentGroup;
      }

      // Update progress
      double _progress = (i + 1) / videoAssets.length;
      updateProgress(_progress);
    }

    return similarGroups;
  }

  bool _areDimensionsSimilar(Size a, Size b) {
    // Allow for small differences in dimensions (e.g., slightly cropped photos)
    const double tolerance = 0.1; // 10% tolerance

    double widthDiff = (a.width - b.width).abs() / a.width;
    double heightDiff = (a.height - b.height).abs() / a.height;

    // Check if dimensions are similar within tolerance
    bool similarSize = widthDiff <= tolerance && heightDiff <= tolerance;

    // Also check if aspect ratios are similar
    double aspectRatioA = a.width / a.height;
    double aspectRatioB = b.width / b.height;
    double aspectRatioDiff = (aspectRatioA - aspectRatioB).abs() / aspectRatioA;
    bool similarAspectRatio = aspectRatioDiff <= tolerance;

    return similarSize || similarAspectRatio;
  }

  Future<Map<String, List<AssetEntity>>> findDuplicatePhotos(
    List<AssetEntity> photos,
    Function(double) updateProgress,
  ) async {
    if (photos.isEmpty) return {};

    Map<String, List<AssetEntity>> duplicateGroups = {};

    // Filter out non-image assets
    List<AssetEntity> imageAssets = photos.where((asset) => asset.type == AssetType.image).toList();

    // Group assets by a composite key of size and id
    Map<String, List<AssetEntity>> groups = {};
    for (var asset in imageAssets) {
      final key = '${asset.width}x${asset.height}-${asset.id}';
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(asset);
    }

    // Find groups with more than one asset
    groups.forEach((key, group) {
      if (group.length > 1) {
        duplicateGroups[key] = group;
      }
    });

    // Update progress (optional, as this is faster)
    updateProgress(1.0);

    return duplicateGroups;
  }

  Future<List<MonthEntry>> getAvailableMonths(List<AssetEntity> allAssets) async {
    List<MonthEntry> availableMonths = [];
    final Map<String, int> monthToCount = {};

    for (final a in allAssets) {
      final dt = a.createDateTime;
      final key = '${dt.year}-${dt.month}';
      monthToCount.update(key, (v) => v + 1, ifAbsent: () => 1);
    }

    final List<MonthEntry> list = monthToCount.entries.map((e) {
      final parts = e.key.split('-');
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return MonthEntry(year: y, month: m, count: e.value);
    }).toList();

    list.sort((a, b) {
      if (a.year != b.year) return b.year.compareTo(a.year);
      return b.month.compareTo(a.month);
    });
    availableMonths.addAll(list);
    return availableMonths;
  }

  Future<List<AssetEntity>> getRandomAssets(List<AssetEntity> allAssets, int count) async {
    final random = Random();
    final List<AssetEntity> randomAssets = [];
    for (int i = 0; i < count; i++) {
      randomAssets.add(allAssets[random.nextInt(allAssets.length)]);
    }
    return randomAssets;
  }
}
