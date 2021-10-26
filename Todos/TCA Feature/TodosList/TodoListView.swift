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
        Text("Todos")
          .font(.system(.title, design: .rounded))
          .bold()
          .foregroundColor(.appColor)
          .padding(.bottom)
        
        ForEachStore(store.scope(
          state: \.todos,
          action: TodoListAction.todos(id:action:)
        ), content: TodoView.init)
      }
//      .alert(store.scope(state: \.alert), dismiss: .dismissSignOutAlert)
      .onAppear {
        viewStore.send(.fetchTodos)
      }
      .toolbar {
        ToolbarItem {
          Spacer()
        }
        ToolbarItem {
          Button("Add") { viewStore.send(.createTodo) }
        }
        ToolbarItem {
          Button("Clear Completed") {
            viewStore.send(.clearCompleted)
          }
        }
        ToolbarItem {
          Button("Sign out") {
            //viewStore.send(.createSignOutAlert)
          }
        }
      }
    }
  }
}

struct TodosListView_Previews: PreviewProvider {
  static var previews: some View {
    TodoListView(store: TodoListState.defaultStore)
  }
}
