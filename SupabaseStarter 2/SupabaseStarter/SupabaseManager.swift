//
//  SupabaseManager.swift
//  SupabaseStarter
//
//  Created by Shruti Sachdeva on 21/04/26.
//

import Foundation
import Supabase

class SupabaseManager {
    let supabaseClient = SupabaseClient(supabaseURL: URL(string: "https://uuumqktdtobpsulawohz.supabase.co")!, supabaseKey: "sb_publishable_8hz2IIN0sFGmJFJaBZHbCA_0FuK6sVJ")
    
    static let shared = SupabaseManager()
    
    private init() { }
    
    // MARK: - todos table
    
    
    func fetchToDoTasks() async throws -> [ToDoTask] {
        let toDos : [ToDoTask] = try await
        supabaseClient
            .from("todos")
            .select()
            .execute()
            .value
        
        return toDos
    }
    
    
    func createToDoTask(title: String, description: String,
                        dueDate: Date, status: Status) async throws {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = formatter.string(from: dueDate)
        
        try await supabaseClient
            .from("todos")
            .insert([
                "title": title,
                "description": description,
                "due_date": dateString,
                "status": status.rawValue
            ])
            .execute()
    }
    
    
    func updateToDoTask(oldTaskId: UUID, with newTask: ToDoTask) async throws {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = formatter.string(from: newTask.dueDate)
        
        try await supabaseClient
            .from("todos")
            .update([
                "title" : newTask.title,
                "description": newTask.description,
                "due_date": dateString,
                "status": newTask.status.rawValue
            ]).eq("id", value: oldTaskId.uuidString)
            .execute()
    }
    
    func deleteToDoTask(with id: UUID) async throws {
        try await supabaseClient.from("todos")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
}

extension SupabaseManager {
    // MARK: - Auth services
    
    var currentUser: User?  {
        supabaseClient.auth.currentUser
    }
    
    func signIn(email:String, password: String) async throws {
        try await supabaseClient.auth.signIn(email: email, password: password)
    }
    
    func signOut() async throws {
        try await supabaseClient.auth.signOut()
    }
    
    
}
