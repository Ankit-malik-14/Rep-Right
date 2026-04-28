# Rep-Right — Comprehensive Project Map
> **Purpose:** AI-readable reference document for codebase structure, data flow, navigation, and architectural decisions.  
> **Last updated:** April 2026 | **Platform:** iOS (SwiftUI, Swift 5.9+, Observation framework)

---

## 0. Project Philosophy & Conventions

| Convention | Detail |
|---|---|
| State Management | Apple's `@Observable` macro (not `ObservableObject`) throughout |
| Environment Injection | All global state injected via `.environment()` from `Rep_RightApp` |
| Navigation | `NavigationStack` + typed `enum` route values (no `NavigationLink(destination:)`) |
| UI Paradigm | Apple HIG-strict SwiftUI; no third-party UI libs |
| Data Persistence | In-memory only (no CoreData, no SwiftData yet) |
| Deprecated Patterns | All `@EnvironmentObject`, `ObservableObject`, old `struct UserProfile`, `DummyUserProfiles`, `SummaryData`, `CalorieGoalViewModel` are fully removed/commented |

---

## 1. App Entry Point & Launch Flow

```
Rep_RightApp  (App entry, @main)
│
│  Instantiates globals (all @Observable):
│    • Presets
│    • Exercises
│    • WeeklySchedules
│    • CustomPresetsDummyData
│    • WorkoutSummaryManager
│    • UserProfileModel
│
└─► ContentView
      │
      ├─ [isShowingSplash == true]  ──► AppNameScreenView   (1.5s splash, logo image)
      │
      ├─ [!hasSeenOnboarding]       ──► OnboardingContainerView
      │       TabView (.page style, 4 pages):
      │         Page 1: OnboardingScreenView1  (AI Assistance hero image)
      │         Page 2: OnboardingScreenView2  (Posture hero image)
      │         Page 3: OnboardingScreenView3  (MetricsView + SchedulerCards preview)
      │         Page 4: OnboardingScreenView4  (FitnessLevel picker + weeklyGoalDays)
      │               └─ "Get Started" sets hasSeenOnboarding = true (@AppStorage)
      │
      └─ [hasSeenOnboarding == true] ──► HomeView
```

### Key State Variables in ContentView
| Variable | Type | Storage | Purpose |
|---|---|---|---|
| `hasSeenOnboarding` | `Bool` | `@AppStorage` | Persists across launches |
| `isShowingSplash` | `Bool` | `@State` | Controls 1.5s splash gate |

---

## 2. HomeView — Tab Structure

```
HomeView  (TabView)
├── Tab "Workout"  (dumbbell.fill)  ──► WorkoutScreen
└── Tab "Summary"  (list.clipboard.fill)  ──► SummaryTabView
```

---

## 3. Workout Tab — Full Navigation Tree

```
WorkoutScreen  (NavigationStack, path: WorkoutRouter.path)
│
│  Scrollable Content:
│    • ScheduledWorkoutCard      (shows today's scheduled preset)
│    • QuickActionRow
│    • SmartRecommendationCard   (uses WorkoutSummaryManager.smartPresetRecommendation)
│    • CustomPreset              (CustomPresetsDummyData)
│    • DefaultPresets            (Presets)
│    • ExerciseListView          (Exercises, "See all" → .exerciseList)
│
│  Toolbar:
│    • person.circle.fill → .profile
│    • calendar icon → SchedulerView (sheet)
│
│  NavigationDestination (WorkoutRoute):
│
├── .defaultPresetsList    ──► DefaultPresetListView(presets:)
├── .customPresetsList     ──► CustomPresetsListView(preset:)
├── .exerciseList          ──► ExerciseListView()
│
├── .presetDetail(Preset)  ──► WorkoutDetailView(preset:)
│       Shows preset info, equipment, focus areas
│       CTA → NavigationLink → .preWorkoutGate(preset)
│
├── .exerciseDetail(Exercise) ──► ExercisesView(exercise:)
│       Shows execution steps, tips, set data
│       Has PostureCheckView sheet (AI Assistance) if assistanceAvailable
│
├── .preWorkoutGate(Preset) ──► PreWorkoutGateView(preset:)
│       • Reads WorkoutSummaryManager.muscleRecoveryStatus
│       • Shows RecoveryWarningCard OR AllClearCard
│       • Shows SmartPrepPromptCard → .activeWorkout(smartPrepPreset)
│       • Toolbar "Skip" alert → router.push(.activeWorkout(preset))
│
├── .activeWorkout(Preset)  ──► ActiveWorkoutView(preset:)
│       (see §5 for full detail)
│
└── .profile               ──► ProfileFormView()
        Binds to UserProfileModel via environment
```

---

## 4. Summary Tab — Full Navigation Tree

```
SummaryTabView  (NavigationStack)
│
│  Scrollable Content:
│    • CalendarView              (week strip, WorkoutSummaryManager.dailySummaries)
│    • MetricsView               (→ .metricRing NavigationLink)
│    • WeeklyCalorieBurnView     (→ .calorieBreakdown NavigationLink)
│    • FormInsightView           (latestFormInsight)
│    • FormAccuracyReportView    (averageFormAccuracy → .exerciseAccuracyList)
│
│  Toolbar: person.circle.fill → .profile
│
│  NavigationDestination (SummaryRoute):
│
├── .calorieBreakdown     ──► CalorieBreakdownView()
│       Bar chart (weekly), insight card, Edit toolbar → .userCalorieIntake
│
├── .metricRing           ──► MetricRingView()
│       Custom circular progress + 4 metric cards
│
├── .userCalorieIntake    ──► UserCalorieIntake()
│       Stepper UI, binds to WorkoutSummaryManager.dailyCalorieGoal
│
├── .exerciseAccuracyList ──► ExerciseAccuracyListView()
│       Lists CompletedExerciseRecord where formAccuracy != nil
│       Each row → .accuracyMeter(value:exerciseName:)
│
├── .accuracyMeter(v, n)  ──► AccuracyMeterView(value:exerciseName:)
│       GaugesView + LevelView + MotivationalQuote + RiskView (static)
│
└── .profile              ──► ProfileFormView()
```

---

## 5. Active Workout Flow (WorkoutSessionManager State Machine)

```
ActiveWorkoutView
│
│  Phase: WorkoutPhase (enum, Equatable)
│
├── .preparing
│       3-2-1 countdown Timer
│       → calls manager.startWorkout()
│       → phase becomes .activeExercise(exercise[0])
│
├── .activeExercise(Exercise)
│       Background: ExerciseBackground (video player + pulse rings)
│       Sheet (non-dismissible): WorkoutControlsSheet
│         ├── [detent = .fraction(0.2)]  Header + 3 control buttons
│         │     • Pause/Resume (toggleTimer)
│         │     • Skip Exercise (skipExercise → archive → rest or finish)
│         │     • Finish Workout (finishWorkout)
│         └── [detent = .medium]  + Interactive Sets Table
│               3 rows: SetNumber | Reps TextField | Weight TextField | ✓ Toggle
│               All 3 sets completed → auto-transition to .resting (0.6s delay)
│
├── .resting(duration: Int)
│       WorkoutRestScreen
│         • Circular countdown ring (restTimeRemaining / 60)
│         • Motivational quote (random from static array)
│         • Next exercise preview
│         • "Skip Rest" button → skipRest() → moveToNextExercise()
│       Timer ticks every 1s (real Timer, drives state transition)
│
└── .finished
        finishedView
          • checkmark.circle.fill + bounce effect
          • PRBadgeView (if personal record detected)
          • RecoveryAdvisoryView (trained muscles list)
          • Stats row: Duration | Calories | Exercises
        → logSession() called
        → router.popToRoot() after 2s delay
```

### WorkoutSessionManager Key Properties
| Property | Type | Purpose |
|---|---|---|
| `preset` | `Preset` | Source of truth for exercise list |
| `exerciseQueue` | `[Exercise]` | Ordered list, indexed by `currentIndex` |
| `currentIndex` | `Int` | Pointer into exerciseQueue |
| `phase` | `WorkoutPhase` | Drives view switching |
| `currentSets` | `[ExerciseSetEntry]` | Live set data for current exercise (always 3) |
| `completedSetsArchive` | `[Int: [ExerciseSetEntry]]` | Keyed by exercise index, persists past sets |
| `accumulatedTime` | `TimeInterval` | Banked time (for pause/resume) |
| `timerStartDate` | `Date?` | Non-nil = running (Date-based, drives TimelineView) |
| `restTimeRemaining` | `Int` | Counts down 60→0, drives rest ring |

---

## 6. AI Posture Check Flow (PostureCheckView)

```
PostureCheckView (sheet, presented from ExercisesView)
│
│  @State viewModel: ExerciseDetectionViewModel (@Observable)
│
│  Layers (ZStack):
│    1. CameraFeedView (UIViewRepresentable → PreviewView)
│         PreviewView: layerClass = AVCaptureVideoPreviewLayer
│         bonesLayer + jointsLayer (CAShapeLayer) drawn via
│         previewLayer.layerPointConverted(fromCaptureDevicePoint:)
│
│    2. UI Controls (VStack)
│         • xmark.circle.fill → stopCameraSession() + dismiss()
│         • LivePillView (pulsing red dot)
│         • CameraPlacementBanner (guidance from ExerciseRuleset.json)
│         • FeedbackCardView
│             ├── Exercise name + live % score
│             ├── Progress bar (animated)
│             ├── Status: "Good Form" / "Needs Correction"
│             ├── primaryCorrectionParts: (issue, fix) from top flag
│             └── Scrollable flags list
│
│  ExerciseDetectionViewModel pipeline:
│    AVCaptureSession (front camera, sessionQueue)
│    → captureOutput (processingQueue)
│    → VNDetectHumanBodyPoseRequest
│    → processPose: extract 19 joints, flip Y (Vision bottom-left → screen top-left)
│    → buildAnalysisResult:
│         strategyAngles (per exercise ID)
│         → strategyChecks (ScoredRuleCheck array)
│         → feedbackFlags (threshold 0.72)
│         → strategyConfidenceScore (blend: rules 80%, coverage 12%, confidence 8%)
│    → publish: currentPose, analysisResult, liveFormPercent (main thread)
│
│  Exercise ID Mapping (name → ruleset ID):
│    Plank=1, Wall Sit=2, Bodyweight Squat=3, Glute Bridge Hold=4
│    Dead Hang=5, Overhead Hold=6, Push-Up=7, Forearm Plank=8
│    Side Plank=9, Lunge Hold=10, Hip Abduction Hold=11
│    L-Sit Hold=12, Hollow Body Hold=13, Superman Hold=14
```

---

## 7. Data Models

### 7a. Core Domain Models (`DataModel.swift`)

```
Exercise  (struct, Identifiable, Equatable, Hashable)
├── id: UUID
├── name: String
├── targetAreas: [String]           -- e.g. ["Chest","Triceps"]
├── equipments: [String]
├── executionSteps: [String]
├── tips: [String]
├── assistanceAvailable: Bool       -- gates PostureCheckView
├── demoVideo: URL?
├── image: String?                  -- asset catalog name
├── setData: [SetData]
└── metValue: Double                -- computed from static dictionary (Ainsworth compendium)

SetData  (struct, Hashable)
├── sets: Int
└── reps: Int                       -- doubles as seconds for isometric holds

Preset  (struct, Identifiable, Equatable, Hashable)
├── id: UUID
├── isRestDay: Bool
├── name: String
├── image: String?
├── exercises: [Exercise]
├── isWarmpUp: Bool
├── scheduledFor: Weekday?
├── estTime: Int                    -- minutes
├── focousArea: [String]            -- computed: top 3 FocusArea.rawValue by frequency
├── equipments: [String]
└── calories: Int

FocusArea  (enum, CaseIterable, Hashable)
  .shoulder | .back | .chest | .arms | .core | .legs
  static func from(targetArea: String) -> FocusArea?  -- fuzzy string matching

Weekday  (enum, Int, CaseIterable)
  .sunday=1 … .saturday=7

UserProfileModel  (@Observable class)
├── profilePicture: String?
├── name: String
├── age: Int
├── gender: Genders (.male | .female)
├── weight: Double                  -- kg, used in MET calorie calculation
├── height: Double                  -- metres
├── modelSensitivity: SensitivityLevels (.Low | .Medium | .High)
├── unitSystem: UnitSystem (.metric | .imperial)
├── fitnessLevel: FitnessLevel (.beginner | .intermediate | .advanced)
└── weeklyGoalDays: Int
```

### 7b. Summary / History Models (`SummaryDataModel.swift`)

```
CompletedExerciseRecord  (struct, Identifiable, Hashable)
├── id, exerciseId, presetId, workoutSessionId: UUID?
├── date, startTime, endTime: Date
├── actualSet: [SetData]
├── formAccuracy: Double?           -- 0–100, set by AI posture check
├── formInsights: [String]?
├── caloriesBurnedValue: Double?    -- pre-calculated at log time
└── duration: TimeInterval          -- computed (endTime - startTime)

CompletedPresetRecord  (struct, Identifiable, Hashable)
├── id, presetId: UUID
└── date: Date

DailySummary  (struct, Identifiable)
├── date: Date
├── exercises: [CompletedExerciseRecord]
├── totalDuration: TimeInterval     -- computed
├── standaloneExercises             -- computed (workoutSessionId == nil)
├── presetSessions: [UUID: [...]]   -- grouped by workoutSessionId
└── totalCalories(userWeightKg:)    -- computed

WeeklySummary  (struct, Identifiable)
├── weekStartDate: Date
├── dailySummaries: [DailySummary]
├── totalDuration                   -- computed
└── totalCalories(userWeightKg:)    -- computed

FocusAreaLoadInsight  (struct, Identifiable)
├── focusArea: FocusArea
├── weeklyExercises: Int
├── status: FocusAreaLoadStatus (.undertrained | .onTrack | .overtrained)
└── recommendation: String          -- computed
```

### 7c. New Architecture Models (`BaseEntityDataModel.swift`) ⚠️ In Progress
These exist alongside the legacy models and represent the planned migration target:

```
ExerciseDefinition  (struct, Identifiable, Hashable)
PresetTemplate      (struct, Identifiable, Equatable, Hashable)
PresetSession       (struct, Identifiable, Equatable, Hashable)
WorkoutExercise     (struct, Identifiable, Equatable, Hashable)
AWorkoutSet         (struct, Identifiable, Equatable, Hashable)
Equipment           (enum)
WorkoutCategory     (enum: .strength | .warmup | .isometric)
```
> **Note:** `ExerciseCatalog`, `WorkoutTemplates`, `WorkoutHistory` (in `ExerciseCatalog.swift`) are new singletons using these types. They are NOT yet wired into the main app environment — still isolated.

---

## 8. Global State Objects (Environment)

All injected at `Rep_RightApp` level, available app-wide:

| Object | Type | File | Purpose |
|---|---|---|---|
| `Presets` | `@Observable class` | `Dummy.swift` | Default preset catalog |
| `Exercises` | `@Observable class` | `Dummy.swift` | Exercise catalog (15 exercises) |
| `WeeklySchedules` | `@Observable class` | `Dummy.swift` | `[Weekday: Preset]` schedule map |
| `CustomPresetsDummyData` | `@Observable class` | `Dummy.swift` | User-created presets |
| `WorkoutSummaryManager` | `@Observable class` | `SummaryDataModel.swift` | All workout history + analytics |
| `UserProfileModel` | `@Observable class` | `DataModel.swift` | User profile & preferences |

### WorkoutSummaryManager Key Computed Properties
| Property | Returns | Used In |
|---|---|---|
| `dailySummaries` | `[DailySummary]` | CalendarView, SummaryTabView |
| `weeklySummaries` | `[WeeklySummary]` | MetricRingView, CalorieBreakdown |
| `weeklyCalorieChartData` | `[(day,calories)]` | WeeklyCalorieBurnView, CalorieBreakdownView |
| `totalExercisesCurrentWeek` | `Int` | MetricsView |
| `totalTimeCurrentWeekInHours` | `Double` | MetricsView |
| `activeMinutesCurrentWeek` | `Int` | MetricRingView |
| `currentStreak` | `Int` | MetricsView |
| `calorieProgress` | `Double` 0–1 | MetricRingView (circular arc) |
| `todayCaloriesBurned` | `Double` | CaloriesView |
| `averageFormAccuracy` | `Double` 0–1 | FormAccuracyReportView |
| `latestFormInsight` | `String?` | FormInsightView |
| `focusAreaLoadInsights(using:)` | `[FocusAreaLoadInsight]` | (available, not yet displayed) |
| `smartPresetRecommendation(from:using:)` | `Preset?` | SmartRecommendationCard |
| `muscleRecoveryStatus(for:using:)` | `[(muscle,hoursRemaining)]` | PreWorkoutGateView |

---

## 9. Navigation Architecture

### Route Enums (`EnumRoutes.swift`)

```swift
// Workout Tab
enum WorkoutRoute: Hashable {
    case defaultPresetsList
    case customPresetsList
    case exerciseList
    case presetDetail(Preset)
    case exerciseDetail(Exercise)
    case preWorkoutGate(Preset)
    case activeWorkout(Preset)
    case profile
}

// Summary Tab
enum SummaryRoute: Hashable {
    case calorieBreakdown
    case metricRing
    case userCalorieIntake
    case exerciseAccuracyList
    case accuracyMeter(value: Double, exerciseName: String)
    case profile
}
```

### WorkoutRouter (`WorkoutSessionManager.swift`)
```swift
@Observable class WorkoutRouter {
    var path: [WorkoutRoute] = []
    func push(_ route: WorkoutRoute)   // appends
    func popToRoot()                   // removeAll — used after workout finishes
}
```
Injected into environment from `WorkoutScreen`, consumed by `PreWorkoutGateView` and `ActiveWorkoutView`.

---

## 10. Scheduler System

```
SchedulerView  (sheet from WorkoutScreen toolbar)
│
│  ForEach Weekday.allCases:
│  └── SchedulerCards(weekday:, contextPreset:?)
│         ├── [isRest = false, preset exists]
│         │     Shows preset info card
│         │     "Edit" → PresetSelectionView (sheet)
│         │     "Assign" (if contextPreset != nil) → weeklySchedules.schedules[weekday] = contextPreset
│         │
│         ├── [isRest = false, no preset]
│         │     Dashed "Tap to schedule" button → PresetSelectionView (sheet)
│         │
│         └── [isRest = true]
│               Rest day tips (dynamic, reads yesterday's exercises from summaryManager)
│
│  PresetSelectionView(weekday:)
│       Searchable list of Presets.presets
│       Tap to select → "Done" → weeklySchedules.schedules[weekday] = selectedPreset + dismiss
```

`contextPreset` parameter enables direct assignment flow: from a WorkoutDetailView, passing the current preset to SchedulerView/SchedulerCards for one-tap scheduling.

---

## 11. Onboarding System

```
OnboardingContainerView  (@Binding hasSeenOnboarding: Bool)
│  TabView (.page style, ignoresSafeArea)
│
├── OnboardingScreenView1   Hero: "Your Personal AI Fitness Assistance"
│     Image: AIassistance (full-bleed clipped top)
│
├── OnboardingScreenView2   Hero: "Perfect your form"
│     Image: deadliftForOnboarding
│
├── OnboardingScreenView3   "Plan Your Success"
│     Live: MetricsView (dummy data visible)
│     Live: SchedulerCards(weekday: .wednesday, allowsHitTesting: false)
│     Requires: WeeklySchedules in environment
│
└── OnboardingScreenView4   "Personalise your plan"
      FitnessLevelCard × 3 → userProfile.fitnessLevel
      Days picker → userProfile.weeklyGoalDays
      "Get Started" → hasSeen = true → ContentView shows HomeView
      Requires: UserProfileModel in environment
```

---

## 12. Shared View Components

### ViewStore.swift — Reusable View Builders
| Component | Type | Usage |
|---|---|---|
| `assisstanceAvailablityTag(type:)` | `@ViewBuilder func` | Exercise detail, workout cards |
| `PresetTileViewType(preset:type:)` | `View` | `.large` (160×185 card), `.small` (HStack row) |
| `ContinueButton` | `View` | Onboarding, UserCalorieIntake |

### MethodStore.swift — Global Helpers
| Function | Signature | Usage |
|---|---|---|
| `arrayToString` | `([String]) -> String` | Equipment lists, focus areas |
| `pointView` | `@ViewBuilder ([String]) -> some View` | Numbered execution steps |
| `continueButtonView` | `@ViewBuilder () -> some View` | (legacy capsule variant) |

### Summary Tab Sub-Views
| View | Data Source | Displays |
|---|---|---|
| `GaugesView` | `@Binding Double` | Circular gauge (0–100, color-coded) |
| `LevelView` | `@Binding Double` | "Accuracy — Perfect/Cautious/Danger" |
| `MotivationalQuote` | `@Binding Double` | Range-based quote string |
| `RiskView` | `var risks: [String]` | Red triangle list |
| `SuggestionView` | `var suggestions: [String]` | Green checkmark list |
| `AccuracyMeterView` | `value: Double, exerciseName: String` | Full accuracy detail screen |
| `MetricRingView` | `WorkoutSummaryManager` | Custom arc progress + 4 cards |
| `ExerciseRingView` | `WorkoutSummaryManager + Exercises` | Donut chart by FocusArea |
| `TotalTimeExerciseView` | `WorkoutSummaryManager + Exercises` | Bar chart by day |
| `CalorieBreakdownView` | `WorkoutSummaryManager` | Bar chart + insight card |
| `WeeklyCalorieBurnView` | `WorkoutSummaryManager` | Line+area chart |
| `CalendarView` | `WorkoutSummaryManager` | 7-day week strip, navigable |
| `MetricsView` | `WorkoutSummaryManager` | 3-cell metric strip (exercises, time, streak) |
| `FormInsightView` | `WorkoutSummaryManager` | Latest form insight string |
| `FormAccuracyReportView` | `WorkoutSummaryManager` | Gauge + "View Trends" link |

---

## 13. Calorie Calculation Engine

**Formula:** `Calories = MET × WeightKg × TimeInHours`

```
WorkoutSummaryManager.calculateCalories(for:durationInSeconds:weightInKg:) -> Double

MET values from Exercise.metDictionary (static, Ainsworth Compendium):
  Push-Up: 3.8 | Bodyweight Squat: 5.0 | Dumbbell Row: 4.5
  Plank: 3.0 | Pull-Up: 8.0 | Burpee: 8.0 | Jump Rope: 10.0
  (+ 30 more entries, fallback: 3.5)

At logSession() in ActiveWorkoutView:
  timePerExercise = elapsedTime / count(attemptedExercises)
  forEach attemptedExercise:
    cals = calculateCalories(exercise, timePerExercise, userProfile.weight)
  → logPresetSession(presetId:exercises:)
```

---

## 14. Recovery & Smart Recommendation Engine

```
WorkoutSummaryManager.muscleRecoveryStatus(for:using:windowHours:48)
  → Finds exercises completed in last 48h
  → Extracts targetAreas trained
  → Cross-references with preset's exercise targetAreas
  → Returns [(muscle: String, hoursRemaining: Double)] sorted by hoursRemaining desc

WorkoutSummaryManager.smartPresetRecommendation(from:using:)
  → Filters: !isRestDay, !exercises.isEmpty
  → Picks preset with fewest muscles still in recovery window

Used by:
  PreWorkoutGateView  → recovery warning before starting
  SmartRecommendationCard  → homepage suggestion
```

---

## 15. AI Posture Detection Architecture (`ExerciseDetectionViewModel.swift`)

### Camera Pipeline
```
AVCaptureDevice (front, builtInWideAngleCamera)
  → AVCaptureSession (preset: .high)
  → AVCaptureVideoDataOutput (BGRA, alwaysDiscardsLateVideoFrames)
  → connection.videoRotationAngle = f(interfaceOrientation)
  → connection.isVideoMirrored = true (manual, automaticallyAdjustsVideoMirroring = false)
  → VNImageRequestHandler(orientation: visionOrientation(for:))
  → VNDetectHumanBodyPoseRequest
  → 19 joints extracted (confidence > 0.3)
  → Y-flip: flippedY = 1.0 - recognizedPoint.location.y
```

### Analysis Pipeline (per frame)
```
processPose(observation)
  → buildAnalysisResult(joints:coordinates:)
      → strategyAngles(exerciseId, joints)   // extracts key angles for that exercise
      → strategyChecks(exercise, joints, angles)  // returns [ScoredRuleCheck]
          each check has:  flagKey: String, score: Double? (0.0–1.0)
      → feedbackFlags(checks, exercise)       // flags where score < 0.72
      → strategyConfidenceScore(exercise, joints, checks)
          = (rulesScore × 0.80) + (poseCoverage × 0.12) + (avgJointConfidence × 0.08)
          clamped to calibratedFloor based on rulesScore band
  → publish on main thread:
      analysisResult: ExerciseAnalysisResult
      liveFormPercent: Double (0–100)
      currentPose: DetectedPose
      jointOverlayPoints: [CGPoint]
```

### Scoring Helpers
| Helper | Purpose |
|---|---|
| `scoreTarget(value, target, tolerance)` | Cosine-style score for angles |
| `scoreMin(value, minValue, softTolerance)` | Penalises values below threshold |
| `scoreMax(value, maxValue, softTolerance)` | Penalises values above threshold |
| `scoreRange(value, min, max, softTolerance)` | Penalises values outside range |

### Skeleton Rendering (PreviewView / CAShapeLayer)
```
PreviewView: UIView (layerClass = AVCaptureVideoPreviewLayer)
  ├── bonesLayer: CAShapeLayer  (stroke, 2.5pt, rounded)
  └── jointsLayer: CAShapeLayer (fill white, stroke colored)

Point conversion:
  previewLayer.layerPointConverted(fromCaptureDevicePoint: point)
  → Handles rotation, mirroring, and resizeAspectFill cropping automatically

Bone color:
  nil isCorrect → .systemYellow
  true → .systemGreen
  false → .systemOrange
```

---

## 16. Dummy / Seed Data

| Class | File | Contents |
|---|---|---|
| `Exercises` | `Dummy.swift` | 15 exercises (Push-Up, Wall Sit, Plank, Bodyweight Squat, Dumbbell Row, + 10 isometrics) |
| `Presets` | `Dummy.swift` | 5 presets (Full Body Starter, Upper Focus, Core & Stability, Active Recovery, Lower Body Builder) |
| `CustomPresetsDummyData` | `Dummy.swift` | 4 custom presets |
| `WeeklySchedules` | `Dummy.swift` | `[.wednesday: fullBodyStarterPreset]` |
| `DummyWorkoutSummaryData` | `DummyWorkoutSummaryData.swift` | Seeds WorkoutSummaryManager with multi-day history for UI testing |

---

## 17. Deprecated / Removed Code (Do Not Resurrect)

| What | Where | Replaced By |
|---|---|---|
| `struct UserProfile` | `DataModel.swift` (commented) | `class UserProfileModel` |
| `UserProfileKey: EnvironmentKey` | `DataModel.swift` (commented) | `.environment(profileModel)` |
| `DummyUserProfiles` | `Dummy.swift` (commented) | `UserProfileModel` |
| `class SummaryData` | `ObservableModels.swift` (commented) | `WorkoutSummaryManager` |
| `class UserProfileModel` (old) | `ObservableModels.swift` (commented) | Moved to `DataModel.swift` |
| `class CalorieGoalViewModel` | `UserCalorieIntake.swift` (commented) | `WorkoutSummaryManager.dailyCalorieGoal` |
| `ObservableObject` / `@Published` | Everywhere | `@Observable` macro |

---

## 18. Files → Responsibilities Quick Reference

| File | Primary Responsibility |
|---|---|
| `Rep_RightApp.swift` | App entry, global environment injection |
| `ContentView.swift` | Splash → Onboarding → HomeView gate |
| `HomeView.swift` | TabView shell |
| `WorkoutScreen.swift` | Workout tab root, NavigationStack, all WorkoutRoute destinations |
| `SummaryTabView.swift` | Summary tab root, NavigationStack, all SummaryRoute destinations |
| `DataModel.swift` | Exercise, Preset, SetData, UserProfileModel, enums |
| `SummaryDataModel.swift` | WorkoutSummaryManager, CompletedExerciseRecord, DailySummary, WeeklySummary |
| `Dummy.swift` | Seed data: Exercises, Presets, CustomPresets, WeeklySchedules |
| `DummyWorkoutSummaryData.swift` | Multi-day seeded history for previews |
| `BaseEntityDataModel.swift` | New architecture types (migration in progress) |
| `ExerciseCatalog.swift` | New singletons (ExerciseCatalog, WorkoutTemplates, WorkoutHistory) |
| `WorkoutSessionManager.swift` | WorkoutPhase SM, WorkoutRouter, ExerciseSetEntry |
| `ActiveWorkoutView.swift` | Full workout execution UI + logSession() |
| `WorkoutControlsSheet.swift` | Bottom sheet: timer, controls, sets table |
| `WorkoutRestScreen.swift` | Rest countdown screen |
| `PreWorkoutGateView.swift` | Recovery check + SmartPrep before workout |
| `PostureCheckView.swift` | Camera + skeleton overlay + feedback card |
| `ExerciseDetectionViewModel.swift` | Vision pose detection + scoring engine |
| `ExerciseRuleset.json` | 14 exercise rules (angles, flags, expected accuracy) |
| `EnumRoutes.swift` | WorkoutRoute + SummaryRoute enums |
| `ViewStore.swift` | Shared view builders: PresetTileViewType, ContinueButton, tags |
| `MethodStore.swift` | Global helper functions |
| `OnboardingContainerView.swift` | 4-page PageTabView shell |
| `OnboardingScreenView1–4.swift` | Individual onboarding pages |
| `AppNameScreenView.swift` | Splash logo screen |
| `SchedulerView.swift` | Full-week schedule sheet |
| `SchedulerCards.swift` | Per-day scheduler card with rest tips |
| `PresetSelectionView.swift` | Searchable preset picker |
| `SignInView.swift` / `SignUpView.swift` | Auth screens (not yet wired into app flow) |
| `UserDataIntake.swift` | Profile form: gender, age, height, weight |
| `UserCalorieIntake.swift` | Daily calorie goal stepper |
| `CalendarView.swift` | Navigable week strip |
| `MetricsView.swift` | 3-metric card strip |
| `MetricsTabViewContainer.swift` | ExerciseRingView + TotalTimeExerciseView scroll |
| `ExerciseRingView.swift` | Donut chart by FocusArea |
| `TotalTimeExerciseView.swift` | Bar chart by day/category |
| `WeeklyCalorieBurnView.swift` | Line+area calorie chart |
| `CalorieBreakdownView.swift` | Full calorie analytics screen |
| `CaloriesView.swift` | Today's calorie gauge |
| `MoveDataView.swift` | cal/goal display row |
| `FormInsightView.swift` | Latest AI form insight bubble |
| `FormAccuracyReportView.swift` | Gauge + link to history |
| `ExerciseAccuracyListView.swift` | History list with formAccuracy |
| `AccuracyMeterView.swift` | Gauge + level + quote + risks |
| `GaugesView.swift` | Circular gauge (0–100) |
| `LevelView.swift` | Text label: Danger/Cautious/Perfect |
| `MotivationalQuote.swift` | Range-mapped motivational string |
| `RiskView.swift` | Red risk list |
| `SuggestionView.swift` | Green suggestion list |
| `MetricRingView.swift` | Animated arc + 4 metric cards |
| `RecommendationEngine.swift` | Placeholder/notes (not implemented) |
| `ObservableModels.swift` | Deprecated stubs only (CalorieEntry still used) |

---

## 19. Known Gaps / Future Work

| Area | Status | Notes |
|---|---|---|
| Auth (SignIn/SignUp) | UI exists, not wired | No auth backend yet |
| CoreData / SwiftData | Not implemented | All data in-memory |
| New architecture migration | In progress | `BaseEntityDataModel.swift` types coexist with legacy |
| ProfileFormView | Referenced in routes | Not found in provided files — likely exists but not shared |
| `SmartRecommendationCard`, `QuickActionRow`, `ScheduledWorkoutCard` | Referenced in WorkoutScreen | Not found in provided files |
| `WorkoutDetailView`, `ExercisesView`, `ExerciseListView`, `DefaultPresetListView`, `CustomPresetsListView` | Referenced in WorkoutScreen routes | Not found in provided files |
| `RecommendationEngine.swift` | Stub only | Comment-only, no implementation |
| Form accuracy write-back | Engine exists | `formAccuracy` never written from PostureCheckView into WorkoutSummaryManager during live workout |
| Weight tracking per set | `SetData` has no weight field | `AWorkoutSet` in new architecture does |
