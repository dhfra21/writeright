# ML Model Usage & Limitations

## Model Purpose

The pretrained ML models in this application are used **exclusively** for:
- Evaluating handwriting shape similarity
- Providing basic correctness feedback
- Scoring handwriting quality (for gamification)

## Model Limitations

### What the Model Does

✅ Compares drawn character to reference template
✅ Provides similarity score (0.0 - 1.0)
✅ Basic shape recognition

### What the Model Does NOT Do

❌ Recognize arbitrary handwriting
❌ Learn from user input
❌ Improve over time
❌ Provide detailed stroke-by-stroke feedback
❌ Detect all handwriting errors

## Model Input/Output

### Input Format

- Normalized stroke coordinates (x, y)
- Character identifier (which letter/number)
- Preprocessing: Size normalization, centering

### Output Format

```dart
class HandwritingScore {
  double similarity;      // 0.0 - 1.0
  double correctness;     // 0.0 - 1.0
  String feedback;        // Simple feedback message
}
```

## Model Selection Criteria

When choosing a pretrained model:

1. **Size**: < 10MB for mobile deployment
2. **Latency**: < 500ms inference time
3. **Accuracy**: > 80% similarity detection
4. **Format**: TFLite or ONNX compatible
5. **License**: Compatible with app distribution

## Model Updates

- Models are updated via app updates only
- No over-the-air model updates
- Version checking for model compatibility
- Rollback capability for problematic models

## Performance Considerations

- Models run on CPU (GPU optional for better performance)
- Inference happens asynchronously
- Results cached for repeated evaluations
- Error handling for model loading failures

## Future Model Upgrades

If upgrading to a better model:

1. Test thoroughly on test devices
2. Maintain backward compatibility
3. Update model version in config
4. Document changes in release notes
