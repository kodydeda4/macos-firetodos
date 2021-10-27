//
//  AuthenticationView.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture
import AuthenticationServices

struct AuthenticationView: View {
  let store: Store<AuthenticationState, AuthenticationAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 20) {
        Circle()
          .frame(width: 30, height: 30)
          .foregroundColor(.red)
          .overlay(Image(systemSymbol: .lock).foregroundColor(.black))
        
        Text("Login")
          .font(.largeTitle)
        
        
        TextField("Email", text: viewStore.binding(\.$email))
        TextField("Password", text: viewStore.binding(\.$password))
        //        SecureField("Password", text: viewStore.binding(\.$password))
        
        Button(action: {viewStore.send(.signInWithEmail)}) {
          ZStack {
            RoundedRectangle(cornerRadius: 4)
              .foregroundColor(.appColor)
            
            Text("Log in")
              .foregroundColor(Color(nsColor: .windowBackgroundColor))
            
          }
        }
        .frame(height: 24)
        .buttonStyle(.plain)
        
        Button("Continue as Guest") {
          viewStore.send(.signInAnonymously)
        }
        
        SignInWithAppleButton() {
          viewStore.send(.signInWithApple(id: $0, nonce: $1))
        }
        
        HStack {
          Link("Forgot Password?", destination: URL(string: "https://www.google.com")!)
          
          Spacer()
          Link("Don't have an account? Sign up", destination: URL(string: "https://www.google.com")!)
        }
        .foregroundColor(.appColor)
        
        Link("Created by Kody Deda", destination: URL(string: "https://kodydeda.netlify.app")!)
          .padding(.top)
          .foregroundColor(.gray)
      }
      .padding()
      .padding(.horizontal, 100)
      .frame(width: 540, height: 860)
      .navigationTitle("Login")
      .textFieldStyle(RoundedBorderTextFieldStyle())
    }
  }
}

struct Authentication_Previews: PreviewProvider {
  static var previews: some View {
    AuthenticationView(store: AuthenticationState.defaultStore)
  }
}

