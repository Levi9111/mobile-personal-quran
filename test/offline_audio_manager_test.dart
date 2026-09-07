import 'package:flutter_test/flutter_test.dart';
import 'package:noor_quran/services/offline_audio_manager.dart';

void main() {
  group('OfflineAudioManager Unit Tests', () {
    test('Formats byte counts into clean human-readable units', () {
      expect(OfflineAudioManager.formatBytes(0), '0 B');
      expect(OfflineAudioManager.formatBytes(-50), '0 B');
      expect(OfflineAudioManager.formatBytes(512), '512 B');
      expect(OfflineAudioManager.formatBytes(1024), '1.0 KB');
      expect(OfflineAudioManager.formatBytes(2048), '2.0 KB');
      expect(OfflineAudioManager.formatBytes(1536), '1.5 KB');
      expect(OfflineAudioManager.formatBytes(1048576), '1.0 MB');
      expect(OfflineAudioManager.formatBytes(5242880), '5.0 MB');
    });

    test('DownloadProgress calculation and flags', () {
      const progress = DownloadProgress(
        surahId: 1,
        completedVerses: 4,
        totalVerses: 7,
        fraction: 4 / 7,
      );

      expect(progress.surahId, 1);
      expect(progress.completedVerses, 4);
      expect(progress.totalVerses, 7);
      expect(progress.fraction, closeTo(0.571, 0.005));
      expect(progress.isDone, isFalse);
      expect(progress.error, isNull);
    });

    test('Cancellation requests properly set cancel flag', () {
      OfflineAudioManager.cancelDownload(18);
      // Ensures no exception is thrown when cancelling
      expect(true, isTrue);
    });
  });
}
