//
//  UserClient.swift
//  Todos
//
//  Created by Kody Deda on 10/26/21.
//

import ComposableArchitecture
import Combine
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import AuthenticationServices

struct AuthClient {
  let signInAnonymously: () -> Effect<User, AuthError>
  let signInEmailPassword: (
    _ email: String,
    _ password: String
  ) -> Effect<User, AuthError>
  let signInApple: (SignInWithAppleToken) -> Effect<User, AuthError>
}

enum AuthError: Error, Equatable {
  case signInAnonymously
  case signInEmailPassword
  case signInApple
  case signout
}

extension AuthClient {
  static let live = AuthClient(
    signInAnonymously: {
      let rv = PassthroughSubject<User, AuthError>()
      
      Auth.auth().signInAnonymously { _, _ in
        if let user = Auth.auth().currentUser {
          rv.send(user)
          return
        }
        rv.send(completion: .failure(.signInAnonymously))
      }
      
      return rv.eraseToEffect()
    },
    signInEmailPassword: { email, password in
      let rv = PassthroughSubject<User, AuthError>()
      
      Auth.auth().signIn(withEmail: email, password: password) { _, _ in
        if let user = Auth.auth().currentUser {
          rv.send(user)
          return
        }
        rv.send(completion: .failure(.signInEmailPassword))
      }
      
      return rv.eraseToEffect()
    },
    signInApple: { token in
      let rv = PassthroughSubject<User, AuthError>()
      let credential = OAuthProvider.credential(
        withProviderID: "apple.com",
        idToken: token.appleID.description,
        rawNonce: token.nonce
      )
      Auth.auth().signIn(with: credential) { _, _ in
        if let user = Auth.auth().currentUser {
          rv.send(user)
          return
        }
        rv.send(completion: .failure(.signInApple))
      }
      return rv.eraseToEffect()
    }
  )
}
