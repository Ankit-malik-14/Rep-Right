# Assistance Model Notes

This document summarizes the joint-based and contour-based assistance systems in Rep-Right, along with the rep-counting design discussed so far.

## 1. Current Assistance Architecture

Rep-Right uses two assistance paths:

- `joint` based assistance
- `contour` based assistance

The active exercise model stores the assistance metadata:

- `assistanceAvailable`
- `assistanceModel`
- `assistanceRuleName`
- `assistanceUsesStaticHold`

The assistance flow is triggered from the workout controls sheet:

- if the current exercise uses `joint`, the app opens `JointModelTestScreen`
- otherwise it opens `CaliberationScreen`

## 2. Joint-Based Assistance

The joint-based pipeline currently uses:

- `AVCaptureSession`
- `VNDetectHumanBodyPoseRequest`
- normalized joints
- EMA smoothing
- rule evaluation from `ExerciseRuleset.json`
- rep counting / hold timing
- feedback aggregation into form accuracy and insights

### Main responsibilities

- capture frames
- extract joints
- normalize pose data
- evaluate pose quality
- count reps for rep-based exercises
- measure time for hold-based exercises

### Important model behavior

- exercise identity should be fixed by the workout flow
- the assistant should not re-decide which exercise is being done during the set
- form scoring and rep counting should be separate systems

## 3. Why the Old Ruleset Lookup Was Fragile

The earlier joint model depended on:

- rule names matching exactly
- fallback to the JSON array index

That was brittle because:

- any order change in the ruleset could break mapping
- similar exercise names could map to the wrong rule
- some exercises used approximate names instead of exact rule names

The safer design is:

- stable rule ID first
- exact name second
- never depend on array order for correctness

## 4. Static Hold Exercises

Static hold exercises are a strong fit for rules-based analysis.

Examples:

- Plank
- Wall Sit
- Side Plank
- Glute Bridge Hold
- Dead Hang
- L-Sit Hold
- Hollow Body Hold
- Superman Hold

These exercises can usually be judged by a small number of checks:

- body alignment
- joint angle ranges
- relative joint positions
- stability over time

### Recommended hold analysis structure

- evaluate pose every frame
- smooth the joints over a short window
- require a rule failure to persist for multiple frames before showing feedback
- keep the exercise fixed while the hold is being analyzed

## 5. Rep-Based Exercises

Rep-based exercises need a different layer from hold-based exercises.

Examples:

- Push-Up
- Squat
- Crunches
- Leg Raise
- Jumping Jacks

### Key principle

Rep counting should not be based on raw screen `x/y` coordinates.

That breaks when device orientation changes.

Instead, the rep counter should operate in a **body-centric coordinate system**.

## 6. Body-Centric Rep Counting

The rep counter should use a normalized body frame, not device coordinates.

### Better signals than screen axes

- joint angle change
- normalized body-axis displacement
- distance ratios between key joints
- combined bilateral signals

### Example rep signal sources

- Push-Up
  - elbow flexion
  - torso compression
  - shoulder/hip relationship

- Crunches / Leg Raise
  - torso compression
  - hip flexion
  - shoulder-to-hip movement

- Jumping Jacks
  - wrist spread
  - ankle spread
  - combined spread ratio

## 7. Generic Rep Counter Design

The rep counter should be a reusable state machine with pluggable signal providers.

### Suggested states

- `idle`
- `tracking`
- `refractory`

### Suggested transition logic

- wait for the motion signal to enter a valid trigger zone
- begin tracking once the trigger threshold is crossed
- confirm the peak phase
- count a rep only when the signal returns through the reset threshold
- apply a refractory period so the same rep is not counted twice

### Why this works

- stable against jitter
- stable against device orientation changes
- reusable across multiple exercises
- easier to tune than one-off heuristics

## 8. Rep Counting Profiles

Each rep-based exercise should have a small profile defining:

- trigger threshold
- peak threshold
- reset threshold
- refractory frames
- maximum cycle length
- signal provider

### Example profile concept

- `Push-Up`
  - normalized torso depth signal
  - elbow angle support signal

- `Crunches`
  - shoulder-to-hip compression signal

- `Jumping Jacks`
  - limb spread ratio signal

## 9. Static Hold vs Rep-Based Modes

Use two separate modes:

- `hold`
- `rep`

### Hold mode

- measure duration while form stays valid
- pause or invalidate when the posture breaks

### Rep mode

- count a rep only when a full motion cycle is completed
- continue running form checks in parallel

## 10. Reusable Architecture Recommendation

The best overall architecture is:

1. `PoseExtractor`
2. `PoseNormalizer`
3. `FormEvaluator`
4. `RepCounter`
5. `FeedbackComposer`

### What each layer does

- `PoseExtractor`
  - gets joints or contour data from Vision

- `PoseNormalizer`
  - transforms pose into a body-relative coordinate system

- `FormEvaluator`
  - checks posture rules for the selected exercise

- `RepCounter`
  - counts valid motion cycles for rep-based exercises

- `FeedbackComposer`
  - turns scoring outputs into user-facing coaching text

## 11. Contour-Based Exercises

The same counting architecture can be reused for contour-based exercises, but the signal provider should be different.

Examples:

- Squat
- some lunge variations
- other body-shape-driven movements

### For contour-based exercises

Use contour-derived features instead of joint angles:

- torso depth
- hip contour position
- back curvature
- body-center displacement along the body axis

### Important point

Reuse the **rep-counting architecture**, not the exact same signal formulas.

## 12. ML vs Rules

For static hold exercises and many rep-based assisted exercises, a static ruleset is a strong fit.

Reasons:

- easier to debug
- easier to explain
- fewer training data requirements
- safer for form coaching

ML can still be added later for:

- scoring confidence
- ambiguous cases
- personalization

But the current best path is:

- rules first
- body-normalized rep counting
- ML later only if needed

## 13. What We Decided

- Keep the exercise selected by the workout flow fixed during the set
- Do not let the assistant switch exercises mid-set
- Use rules for static hold posture analysis
- Use a generic body-centric rep counter for rep-based exercises
- Use pluggable signal providers so joint-based and contour-based exercises can share the same rep-counting engine

