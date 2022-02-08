import SwiftUI
import ComposableArchitecture
import AuthenticationServices

struct AuthenticationView: View {
  let store: Store<AuthenticationState, AuthenticationAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      ZStack {
        LoginView(store: store)
          .opacity(viewStore.state.route == .login ? 1 : 0)
          .transition(.opacity.combined(with: .offset(x: 0, y: 20)))
        
        SignupView(store: store)
          .opacity(viewStore.state.route == .signup ? 1 : 0)
          .transition(.opacity.combined(with: .offset(x: 0, y: 20)))
      }
    }
  }
}

struct Authentication_Previews: PreviewProvider {
  static var previews: some View {
    AuthenticationView(store: AuthenticationStore.default)
  }
}


