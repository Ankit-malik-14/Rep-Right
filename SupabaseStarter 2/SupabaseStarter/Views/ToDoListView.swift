//
//  ToDoListView.swift
//  SupabaseStarter
//
//  Created by Shruti Sachdeva on 16/04/26.
//

import SwiftUI

struct ToDoListView: View {
    @Environment(ToDoTaskViewModel.self) var viewModel
    @Environment(AuthViewModel.self) var authViewModel
    @State var newTask = ToDoTask(id: UUID(), title: "", description: "", dueDate: .now, status: .notStarted)
    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            Group {
                if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView("Cant load to-dos", systemImage: "exclamationmark.triangle.fill", description: Text(errorMessage))
                } else {
                    List {
                        ForEach($viewModel.toDos){ $toDo in
                            NavigationLink {
                                ToDoTaskDetailView(toDo: $toDo)
                            } label: {
                                Text(toDo.title)
                            }
                        }
                        .onDelete { indexset in
                            viewModel.delete(at: indexset)
                        }
                    }
                }
            }
            .navigationTitle("To Dos")
            .onAppear {
                viewModel.fetchToDos()
            }
            .refreshable {
                viewModel.fetchToDos()
            }
            .toolbar {
                NavigationLink {
                    ToDoTaskDetailView(toDo: $newTask, isEditing: false)
                } label: {
                    Label("Add", systemImage: "plus")
                }
                
                Button("Sign out", systemImage: "power") {
                    authViewModel.signOut()
                }
            }
            
        }
    }
}

#Preview {
    ToDoListView()
        .environment(ToDoTaskViewModel())
        .environment(AuthViewModel())
}

