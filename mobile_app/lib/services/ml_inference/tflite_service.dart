// TensorFlow Lite implementation
import 'ml_inference_service.dart';

class TFLiteService implements MLInferenceService {
  @override
  Future<void> loadModel() async {
    // TODO: Implement TensorFlow Lite model loading
  }

  @override
  Future<HandwritingScore> evaluateHandwriting(String character, List<Point> strokes) async {
    // TODO: Implement TensorFlow Lite inference
    throw UnimplementedError();
  }
}
