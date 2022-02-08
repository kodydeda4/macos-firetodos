import SwiftUI
import ComposableArchitecture

struct SidebarView: View {
  let store: Store<UserState, UserAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      List {
        NavigationLink(destination: ProfileView(store: store)) {
          UserProfileView(name: "\(viewStore.user.email ?? "Guest")")
        }
        Section("") {
          NavigationLink(destination: TodoListView(store: store.scope(state: \.todosList, action: UserAction.todosList))) {
            Label("Todos", systemSymbol: .flameFill)
          }
          NavigationLink(destination: ProfileView(store: store)) {
            Label("Settings", systemSymbol: .gearshapeFill)
          }
        }
      }
    }
  }
}

struct SidebarView_Previews: PreviewProvider {
  static var previews: some View {
    SidebarView(store: UserStore.default)
  }
}

struct UserProfileView: View {
  let name: String
  
  var body: some View {
    HStack {
      Image(systemSymbol: .personFill)
        .resizable()
        .scaledToFit()
        .shadow(radius: 10)
        .padding(8)
        .background(Color.accentColor)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .frame(width: 35, height: 35)
      
      VStack(alignment: .leading) {
        Text(name)
        
        Text("Profile")
          .font(.caption)
          .opacity(0.75)
      }
      Spacer()
    }
    .padding(4)
  }
}

func toggleSidebar() {
  NSApp
    .keyWindow?
    .firstResponder?
    .tryToPerform(#selector(NSSplitViewController.toggleSidebar), with: nil)
}
