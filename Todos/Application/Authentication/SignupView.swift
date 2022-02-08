import SwiftUI
import ComposableArchitecture

struct SignupView: View {
  let store: Store<AuthenticationState, AuthenticationAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 20) {
        Circle()
          .frame(width: 30, height: 30)
          .foregroundColor(.red)
          .overlay(Image(systemSymbol: .lock).foregroundColor(.black))
        
        Text("Sign Up")
          .font(.largeTitle)
        
        TextField("Email", text: viewStore.binding(\.$email))
        TextField("Password", text: viewStore.binding(\.$password))
        
        Button(action: { viewStore.send(.signUpWithEmail) }) {
          ZStack {
            RoundedRectangle(cornerRadius: 4)
              .foregroundColor(.accentColor)
            
            Text("Sign Up")
              .foregroundColor(Color(nsColor: .windowBackgroundColor))
            
          }
        }
        .frame(height: 24)
        .buttonStyle(.plain)
        
        Button("Already have an account?") {
          viewStore.send(.updateRoute(.login))
        }
        .foregroundColor(.accentColor)
        .buttonStyle(LinkButtonStyle())
        
        Link("Created by Kody Deda", destination: .personalWebsite)
          .padding(.top)
          .foregroundColor(.gray)
      }
      .padding()
      .padding(.horizontal, 100)
      .navigationTitle("Signup")
      .textFieldStyle(RoundedBorderTextFieldStyle())
      .alert(store.scope(state: \.alert), dismiss: .dismissAlert)
    }
  }
}

struct SignupView_Previews: PreviewProvider {
  static var previews: some View {
    SignupView(store: AuthenticationStore.default)
  }
}
