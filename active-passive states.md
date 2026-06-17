# Active-Passive States

Goal: prevent the contour-based detector from treating normal standing as an exercise posture.

## State Model

- `idle`: no useful pose has been detected yet.
- `passive`: the person is standing neutrally and should not be evaluated.
- `active`: the person is in an exercise-ready posture and should be analyzed.

## Intended Behavior

- If the user is just standing, keep the detector in `passive`.
- While in `passive`, skip heavy contour posture checks and rep logic.
- Only switch to `active` when the body clearly enters a workout-ready pose.
- Return to `passive` if the user relaxes back into a neutral standing posture.

## Suggested Neutral Checks

- Torso is upright and stable.
- Hip, knee, and ankle angles are close to normal standing ranges.
- Arms are relaxed, not locked into a start position.
- Pose motion is low for several consecutive frames.
- Silhouette shape does not indicate an exercise start posture.

## Suggested Activation Checks

- The pose is stable for multiple frames, not just one.
- The body has moved into a known exercise start position.
- Joint angles and silhouette both look intentional, not casual standing.
- Use hysteresis so the detector does not flip states every frame.

## Why This Helps

- Reduces false positives from normal standing.
- Prevents shoulder rounding or small posture changes from being flagged.
- Saves compute by skipping unnecessary analysis.
- Makes the detector feel less jumpy and more intentional.

## Important Note

- This gate should be exercise-aware.
- Some exercises start from standing, so "neutral" does not always mean "inactive forever".
- The detector should require sustained evidence before leaving `passive`.

