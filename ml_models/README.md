# ML Models Directory

This directory contains pretrained machine learning models used for handwriting evaluation.

## Structure

- `pretrained/` - Pretrained ML model files (.tflite or .onnx)
- `templates/` - Reference templates for letters and numbers

## Model Requirements

- **Format**: TensorFlow Lite (.tflite) or ONNX (.onnx)
- **Input**: Normalized stroke data (x, y coordinates)
- **Output**: Similarity score and correctness metrics
- **Size**: Optimized for mobile deployment (< 10MB recommended)

## Model Sources

Consider these pretrained handwriting recognition models:

1. **TensorFlow Lite Models**
   - TensorFlow Hub handwriting models
   - Custom trained models converted to TFLite

2. **ONNX Models**
   - ONNX Model Zoo
   - Converted PyTorch/TensorFlow models

## Usage

Models are loaded at app startup and used for on-device inference only.
No training or fine-tuning is performed in the app.

## Model Versioning

When updating models:
1. Keep old versions for rollback capability
2. Update model version in app configuration
3. Test thoroughly before deployment
