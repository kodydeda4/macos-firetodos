import SwiftUI
import ComposableArchitecture

struct UserView: View {
  let store: Store<UserState, UserAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        SidebarView(store: store)
        
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



