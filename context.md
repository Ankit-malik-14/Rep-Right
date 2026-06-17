# Rep-Right Context & Models Summary

This document serves as a reference for the architectural models and the AI posture detection system currently implemented in the Rep-Right project.

## 1. AI Posture Detection Models

The app uses Apple's Vision framework (`VNDetectHumanBodyPoseRequest` and `VNGeneratePersonSegmentationRequest`) for real-time posture and form analysis. 

### A. Live Exercise Form Detection (`ExerciseDetectionViewModel.swift`)
- **Purpose**: Evaluates user form during active workout exercises.
- **Pipeline**:
  1. `AVCaptureSession` captures frames via the front camera.
  2. Frames are processed using `VNDetectHumanBodyPoseRequest`.
  3. 19 joints are extracted and normalized (Y-axis is flipped to match screen coordinates).
  4. Joint coordinates are used to calculate specific body angles (e.g., knee bend, back straightness) depending on the active exercise ID.
  5. Angles are scored against predefined rules in `ExerciseRuleset.json` (e.g., Plank=1, Squat=3).
  6. A confidence score is calculated: (Rules 80% + Pose Coverage 12% + Joint Confidence 8%).
  7. Feedback is generated (e.g., "Good Form" or "Needs Correction" with specific flags).

### B. Calibration & Reference Curve (`BackContourDetector.swift`)
- **Purpose**: Establishes a baseline for straight back posture before certain exercises.
- **Phases**: `.infoSheet` -> `.detectingPerson` -> `.timer` -> `.analyzing`
- **Pipeline**:
  1. Detects side-profile orientation using facial landmarks (nose vs. ears distances).
  2. Initiates a 3-second timer once the user is positioned correctly sideways.
  3. Uses `VNGeneratePersonSegmentationRequest` to generate a body mask and `VNDetectHumanBodyPoseRequest` for neck/root bounds.
  4. Scans the mask horizontally to plot the contour of the user's back.
  5. Calculates the maximum deviation of the contour from a straight line. If the deviation exceeds 3% of the screen width, it flags "Mistake: Back not straight".

### C. Active-Passive Gate (`BackContourDetector.swift`)
- **Purpose**: Prevent neutral standing from being treated as exercise posture.
- **States**:
  - `idle`: no useful pose has been detected yet.
  - `passive`: the person is standing neutrally and should not be evaluated.
  - `active`: the person is in an exercise-ready posture and should be analyzed.
- **Intended flow**:
  1. Keep the detector in `passive` when the user is just standing.
  2. Skip heavy contour posture checks and rep logic while `passive`.
  3. Move to `active` only after several frames show an intentional workout stance.
  4. Return to `passive` if the user relaxes back into a neutral standing posture.
- **Why it matters**:
  - Reduces false positives from natural standing posture.
  - Stops mild shoulder rounding from being treated as incorrect form.
  - Saves compute by avoiding unnecessary analysis while idle.

---

## 2. Active Workout Session Model (`WorkoutSessionManager.swift`)

- **State Machine (`WorkoutPhase`)**:
  - `.preparing`: 3-2-1 countdown.
  - `.activeExercise(Exercise)`: The main exercise phase, which logs sets (Reps & Weight).
  - `.resting`: Countdown timer between sets/exercises.
  - `.finished`: Workout completion, PR detection, and logging.
- **Tracking**:
  - `currentSets`: An array of `ExerciseSetEntry` for the current exercise. Users can manually check off sets.
  - `completedSetsArchive`: Stores all completed sets so that progress isn't lost if the user skips or finishes early.
  - Logs session data to `WorkoutSummaryManager` when `.finished` is reached.

---

## 3. Core Data Models (`DataModel.swift` & `SummaryDataModel.swift`)

### Core Entities
- **`Exercise`**: Contains properties like `targetAreas`, `equipments`, `executionSteps`, `tips`, `demoVideo`, and `metValue` (used for calorie calculation).
- **`Preset`**: A pre-defined collection of exercises (e.g., Full Body Starter). Includes estimated time, calories, and focus areas.
- **`SetData`**: Represents target sets and reps (or duration for isometric holds).
- **`UserProfileModel`**: Stores user metrics (age, weight, height, fitness level) which directly impact the Calorie Calculation Engine.

### Summary & Analytics
- **`CompletedExerciseRecord`**: Logs actual sets completed, duration, calories burned, and AI form accuracy (0-100 score).
- **`DailySummary` & `WeeklySummary`**: Aggregates workout sessions for calendar views and the Metric Rings.
- **Calorie Engine**: `Calories = MET × WeightKg × TimeInHours`. The `MET` values are fetched from a static compendium dictionary.

---

## 4. UI Architecture & Navigation

- **State Management**: Built primarily with Apple's `@Observable` macro injected via the `.environment()`.
- **Navigation**: Uses strict `NavigationStack` with typed enumerations (`WorkoutRoute` and `SummaryRoute`).
- **Mid-Workout Assistance**: The `WorkoutControlsSheet` was recently modified to support an immediate trigger into the `CaliberationScreen` full-screen cover, allowing users to calibrate their posture mid-workout without disrupting the session state.
