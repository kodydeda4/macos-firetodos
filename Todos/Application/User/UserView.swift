import SwiftUI
import ComposableArchitecture

struct UserView: View {
  let store: Store<UserState, UserAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        List {
          NavigationLink(destination: { TodoListView(store: store.scope(state: \.todosList, action: UserAction.todosList))}) {
            Label("Todos", systemSymbol: .checkmarkSquareFill)
          }
          NavigationLink(destination: { ProfileView(store: store) }) {
            Label("Profile", systemSymbol: .personCircleFill)
          }
        }
        .listStyle(SidebarListStyle())
        
        TodoListView(store: store.scope(
          state: \.todosList,
          action: UserAction.todosList
        ))
      }
    }
  }
}

struct UserView_Previews: PreviewProvider {
  static var previews: some View {
    UserView(store: UserStore.default)
  }
}

