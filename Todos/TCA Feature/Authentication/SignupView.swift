//
//  SignupView.swift
//  Todos
//
//  Created by Kody Deda on 11/1/21.
//

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
        
//        Button(action: { viewStore.send(.signUpWithEmail) }) {
        Button(action: { viewStore.send(.createSignupAlert) }) {
          ZStack {
            RoundedRectangle(cornerRadius: 4)
              .foregroundColor(.accentColor)
            
            Text("Log in")
              .foregroundColor(Color(nsColor: .windowBackgroundColor))
            
          }
        }
        .frame(height: 24)
        .buttonStyle(.plain)
        
        Button("Already have an account?") {
          viewStore.send(.updateRoute(.login))//, animation: .default)
        }
        .foregroundColor(.accentColor)
        .buttonStyle(LinkButtonStyle())
        
        Link("Created by Kody Deda", destination: URL(string: "https://kodydeda.netlify.app")!)
          .padding(.top)
          .foregroundColor(.gray)
      }
      .padding()
      .padding(.horizontal, 100)
      .frame(width: 540, height: 860)
      .navigationTitle("Signup")
      .textFieldStyle(RoundedBorderTextFieldStyle())
      .alert(store.scope(state: \.alert), dismiss: .dismissAlert)
    }
  }
}

struct SignupView_Previews: PreviewProvider {
  static var previews: some View {
    SignupView(store: .default)
  }
}
