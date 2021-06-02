//
//  TodosListView.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture

struct TodosListView: View {
    let store: Store<TodosList.State, TodosList.Action>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            List(viewStore.todos) { todo in
                VStack {
                    HStack {
                        Button<Image>(todo.completed ? .largecircleFillCircle : .circle) {
                            viewStore.send(.toggleCompleted(todo))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.accentColor)
                        
                        
                        TextField("Description", text: .constant(todo.description))
                            .opacity(todo.completed ? 0.25 : 1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                }
            }
            .onAppear() {
                viewStore.send(.onAppear)
            }
            .toolbar {
                ToolbarItem {
                    Button("Add") { viewStore.send(.createTodo) }
                }
                ToolbarItem {
                    Button("Clear Completed") {
                        viewStore.send(.clearCompleted)
                    }
                }
            }
        }
    }
}

struct TodosListView_Previews: PreviewProvider {
    static var previews: some View {
        TodosListView(store: TodosList.defaultStore)
    }
}
