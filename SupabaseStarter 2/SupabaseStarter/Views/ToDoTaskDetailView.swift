//
//  ToDoTaskDetailView.swift
//  SupabaseStarter
//
//  Created by Shruti Sachdeva on 16/04/26.
//

import SwiftUI

struct ToDoTaskDetailView: View {
    @Environment(ToDoTaskViewModel.self) var viewModel
    @Environment(\.dismiss) var dismiss
    @Binding var toDo: ToDoTask
    var isEditing: Bool = true
    var body: some View {
        Form {
            TextField("title", text: $toDo.title)
            TextField("description", text: $toDo.description)
            DatePicker("Due date", selection: $toDo.dueDate, displayedComponents: .date)
            Picker("Status", selection: $toDo.status) {
                Text(Status.notStarted.displayName).tag(Status.notStarted)
                Text(Status.started.displayName).tag(Status.started)
                Text(Status.almostComplete.displayName).tag(Status.almostComplete)
                Text(Status.underProgress.displayName).tag(Status.underProgress)
                Text(Status.completed.displayName).tag(Status.completed)
            }
        }
        .navigationTitle("To Do Task")
        .toolbar {
            Button("Save",systemImage: "checkmark.circle.fill") {
                // save the edited task
                if isEditing {
                    viewModel.update(oldTaskId: toDo.id, with: toDo)
                } else {
                    viewModel.createTask(title: toDo.title, description: toDo.description, dueDate: toDo.dueDate, status: toDo.status)
                    toDo.title = ""
                    toDo.description = ""
                    toDo.dueDate = .now
                    toDo.status = .notStarted
                }
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ToDoTaskDetailView(toDo: .constant(ToDoTaskViewModel.preview))
    }
    .environment(ToDoTaskViewModel())
}
