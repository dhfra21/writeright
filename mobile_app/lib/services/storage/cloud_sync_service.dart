// Optional cloud sync service
abstract class CloudSyncService {
  Future<void> syncProgress(String userId);
  Future<void> enableSync();
  Future<void> disableSync();
}
