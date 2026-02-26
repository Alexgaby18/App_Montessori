import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:path_provider/path_provider.dart';

class PictogramPrefetchService {
  static const String _markerFileName = '.pictograms_prefetched_v1';

  static Future<void> runOnFirstInstall() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final markerFile = File('${dir.path}/$_markerFileName');

      if (await markerFile.exists()) {
        return;
      }

      await prefetchAllAppPictograms();
      await markerFile.writeAsString(DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error en prefetch inicial de pictogramas: $e');
    }
  }
}
