//
//  UserProfileDTO.swift
//  Rep_Right
//
//  Created by GU on 28/04/26.
//

import Foundation
import Supabase


struct UserProfileDTO: Codable, Identifiable {
    var id: UUID // Matches auth.users ID
    var name: String
    var age: Int
    var gender: String
    var weight: Double
    var height: Double
    var unit_system: String
    var fitness_level: String
    var weekly_goal_days: Int
}

struct CompletedExerciseDTO: Codable, Identifiable {
    var id: UUID
    var user_id: UUID
    var exercise_id: UUID
    var preset_id: UUID?
    var workout_session_id: UUID?
    var start_time: Date
    var end_time: Date
    var actual_set: [SetData] // Requires SetData to be Codable
    var calories_burned_value: Double?
}

// MARK: - Supabase Manager

class SupabaseDataManager {
    // Replace with your actual Rep-Right Supabase credentials
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://YOUR_PROJECT.supabase.co")!,
        supabaseKey: "YOUR_ANON_KEY"
    )
    
    static let shared = SupabaseDataManager()
    private init() { }
    
    // MARK: - Auth Services
    
    var currentUser: User? {
        client.auth.currentUser
    }
    
    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }
    
    func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(email: email, password: password)
        // Note: A database trigger should ideally create the `profiles` row automatically on sign up.
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    // MARK: - User Profile (profiles table)
    
    func fetchUserProfile() async throws -> UserProfileDTO {
        guard let userId = currentUser?.id else { throw URLError(.userAuthenticationRequired) }
        
        return try await client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single() // Expect exactly one profile per user
            .execute()
            .value
    }
    
    func updateUserProfile(_ profile: UserProfileDTO) async throws {
        guard let userId = currentUser?.id else { throw URLError(.userAuthenticationRequired) }
        
        try await client
            .from("profiles")
            .update(profile)
            .eq("id", value: userId.uuidString)
            .execute()
    }
    
    // MARK: - Custom Presets (custom_presets table)
    // Assuming you make your `Preset` struct Codable
    
//    func fetchCustomPresets() async throws -> [Preset] {
//        guard let userId = currentUser?.id else { throw URLError(.userAuthenticationRequired) }
//        
//        return try await client
//            .from("custom_presets")
//            .select()
//            .eq("user_id", value: userId.uuidString)
//            .execute()
//            .value
//    }
    
//    func saveCustomPreset(_ preset: Preset) async throws {
//        guard let userId = currentUser?.id else { throw URLError(.userAuthenticationRequired) }
//        
//        // Wrap preset into a dictionary or a DTO that includes the user_id
//        struct PresetInsert: Codable {
//            var user_id: UUID
//            var preset: Preset
//        }
//        
//        try await client
//            .from("custom_presets")
//            .upsert(PresetInsert(user_id: userId, preset: preset))
//            .execute()
//    }
    
    func deleteCustomPreset(id: UUID) async throws {
        try await client
            .from("custom_presets")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Workout Summary / History (completed_exercises table)
    
    func fetchWorkoutHistory() async throws -> [CompletedExerciseDTO] {
        guard let userId = currentUser?.id else { throw URLError(.userAuthenticationRequired) }
        
        return try await client
            .from("completed_exercises")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("start_time", ascending: false) // Newest first
            .execute()
            .value
    }
    
    func logWorkout(exercises: [CompletedExerciseDTO]) async throws {
        guard let userId = currentUser?.id else { throw URLError(.userAuthenticationRequired) }
        
        // Ensure all records have the correct user_id attached before inserting
        let exercisesToInsert = exercises.map { mutExercise -> CompletedExerciseDTO in
            var ex = mutExercise
            ex.user_id = userId
            return ex
        }
        
        try await client
            .from("completed_exercises")
            .insert(exercisesToInsert)
            .execute()
    }
}
