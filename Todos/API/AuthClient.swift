//
//  UserClient.swift
//  Todos
//
//  Created by Kody Deda on 10/26/21.
//

import ComposableArchitecture
import Combine
import Firebase

struct AuthClient {
  let signup:                (_ email: String, _ password: String)   -> Effect<User, Error>
  let signInEmailPassword:   (_ email: String, _ password: String)   -> Effect<User, Error>
  let signInApple:           (SignInWithAppleToken)                  -> Effect<User, Error>
  let signInAnonymously:     ()                                      -> Effect<User, Error>
  let signOut:               ()                                      -> Effect<Never, Never>
}

extension AuthClient {
  static let live = AuthClient(
    signup: { email, password in
      .task {
        try await Auth.auth().createUser(withEmail: email, password: password).user
      }
    },
    signInEmailPassword: { email, password in
      .task {
        try await Auth.auth().signIn(withEmail: email, password: password).user
      }
    },
    signInApple: { token in
      .task {
        try await Auth.auth().signIn(with: OAuthProvider.credential(
          withProviderID: "apple.com",
          idToken: token.appleID,
          rawNonce: token.nonce
        )).user
      }
    },
    signInAnonymously: {
      .task {
        try await Auth.auth().signInAnonymously().user
      }
    },
    signOut: {
      .fireAndForget {
        try! Auth.auth().signOut()
      }
    }
  )
}
