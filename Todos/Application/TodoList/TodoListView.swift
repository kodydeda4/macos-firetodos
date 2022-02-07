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
      .navigationTitle("Todos")
      .alert(store.scope(state: \.alert), dismiss: .dismissAlert)
      .onAppear {
        viewStore.send(.fetch)
      }
      .toolbar {
        Spacer()
        Button(action: { viewStore.send(.createAlert) }) {
          Image(systemSymbol: .trash)
        }
        Button(action: { viewStore.send(.create) }) {
          Image(systemSymbol: .plus)
        }
      }
    }
  }
}

struct TodosListView_Previews: PreviewProvider {
  static var previews: some View {
    TodoListView(store: TodoListStore.default)
  }
}
