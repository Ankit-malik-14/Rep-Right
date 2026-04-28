//
//  ToDoTaskViewModel.swift
//  SupabaseStarter
//
//  Created by Shruti Sachdeva on 16/04/26.
//

import Foundation
import SwiftUI

@Observable
class ToDoTaskViewModel {
    var toDos:[ToDoTask] = []
    var errorMessage: String?
    static let preview = ToDoTask(id: UUID(), title: "Some task", description: "Some Description", dueDate: Date.now, status: .completed)
    
    let supabaseManger = SupabaseManager.shared
    
    init() {
        fetchToDos()
    }
    
    func fetchToDos() {
//        toDos = [
//            ToDoTask(id: UUID(), title: "Buy groceries", description: "Milk, Eggs, Bread & Butter", dueDate: DateComponents(calendar: .current,year: 2026, month: 4, day: 1).date!, status: .notStarted),
//            ToDoTask(id: UUID(), title: "Study Swift", description: "Supabase Integration", dueDate: DateComponents(calendar: .current,year: 2026, month: 3, day: 22).date!, status: .notStarted)
//        ]
        Task {
            do {
                toDos = try await supabaseManger.fetchToDoTasks()
                print("Tasks fetched successfully")
                for toDo in toDos {
                    print(toDo.title)
                }
            } catch {
                errorMessage = "Error fetching todos from Supabase: \(error.localizedDescription)"
                print(errorMessage ?? "Error fetching")
            }
        }
        
    }
    
    func update(oldTaskId: UUID, with newTask: ToDoTask) {
        // Updation at Supabase
        
        Task {
            do {
                try await supabaseManger.updateToDoTask(oldTaskId: oldTaskId, with: newTask)
                print("Successfully updated task at Supabase")
            } catch {
                print("Error updating the task: \(oldTaskId.uuidString)")
            }
        }
        
        // Updation at View model array
        
        if let index = toDos.firstIndex(where: { toDo in
            toDo.id == oldTaskId
        }) {
            toDos[index] = newTask
            print("Task Updated at View model array todos")
        } else {
            print("Unable to update the task in view model")
        }
    }
    
    func createTask(title: String, description: String, dueDate: Date, status: Status) {
        
        // Supabase
        Task {
            do {
                try await supabaseManger.createToDoTask(title: title, description: description, dueDate: dueDate, status: status)
                print("Successfully task created at Supabase")
            } catch {
                print("Error creating task at Supabase: \(error.localizedDescription)")
            }
        }
        
        
        // Local view model
        let newTask = ToDoTask(id: UUID(), title: title, description: description, dueDate: dueDate, status: status)
        toDos.append(newTask)
        print("New Task created in View model todos")
    }
    
    func delete(at offsets: IndexSet) {
        //Supabase deletion
        
        var uuidsOfTasksToBeDeleted: [UUID] = []
        
        for indice in offsets {
            uuidsOfTasksToBeDeleted.append(toDos[indice].id)
        }
        
        Task {
            do {
                for uuid in uuidsOfTasksToBeDeleted {
                    try await supabaseManger.deleteToDoTask(with: uuid)
                    print("task deleted successfully from supabase.")
                }
                
            } catch {
                print("Error deleting task at Supabase: \(error.localizedDescription)")
            }
        }
        
        
        
        // View model
        toDos.remove(atOffsets: offsets)
    }
}

