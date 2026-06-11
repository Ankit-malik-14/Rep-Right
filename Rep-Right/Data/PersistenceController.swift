import Foundation
import SwiftData

struct PersistedUserProfile: Codable {
    var profilePicture: String?
    var name: String
    var age: Int
    var gender: Genders
    var modelSensitivity: SensitivityLevels
    var fitnessLevel: FitnessLevel
    var weeklyGoalDays: Int
    var unitSystem: UnitSystem
    var storedWeightKg: Double
    var storedHeightMeters: Double
}

struct PersistedWorkoutSummary: Codable {
    var completedExercises: [CompletedExerciseRecord]
    var completedSessions: [CompletedPresetRecord]
    var currentUserWeight: Double
    var dailyCalorieGoal: Double
}

struct PersistedWeeklyScheduleEntry: Codable {
    var weekday: Weekday
    var preset: Preset
}

@Model
final class PersistedAppState {
    @Attribute(.unique) var id: String
    var profileData: Data
    var summaryData: Data
    var weeklySchedulesData: Data
    var customPresetsData: Data
    
    init(
        id: String = "main",
        profileData: Data = Data(),
        summaryData: Data = Data(),
        weeklySchedulesData: Data = Data(),
        customPresetsData: Data = Data()
    ) {
        self.id = id
        self.profileData = profileData
        self.summaryData = summaryData
        self.weeklySchedulesData = weeklySchedulesData
        self.customPresetsData = customPresetsData
    }
}

@MainActor
final class PersistenceController {
    static let shared = PersistenceController()
    
    private(set) var container: ModelContainer?
    private var context: ModelContext?
    private var appState: PersistedAppState?
    private weak var summaryManagerRef: WorkoutSummaryManager?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private(set) var isRestoring = false
    
    private init() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }
    
    func configure(
        container: ModelContainer,
        summaryManager: WorkoutSummaryManager,
        weeklySchedules: WeeklySchedules,
        customPresets: CustomPresetsDummyData,
        profileModel: UserProfileModel
    ) throws {
        self.container = container
        let context = ModelContext(container)
        self.context = context
        self.summaryManagerRef = summaryManager
        
        let descriptor = FetchDescriptor<PersistedAppState>(
            predicate: #Predicate { $0.id == "main" }
        )
        
        if let existing = try context.fetch(descriptor).first {
            appState = existing
        } else {
            let created = PersistedAppState()
            context.insert(created)
            try context.save()
            appState = created
        }
        
        restoreAll(
            summaryManager: summaryManager,
            weeklySchedules: weeklySchedules,
            customPresets: customPresets,
            profileModel: profileModel
        )
        
        if summaryManager.currentUserWeight == 71.0 {
            summaryManager.currentUserWeight = profileModel.weight
        }
        
        saveAll(
            summaryManager: summaryManager,
            weeklySchedules: weeklySchedules,
            customPresets: customPresets,
            profileModel: profileModel
        )
    }
    
    func performRestore(_ block: () -> Void) {
        let previous = isRestoring
        isRestoring = true
        block()
        isRestoring = previous
    }
    
    func saveAll(
        summaryManager: WorkoutSummaryManager,
        weeklySchedules: WeeklySchedules,
        customPresets: CustomPresetsDummyData,
        profileModel: UserProfileModel
    ) {
        saveProfile(from: profileModel)
        saveSummary(from: summaryManager)
        saveWeeklySchedules(from: weeklySchedules)
        saveCustomPresets(from: customPresets)
    }
    
    func saveProfile(from profileModel: UserProfileModel) {
        guard !isRestoring else { return }
        if summaryManagerRef?.currentUserWeight != profileModel.weightInKilograms {
            summaryManagerRef?.currentUserWeight = profileModel.weightInKilograms
        }
        persist { state in
            state.profileData = encode(profileModel.makeSnapshot())
        }
    }
    
    func saveSummary(from summaryManager: WorkoutSummaryManager) {
        guard !isRestoring else { return }
        persist { state in
            state.summaryData = encode(summaryManager.makeSnapshot())
        }
    }
    
    func saveWeeklySchedules(from weeklySchedules: WeeklySchedules) {
        guard !isRestoring else { return }
        let entries = weeklySchedules.schedules
            .map { PersistedWeeklyScheduleEntry(weekday: $0.key, preset: $0.value) }
            .sorted { $0.weekday.rawValue < $1.weekday.rawValue }
        persist { state in
            state.weeklySchedulesData = encode(entries)
        }
    }
    
    func saveCustomPresets(from customPresets: CustomPresetsDummyData) {
        guard !isRestoring else { return }
        persist { state in
            state.customPresetsData = encode(customPresets.customPresets)
        }
    }
    
    private func restoreAll(
        summaryManager: WorkoutSummaryManager,
        weeklySchedules: WeeklySchedules,
        customPresets: CustomPresetsDummyData,
        profileModel: UserProfileModel
    ) {
        guard let appState else { return }
        
        if let profileSnapshot: PersistedUserProfile = decode(appState.profileData) {
            profileModel.apply(snapshot: profileSnapshot)
        }
        
        if let summarySnapshot: PersistedWorkoutSummary = decode(appState.summaryData) {
            summaryManager.apply(snapshot: summarySnapshot)
        }
        
        if let entries: [PersistedWeeklyScheduleEntry] = decode(appState.weeklySchedulesData) {
            let scheduleMap = Dictionary(uniqueKeysWithValues: entries.map { ($0.weekday, $0.preset) })
            weeklySchedules.apply(snapshot: scheduleMap)
        }
        
        if let presets: [Preset] = decode(appState.customPresetsData) {
            customPresets.apply(presets: presets)
        }
    }
    
    private func persist(_ update: (PersistedAppState) -> Void) {
        guard let context, let appState else { return }
        update(appState)
        do {
            try context.save()
        } catch {
            print("SwiftData save failed: \(error)")
        }
    }
    
    private func encode<T: Encodable>(_ value: T) -> Data {
        do {
            return try encoder.encode(value)
        } catch {
            print("Encoding failed: \(error)")
            return Data()
        }
    }
    
    private func decode<T: Decodable>(_ data: Data) -> T? {
        guard !data.isEmpty else { return nil }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding failed: \(error)")
            return nil
        }
    }
}
