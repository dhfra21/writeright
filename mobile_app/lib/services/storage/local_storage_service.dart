// Local storage service for offline-first data persistence
abstract class LocalStorageService {
  Future<void> saveProgress(String userId, ProgressData data);
  Future<ProgressData?> loadProgress(String userId);
}

class ProgressData {
  // TODO: Define progress data structure
}
