import 'package:flutter/foundation.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';

class PictogramPrefetchProgress {
  final int completed;
  final int total;

  const PictogramPrefetchProgress({
    required this.completed,
    required this.total,
  });
}

class PictogramPrefetchService {
  static final ValueNotifier<PictogramPrefetchProgress?> progress =
      ValueNotifier<PictogramPrefetchProgress?>(null);
  static Future<void>? _running;

  static Future<void> runOnStartup() {
    return _running ??= _run().whenComplete(() => _running = null);
  }

  static Future<void> _run() async {
    try {
      await prefetchAllAppPictograms(
        onProgress: (completed, total) {
          progress.value = PictogramPrefetchProgress(
            completed: completed,
            total: total,
          );
        },
      );
    } catch (e) {
      debugPrint('Error en prefetch inicial de pictogramas: $e');
    } finally {
      progress.value = null;
    }
  }
}
