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
      List {
        Text("Todos")
          .font(.system(.title, design: .rounded))
          .bold()
          .foregroundColor(.appColor)
          .padding(.bottom)
        
        ForEachStore(store.scope(
          state: \.todos,
          action: TodosList.Action.todos(index:action:)
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
    TodosListView(store: TodosList.defaultStore)
  }
}
