//
//  ToDoTask.swift
//  SupabaseStarter
//
//  Created by Shruti Sachdeva on 16/04/26.
//

import Foundation

enum Status: String, Codable, CaseIterable {
    case notStarted
    case started
    case underProgress
    case almostComplete
    case completed
    
    var displayName: String {
        switch self {
        case .notStarted:
            "Not Started"
        case .started:
            "Started"
        case .underProgress:
            "Under Progress"
        case .almostComplete:
            "Almost Complete"
        case .completed:
            "Completed"
        }
    }
}

struct ToDoTask: Codable, Identifiable, Hashable {
    var id: UUID
    var title: String
    var description: String
    var dueDate: Date
    var status: Status
    var isCompleted: Bool {
        switch self.status {
        case .notStarted, .started, .underProgress,.almostComplete:
            return false
        case .completed:
            return true
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case dueDate = "due_date"
        case status
    }
}


