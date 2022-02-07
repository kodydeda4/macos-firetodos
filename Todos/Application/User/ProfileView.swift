import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
  let store: Store<UserState, UserAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Text(viewStore.user.email ?? "Guest")
          .font(.title)
        
        Button("Buy Premium") {
          viewStore.send(.buyPremiumButtonTapped)
        }
        .disabled(viewStore.isPremiumUser)
        
        Button("Sign Out") {
          viewStore.send(.createSignoutAlert)
        }
      }
      .alert(store.scope(state: \.alert), dismiss: .dismissAlert)
    }
  }
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView(store: UserStore.default)
  }
}
