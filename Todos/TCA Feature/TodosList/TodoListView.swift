//
//  TodosListView.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture

struct TodoListView: View {
  let store: Store<TodoListState, TodoListAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      List {
        ForEachStore(store.scope(
          state: \.todos,
          action: TodoListAction.todos(id:action:)
        ), content: TodoView.init)
      }
      //      .alert(store.scope(state: \.alert), dismiss: .dismissSignOutAlert)
      .navigationTitle("Todos")
      .onAppear {
        viewStore.send(.fetchTodos)
      }
      .toolbar {
        Spacer()
        Button("Add") {
          viewStore.send(.createTodo)
        }
        Button("Clear Completed") {
          viewStore.send(.clearCompleted)
        }
        Button("Sign out") {
          viewStore.send(.signOutButtonTapped)
        }
      }
    }
  }
}

struct TodosListView_Previews: PreviewProvider {
  static var previews: some View {
    TodoListView(store: .default)
  }
}
