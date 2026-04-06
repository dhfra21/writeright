# ML Evaluation — Usage & Behaviour

## Overview

Handwriting evaluation uses two concrete implementations of the `MLInferenceService` abstract interface, both located in `mobile_app/lib/services/ml_inference/`.

## Implementations

### 1. DistanceBasedService (default, always active)

Fully on-device. No internet or API key required.

**How it works:**
- Normalises the child's drawn stroke coordinates
- Compares them to reference character templates using Dynamic Time Warping (DTW) and Hausdorff distance
- Returns a similarity score (0.0–1.0)

**When to use:** Always — this is the primary evaluator and the offline fallback.

### 2. GroqVisionService (optional, cloud)

Sends a snapshot of the canvas to the Groq Vision API for richer evaluation.

**Requires:** `GROQ_API_KEY` passed via `--dart-define` at build time.

**How it works:**
- Captures canvas as an image
- Posts to Groq Vision endpoint
- Parses score and natural-language feedback from the response

**When to use:** When an API key is configured and the device is online.

## Output Format

Both services return a `HandwritingResult`:

```dart
class HandwritingResult {
  double score;       // 0.0 – 1.0 similarity
  int stars;          // 0–3 (derived from score thresholds)
  String feedback;    // Human-readable feedback for the child
}
```

Star thresholds:
- 3 stars: score >= 0.85
- 2 stars: score >= 0.65
- 1 star:  score >= 0.40
- 0 stars: score < 0.40

## Evaluation Flow

```
DrawingCanvas captures strokes
  → MLInferenceService.evaluate(character, strokes)
  → DistanceBasedService always runs
  → GroqVisionService runs if key is present and device is online
  → Best available score used
  → GamificationService converts score to XP + stars + badges
  → TtsService speaks feedback to child
  → ProgressService syncs session to backend
```

## What the Evaluator Does NOT Do

- Does not learn or retrain from user input
- Does not store or transmit stroke data
- Does not provide stroke-by-stroke breakdown (DistanceBasedService gives aggregate score only)
- Does not recognise arbitrary text — only compares to known character templates

## Adding a New Inference Engine

1. Create a new class that extends `MLInferenceService`
2. Implement the `evaluate(String character, List<Offset> strokes)` method
3. Return a `HandwritingResult`
4. Inject the new service wherever `MLInferenceService` is provided
