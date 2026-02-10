// ONNX Runtime implementation
import 'ml_inference_service.dart';

class ONNXService implements MLInferenceService {
  @override
  Future<void> loadModel() async {
    // TODO: Implement ONNX model loading
  }

  @override
  Future<HandwritingScore> evaluateHandwriting(String character, List<Point> strokes) async {
    // TODO: Implement ONNX inference
    throw UnimplementedError();
  }
}
